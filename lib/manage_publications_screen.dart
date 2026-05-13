import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'services/image_upload_service.dart';
import 'user_provider.dart';

class ManagePublicationsScreen extends StatelessWidget {
  const ManagePublicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gérer les Publications',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('publications')
            .orderBy('publicationDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune publication.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final imageUrl = data['publicationImageUrl'] as String? ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : null,
                  title: Text(
                    data['description'] ?? 'Sans description',
                    maxLines: 2,
                  ),
                  subtitle: Text(
                    'Publié par ${data['userName']} - ${timeago.format((data['publicationDate'] as Timestamp).toDate(), locale: 'fr')}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () => _showAddEditSheet(
                          context,
                          publicationDocument: doc,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _deletePublication(context, doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(context),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: Text(
          'Créer un post',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showAddEditSheet(
    BuildContext context, {
    DocumentSnapshot? publicationDocument,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddEditPublicationSheet(publicationDocument: publicationDocument),
    );
  }

  Future<void> _deletePublication(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('publications')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Publication supprimée.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }
}

class AddEditPublicationSheet extends StatefulWidget {
  final DocumentSnapshot? publicationDocument;

  const AddEditPublicationSheet({super.key, this.publicationDocument});

  @override
  State<AddEditPublicationSheet> createState() =>
      _AddEditPublicationSheetState();
}

class _AddEditPublicationSheetState extends State<AddEditPublicationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _imageUploadService = ImageUploadService();
  File? _selectedImageFile;
  String? _networkImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.publicationDocument != null) {
      final data = widget.publicationDocument!.data() as Map<String, dynamic>;
      _descriptionController.text = data['description'] ?? '';
      _networkImageUrl = data['publicationImageUrl'];
    }
  }

  Future<void> _pickAndSetImage(ImageSource source) async {
    final pickedFile = await _imageUploadService.pickImage(source);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = pickedFile;
        _networkImageUrl = null;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _networkImageUrl = null;
    });
  }

  Future<void> _savePublication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImageFile == null && _networkImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une image.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? finalImageUrl = _networkImageUrl;

    if (_selectedImageFile != null) {
      finalImageUrl = await _imageUploadService.uploadImage(
        imageFile: _selectedImageFile!,
        context: context,
      );
    }

    if (finalImageUrl == null && _selectedImageFile != null) {
      setState(() => _isLoading = false);
      return;
    }

    final userProvider = context.read<UserProvider>();

    final publicationData = {
      'description': _descriptionController.text.trim(),
      'publicationImageUrl': finalImageUrl,
      'publicationDate': FieldValue.serverTimestamp(),
      'userName': userProvider.displayName ?? 'Admin',
      'userProfileImageUrl': userProvider.photoURL ?? '',
    };

    try {
      if (widget.publicationDocument == null) {
        await FirebaseFirestore.instance
            .collection('publications')
            .add(publicationData);
      } else {
        await widget.publicationDocument!.reference.update(publicationData);
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Barre supérieure (Header) avec actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: GoogleFonts.inter(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  Text(
                    widget.publicationDocument == null
                        ? 'Nouveau post'
                        : 'Modifier le post',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _savePublication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C00),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Publier'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePicker(),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        style: GoogleFonts.inter(
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ecrivez une description pour ce post',
                          hintStyle: GoogleFonts.inter(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3)
                              : Colors.grey[100],
                        ),
                        maxLines: 4,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Dites-en un peu plus sur ce style'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showPickOptions(),
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _selectedImageFile != null
                      ? (kIsWeb
                            ? Image.network(
                                _selectedImageFile!.path,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Image.file(
                                _selectedImageFile!,
                                key: ValueKey(
                                  _selectedImageFile!.path,
                                ), // Force le rafraîchissement visuel
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ))
                      : _networkImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: _networkImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 48,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Appuyez pour ajouter une photo',
                                style: GoogleFonts.inter(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                if (_selectedImageFile != null || _networkImageUrl != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Galerie',
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSetImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Appareil photo',
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSetImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
