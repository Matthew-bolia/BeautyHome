import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'profile_screen.dart';
import 'user_provider.dart';
import 'booking_screen.dart';
import 'admin_dashboard.dart';
import 'services_screen.dart';
import 'specialists_screen.dart';

// --- Écran de Notifications (Placeholder) ---
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notifications')),
    body: const Center(child: Text('Page des notifications')),
  );
}

// ─── Modèle de publication ─────────────────────────────────────────────────
class Publication {
  final String id;
  final String userName, userProfileImageUrl, publicationImageUrl, description;
  final DateTime publicationDate;

  Publication({
    required this.id,
    required this.userName,
    required this.userProfileImageUrl,
    required this.publicationImageUrl,
    required this.publicationDate,
    required this.description,
  });

  // Factory constructor pour créer une instance depuis un document Firestore
  factory Publication.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Publication(
      id: doc.id,
      userName: data['userName'] ?? 'Utilisateur inconnu',
      userProfileImageUrl: data['userProfileImageUrl'] ?? '',
      publicationImageUrl: data['publicationImageUrl'] ?? '',
      publicationDate: (data['publicationDate'] as Timestamp).toDate(),
      description: data['description'] ?? '',
    );
  }
}

// ─── HomeScreen ────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('fr', timeago.FrMessages());
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

  Future<void> _saveImage(BuildContext context, String imageUrl) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // 1. Demander la permission
      var status = await Permission.photos.request();
      if (status.isGranted) {
        // 2. Télécharger l'image
        var response = await Dio().get(
          imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        // 3. Sauvegarder dans la galerie
        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 80,
          name: "beauty_home_${DateTime.now().millisecondsSinceEpoch}",
        );
        if (result['isSuccess']) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Image enregistrée dans la galerie.')),
          );
        } else {
          throw Exception('Échec de la sauvegarde de l\'image.');
        }
      } else {
        throw Exception('Permission de stockage refusée.');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: _buildProfileIcon(),
        title: _buildSearchBar(),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            tooltip: 'Notifications',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            tooltip: 'Menu',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: _buildAppDrawer(),
      body: _buildPinterestFeed(),
    );
  }

  Widget _buildProfileIcon() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final photoURL = userProvider.photoURL;
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
              child: photoURL == null
                  ? Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _searchController,
        cursorColor: Theme.of(context).colorScheme.primary,
        decoration: InputDecoration(
          hintText: 'Rechercher un style...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.6),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerItem(
            icon: Icons.home_outlined,
            text: 'Accueil',
            onTap: () => Navigator.of(context).pop(),
          ),
          _buildDrawerItem(
            icon: Icons.content_cut_outlined,
            text: 'Tous nos services',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AllServicesScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.people_alt_outlined,
            text: 'Nos spécialistes',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SpecialistsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today_outlined,
            text: 'Prendre rendez-vous',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BookingScreen(preselectedService: ''),
                ),
              );
            },
          ),
          if (Provider.of<UserProvider>(context, listen: true).isAdmin ==
              true) ...[
            const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
            _buildDrawerItem(
              icon: Icons.dashboard_outlined,
              text: 'Dashboard Admin',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                );
              },
            ),
          ],
          const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Déconnexion',
            onTap: () => _showLogoutConfirmationDialog(context),
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.pexels.com/photos/1319459/pexels-photo-1319459.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Beauty Home',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  ListTile _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: color ?? theme.colorScheme.onSurfaceVariant),
      title: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color ?? theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    Navigator.of(context).pop(); // Ferme le drawer d'abord
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirmation'),
          content: const Text(
            'Êtes-vous certain(e) de vouloir vous déconnecter ?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Se déconnecter'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPinterestFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('publications')
          .orderBy('publicationDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Une erreur est survenue.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 60,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucune publication pour le moment',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        final publications = snapshot.data!.docs
            .map((doc) => Publication.fromFirestore(doc))
            .toList();

        final filteredPublications = publications
            .where(
              (pub) =>
                  pub.userName.toLowerCase().contains(_searchQuery) ||
                  pub.description.toLowerCase().contains(_searchQuery),
            )
            .toList();

        if (filteredPublications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'Aucun résultat pour "$_searchQuery"',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          padding: const EdgeInsets.all(10),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: filteredPublications.length,
          itemBuilder: (context, index) {
            return _buildPinCard(filteredPublications[index]);
          },
        );
      },
    );
  }

  Widget _buildPinCard(Publication publication) {
    return GestureDetector(
      onTap: () => _showPublicationDetail(publication),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.network(
                  publication.publicationImageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) => progress == null
                      ? child
                      : Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                  errorBuilder: (ctx, e, s) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      onTap: () =>
                          _saveImage(context, publication.publicationImageUrl),
                      borderRadius: BorderRadius.circular(30),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.save_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publication.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined, size: 13),
                      label: Text(
                        'Réserver',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () => _openBookingFromPost(publication),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBookingFromPost(Publication publication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BookingBottomSheet(stylistName: publication.userName),
    );
  }

  void _showPublicationDetail(Publication publication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          publication.publicationImageUrl,
                          width: double.infinity,
                          height: 380,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(
                                    publication.userProfileImageUrl,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      publication.userName,
                                      style: GoogleFonts.cormorantGaramond(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    Text(
                                      timeago.format(
                                        publication.publicationDate,
                                        locale: 'fr',
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              publication.description,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            'Réserver ce style',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openBookingFromPost(publication);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A2E),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingBottomSheet extends StatelessWidget {
  final String stylistName;
  const _BookingBottomSheet({required this.stylistName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Réserver avec',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Text(
            stylistName,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              'Choisir une date et un service',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingScreen(
                    preselectedSpecialistName: stylistName,
                    preselectedService: '',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}
