import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'user_provider.dart';
import 'theme_provider.dart';
import 'image_cropper_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  title: const Text('Mode Sombre'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (isDarkMode) {
                    themeProvider.toggleTheme(isDarkMode);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('À Propos')),
    body: const Center(child: Text('Informations sur l\'application')),
  );
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Aide')),
    body: const Center(child: Text('Centre d\'aide et support')),
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  String _displayName = "Nom d'utilisateur";
  String? _profileImageUrl;
  bool _isUploading = false;
  File?
  _localImageFile;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _displayName =
        userProvider.name ?? currentUser?.displayName ?? "Utilisateur Anonyme";
    _profileImageUrl = userProvider.photoURL ?? currentUser?.photoURL;
  }

  Future<void> _changeProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final CroppedFile? croppedFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCropperScreen(imagePath: image.path),
      ),
    );

    if (croppedFile == null) return;

    setState(() {
      _localImageFile = File(croppedFile.path);
    });

    setState(() {
      _isUploading = true;
    });

    try {
      final cloudinary = CloudinaryPublic('doqj8myax', 'xfp55n8l');
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          croppedFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUserPhoto(response.secureUrl);

      setState(() {
        _profileImageUrl = response.secureUrl;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour avec succès !'),
        ),
      );
    } catch (e, s) {
      developer.log(
        'Erreur dans _changeProfilePicture',
        name: 'ProfileScreen.Error',
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _editDisplayName() async {
    final TextEditingController nameController = TextEditingController(
      text: _displayName,
    );
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier votre nom'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Nouveau nom"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == _displayName) return;

    try {
      await currentUser?.updateDisplayName(newName);
      setState(() {
        _displayName = newName;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nom mis à jour avec succès !')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du nom : $e')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Supprimer le compte',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Êtes-vous absolument sûr ? Cette action est irréversible et toutes vos données (profil, publications, etc.) seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer Définitivement'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await currentUser?.delete();

      if (!mounted) return;
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Veuillez vous déconnecter et vous reconnecter pour effectuer cette action.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression du compte : $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  key: ValueKey<String?>(_profileImageUrl),
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _localImageFile != null
                      ? FileImage(_localImageFile!)
                      : (_profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null),
                  child: _profileImageUrl == null && _localImageFile == null
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                if (_isUploading) const CircularProgressIndicator(),
                if (!_isUploading)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: _changeProfilePicture,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _displayName,
                  style: GoogleFonts.oswald(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: _editDisplayName,
                ),
              ],
            ),
            Text(
              currentUser?.email ?? '',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Paramètres'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('À Propos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Aide'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HelpScreen())),
            ),
            const Divider(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Supprimer mon compte'),
              onPressed: _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}
