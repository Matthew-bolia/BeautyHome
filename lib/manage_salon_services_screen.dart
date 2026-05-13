import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'models/service_models.dart';
import 'catalog_detail_screen.dart';
import 'add_edit_salon_service_screen.dart';
import 'services/image_upload_service.dart';
import 'widgets/skeleton_loader.dart';

class ManageSalonServicesScreen extends StatefulWidget {
  const ManageSalonServicesScreen({super.key});

  @override
  State<ManageSalonServicesScreen> createState() =>
      _ManageSalonServicesScreenState();
}

class _ManageSalonServicesScreenState extends State<ManageSalonServicesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Rechercher un catalogue...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
              )
            : Text(
                'Nos Catalogues de Services',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
              ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('serviceCategories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // On utilise uniquement les catégories de Firestore
          List<ServiceCategory> displayCategories = snapshot.data!.docs
              .map((doc) => ServiceCategory.fromFirestore(doc))
              .toList();

          // Filtrage par recherche
          if (_searchQuery.isNotEmpty) {
            displayCategories = displayCategories.where((cat) {
              return cat.name.toLowerCase().contains(_searchQuery) ||
                  cat.description.toLowerCase().contains(_searchQuery);
            }).toList();
          }

          if (displayCategories.isEmpty) {
            return _buildEmptyState(isSearch: true);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: displayCategories.length,
            itemBuilder: (context, index) {
              final category = displayCategories[index];
              return _CatalogCard(
                category: category,
                firestore: _firestore,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CatalogDetailScreen(
                        categoryId: category.id,
                        categoryName: category.name,
                        categoryIcon: category.icon,
                        categoryIconAsset: category.iconAsset,
                      ),
                    ),
                  );
                },
                onEdit: () => _showCategoryDialog(context, category),
                onDelete: () => _confirmDeleteCategory(context, category),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Ajouter',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState({bool isSearch = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch ? Icons.search_off : Icons.folder_open_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isSearch
                ? 'Aucun résultat pour votre recherche'
                : 'Vous n\'avez pas encore créé de catalogue.\nAppuyez sur "Ajouter" pour commencer.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.create_new_folder_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text('Nouveau Catalogue', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(ctx);
                _showCategoryDialog(context, null);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.add_shopping_cart_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text('Nouveau Service', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(ctx);
                _showServiceCategoryPicker(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, ServiceCategory? category) {
    final nameController = TextEditingController(text: category?.name);
    final descController = TextEditingController(text: category?.description);
    File? newPickedFile; // Pour une nouvelle image sélectionnée
    String? currentFirestoreImageUrl; // Pour une image existante de Firestore
    bool isSaving = false;

    // Initialiser _currentFirestoreImageUrl si on modifie une catégorie existante avec une image réseau
    if (category != null &&
        category.assetImages.isNotEmpty &&
        category.assetImages.first.startsWith('http')) {
      currentFirestoreImageUrl = category.assetImages.first;
    }
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              category == null ? 'Nouveau Catalogue' : 'Modifier Catalogue',
            ),
            content: SizedBox(
              // Utilisation de SizedBox pour donner une taille fixe au contenu
              width:
                  MediaQuery.of(context).size.width *
                  0.8, // 80% de la largeur de l'écran
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      enabled: !isSaving,
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Image du catalogue',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Affichage de l'image (nouvelle, existante ou placeholder)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: newPickedFile != null
                          ? Image.file(
                              newPickedFile!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : currentFirestoreImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: currentFirestoreImageUrl!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : (category != null &&
                                category.assetImages.isNotEmpty &&
                                !category.assetImages.first.startsWith('http'))
                          ? Image.asset(
                              // Pour les images assets par défaut
                              category.assetImages.first,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    // Bouton pour supprimer l'image affichée
                    if (newPickedFile != null ||
                        currentFirestoreImageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TextButton.icon(
                          onPressed: isSaving
                              ? null
                              : () {
                                  setDialogState(() {
                                    newPickedFile = null;
                                    currentFirestoreImageUrl =
                                        null; // Marque l'image existante pour suppression
                                  });
                                },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Supprimer l\'image',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final image = await _picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (image != null) {
                                    setDialogState(
                                      () => newPickedFile = File(image.path),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galerie'),
                        ),
                        TextButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final image = await _picker.pickImage(
                                    source: ImageSource.camera,
                                  );
                                  if (image != null) {
                                    setDialogState(
                                      () => newPickedFile = File(image.path),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Photo'),
                        ),
                      ],
                    ),
                    if (isSaving) const LinearProgressIndicator(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (nameController.text.trim().isEmpty ||
                            descController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Veuillez remplir tous les champs obligatoires.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isSaving = true);
                        try {
                          String? uploadedUrl;
                          String? oldImageUrlToDelete;

                          // 1. Gérer la suppression de l'ancienne image si elle est remplacée ou retirée
                          if (category != null &&
                              category.assetImages.isNotEmpty &&
                              category.assetImages.first.startsWith('http')) {
                            if (newPickedFile == null &&
                                currentFirestoreImageUrl == null) {
                              // L'image réseau existante a été explicitement retirée
                              oldImageUrlToDelete = category.assetImages.first;
                            } else if (newPickedFile != null) {
                              // L'image réseau existante est remplacée par une nouvelle
                              oldImageUrlToDelete = category.assetImages.first;
                            }
                          }

                          // 2. Uploader la nouvelle image si sélectionnée
                          if (newPickedFile != null) {
                            uploadedUrl = await _uploadService.uploadImage(
                              imageFile: newPickedFile!,
                              context: context,
                            );
                          } else {
                            // Si pas de nouvelle image, conserver l'URL existante si elle n'a pas été retirée
                            uploadedUrl = currentFirestoreImageUrl;
                          }

                          // 3. Effectuer la suppression si nécessaire
                          if (oldImageUrlToDelete != null) {
                            await _uploadService.deleteImage(
                              oldImageUrlToDelete,
                            );
                          }

                          // 4. Préparer la liste assetImages pour Firestore
                          final List<String> assetImagesForFirestore =
                              uploadedUrl != null ? [uploadedUrl] : [];

                          final data = {
                            'name': nameController.text.trim(),
                            'description': descController.text.trim(),
                            'icon': category?.icon ?? '📁',
                            'iconAsset': category?.iconAsset ?? '',
                            'assetImages': assetImagesForFirestore,
                          };

                          if (category == null) {
                            await _firestore
                                .collection('serviceCategories')
                                .add(data);
                          } else {
                            await _firestore
                                .collection('serviceCategories')
                                .doc(category.id)
                                .set(data, SetOptions(merge: true));
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Catalogue enregistré avec succès !',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Erreur lors de l\'enregistrement : $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setDialogState(() => isSaving = false);
                          }
                        }
                      },
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, ServiceCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce catalogue ?'),
        content: Text(
          'Voulez-vous vraiment supprimer "${category.name}" ? Cela ne supprimera pas les services associés mais ils ne seront plus catégorisés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              // Supprimer l'image Cloudinary associée si elle existe
              if (category.assetImages.isNotEmpty &&
                  category.assetImages.first.startsWith('http')) {
                await _uploadService.deleteImage(category.assetImages.first);
              }

              // Supprimer le document Firestore
              await _firestore
                  .collection('serviceCategories')
                  .doc(category.id)
                  .delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showServiceCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('serviceCategories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Veuillez d\'abord créer un catalogue.'),
            );
          }

          final displayCategories = snapshot.data!.docs
              .map((doc) => ServiceCategory.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: displayCategories.length,
            itemBuilder: (context, i) {
              final cat = displayCategories[i];
              return ListTile(
                leading: cat.iconAsset.isNotEmpty
                    ? Image.asset(
                        cat.iconAsset,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      )
                    : Text(cat.icon, style: const TextStyle(fontSize: 24)),
                title: Text(cat.name),
                subtitle: Text(
                  cat.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEditSalonServiceScreen(categoryId: cat.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Widget réutilisable pour afficher une carte catalogue avec carousel d'images
class _CatalogCard extends StatefulWidget {
  final ServiceCategory category;
  final FirebaseFirestore firestore;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CatalogCard({
    required this.category,
    required this.firestore,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CatalogCard> createState() => _CatalogCardState();
}

class _CatalogCardState extends State<_CatalogCard> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: widget.firestore
          .collection('salonServices')
          .where('categoryId', isEqualTo: widget.category.id)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        List<ServiceImage> images = [];
        int serviceCount = 0;
        bool hasRecentService = false;
        final now = DateTime.now();
        final recentThreshold = now.subtract(
          const Duration(days: 3),
        ); // Seuil de 3 jours pour la nouveauté

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          serviceCount = snapshot.data!.docs.length;
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            // Vérification si un service a été ajouté récemment
            if (data['createdAt'] is Timestamp) {
              final createdAt = (data['createdAt'] as Timestamp).toDate();
              if (createdAt.isAfter(recentThreshold)) {
                hasRecentService = true;
              }
            }

            if (data['images'] is List) {
              images.addAll(
                (data['images'] as List)
                    .map((m) => ServiceImage.fromMap(m as Map<String, dynamic>))
                    .toList(),
              );
            }
          }
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black45 : Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image carousel
                SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      // On affiche les assets par défaut, ou les images Firestore si dispos
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemCount: images.isNotEmpty
                            ? images.length
                            : (widget.category.assetImages.isNotEmpty
                                  ? widget.category.assetImages.length
                                  : 1),
                        itemBuilder: (context, index) {
                          if (images.isNotEmpty) {
                            return CachedNetworkImage(
                              imageUrl: images[index].imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          } else if (widget.category.assetImages.isNotEmpty) {
                            final imagePath =
                                widget.category.assetImages[index];
                            if (imagePath.startsWith('http')) {
                              return CachedNetworkImage(
                                imageUrl: imagePath,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[100],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                              );
                            }
                            return Image.asset(
                              widget.category.assetImages[index],
                              fit: BoxFit.cover,
                            );
                          } else {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          }
                        },
                      ),
                      // Page indicator
                      if (images.isNotEmpty ||
                          widget.category.assetImages.isNotEmpty)
                        Positioned(
                          bottom: 8,
                          left: 16,
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: images.isNotEmpty
                                ? images.length
                                : widget.category.assetImages.length,
                            effect: ScrollingDotsEffect(
                              activeDotColor: Colors.white,
                              dotColor: Colors.white54,
                              dotHeight: 6,
                              dotWidth: 6,
                            ),
                          ),
                        ),
                      // Badge "Nouveau" affiché en haut à gauche
                      if (hasRecentService)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'NOUVEAU',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // Badge nombre d'images
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentPage + 1}/${images.isNotEmpty ? images.length : (widget.category.assetImages.isNotEmpty ? widget.category.assetImages.length : 0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Section Texte (Façon Facebook)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.category.name,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                                onPressed: widget.onEdit,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: widget.onDelete,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.category.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$serviceCount service${serviceCount > 1 ? 's' : ''} publié${serviceCount > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ); // Fin du GestureDetector
      }, // Fin du builder du StreamBuilder
    ); // Fin du StreamBuilder
  } // Fin de la méthode build
} // Fin de la classe _CatalogCardState
