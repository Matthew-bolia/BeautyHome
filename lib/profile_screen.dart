import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/image_upload_service.dart';
import 'user_provider.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'widgets/about_screen.dart';
import 'terms_of_use_screen.dart';
import 'contact_us_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService();
  bool _isUploading = false;
  File? _localImageFile;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- LOGIQUE MÉTIER ---

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _localImageFile = File(image.path);
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // Utilisation du service Cloudinary
      final url = await _uploadService.uploadImage(
        imageFile: _localImageFile!,
        context: context,
      );

      if (url != null) {
        // Nettoyage de l'ancienne image Cloudinary
        final userProvider = context.read<UserProvider>();
        if (userProvider.photoURL != null &&
            userProvider.photoURL!.contains('cloudinary')) {
          await _uploadService.deleteImage(userProvider.photoURL!);
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'photoURL': url});
        userProvider.updatePhotoUrl(url);
        _showSnackbar('Photo de profil mise à jour !', success: true);
      }
    } catch (e) {
      _showSnackbar('Erreur lors de la mise à jour : ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _localImageFile = null;
        });
      }
    }
  }

  Future<void> _updateDisplayName() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userProvider = context.read<UserProvider>();
    _nameController.text = userProvider.displayName ?? '';

    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier votre nom'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Nom complet"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _nameController.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      try {
        userProvider.updateDisplayName(
          newName,
        ); // On met à jour l'UI immédiatement

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'displayName': newName});

        if (mounted) {
          _showSnackbar('Nom mis à jour avec succès.', success: true);
        }
      } catch (e) {
        if (mounted) _showSnackbar('Erreur lors de la mise à jour.');
      }
    }
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser!;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      final photoURL = Provider.of<UserProvider>(
        context,
        listen: false,
      ).photoURL;
      if (photoURL != null && photoURL.contains('cloudinary')) {
        await _uploadService.deleteImage(photoURL);
      }

      await user.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre compte a été supprimé avec succès.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Une erreur est survenue.';
      if (e.code == 'requires-recent-login') {
        message =
            'Cette opération est sensible et nécessite une authentification récente. Veuillez vous reconnecter et réessayer.';
      }
      if (mounted) _showSnackbar(message);
    } catch (e) {
      if (mounted) _showSnackbar('Erreur: ${e.toString()}');
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Êtes-vous sûr ?'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront définitivement perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // --- Widgets de l'interface ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildAvatar(userProvider.photoURL),
                    const SizedBox(height: 12),
                    Text(
                      userProvider.displayName ?? 'Utilisateur',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProvider.email ?? '',
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const Divider(),
                ProfileMenuItem(
                  title: 'Modifier le nom',
                  icon: Icons.edit_outlined,
                  onTap: _updateDisplayName,
                ),
                ProfileMenuItem(
                  title: 'Paramètres',
                  icon: Icons.settings_outlined,
                  onTap: () => _navigateTo(const SettingsScreen()),
                ),
                const Divider(),
                ProfileMenuItem(
                  title: 'Aide et support',
                  icon: Icons.help_outline,
                  onTap: () => _navigateTo(const HelpScreen()),
                ),
                ProfileMenuItem(
                  title: 'À propos',
                  icon: Icons.info_outline,
                  onTap: () => _navigateTo(const AboutScreen()),
                ),
                ProfileMenuItem(
                  title: 'Nous contacter',
                  icon: Icons.email_outlined,
                  onTap: () => _navigateTo(const ContactUsScreen()),
                ),
                ProfileMenuItem(
                  title: 'Conditions d\'utilisation',
                  icon: Icons.gavel_outlined,
                  onTap: () => _navigateTo(const TermsOfUseScreen()),
                ),
                const Divider(),
                ProfileMenuItem(
                  title: 'Supprimer mon compte',
                  icon: Icons.delete_forever_outlined,
                  color: Colors.red,
                  onTap: _showDeleteConfirmationDialog,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? photoURL) {
    return GestureDetector(
      onTap: _isUploading ? null : _pickAndUploadImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  () {
                        if (_localImageFile != null)
                          return FileImage(_localImageFile!);
                        if (photoURL != null &&
                            photoURL.isNotEmpty &&
                            photoURL.startsWith('http')) {
                          return CachedNetworkImageProvider(
                            _uploadService.optimizeUrl(
                              photoURL,
                              width: 300,
                              isAvatar: true,
                            ),
                          );
                        }
                        return null;
                      }()
                      as ImageProvider?,
              child:
                  (_localImageFile == null &&
                      (photoURL == null || photoURL.isEmpty))
                  ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                  : null,
            ),
          ),
          if (_isUploading) const CircularProgressIndicator(),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}

// Widget pour un élément de menu du profil
class ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).iconTheme.color?.withOpacity(0.7),
      ),
      title: Text(title, style: GoogleFonts.lato(fontSize: 16, color: color)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
