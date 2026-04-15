import 'dart:io';
import 'package:flutter/foundation.dart'; // Importer pour kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class AddPublicationScreen extends StatefulWidget {
  const AddPublicationScreen({super.key});

  @override
  State<AddPublicationScreen> createState() => _AddPublicationScreenState();
}

class _AddPublicationScreenState extends State<AddPublicationScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();

  XFile? _pickedFile;
  bool _isLoading = false;

  // Vos informations Cloudinary
  final String _cloudinaryCloudName = 'dnn1lzluo';
  final String _cloudinaryUploadPreset = 'medias_flutter';

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  Future<void> _publish() async {
    if (_isLoading) return;

    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une image.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // 1. Envoi vers Cloudinary (fonctionne pour web et mobile)
      final cloudinary = CloudinaryPublic(
        _cloudinaryCloudName,
        _cloudinaryUploadPreset,
        cache: false,
      );

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          _pickedFile!.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final imageUrl = response.secureUrl;

      // 2. Sauvegarde dans Firestore
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userName = userProvider.name ?? 'Utilisateur Anonyme';
      final userProfileImageUrl = userProvider.photoURL ?? '';

      await FirebaseFirestore.instance.collection('publications').add({
        'publicationImageUrl': imageUrl,
        'description': _descriptionController.text,
        'userName': userName,
        'userProfileImageUrl': userProfileImageUrl,
        'publicationDate':
            FieldValue.serverTimestamp(), // Firestore gère la date
      });

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Publication réussie !')),
      );
      navigator.pop();
    } on CloudinaryException catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erreur Cloudinary: ${e.message}')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Une erreur est survenue: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImagePreview() {
    if (_pickedFile == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Appuyez pour choisir une image',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // kIsWeb est une constante de Flutter qui est vraie si l'app tourne sur le web
    if (kIsWeb) {
      // Sur le web, le chemin est une URL que Image.network peut afficher
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _pickedFile!.path,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else {
      // Sur mobile, on utilise le chemin du fichier avec Image.file
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(_pickedFile!.path),
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nouvelle Publication',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _publish,
              tooltip: 'Publier',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child:
                    _buildImagePreview(), // Utiliser le widget de prévisualisation
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Décrivez votre style...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}
