import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();

  // Configuration Cloudinary (extraite de votre code add_publication)
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dnn1lzluo',
    'medias_flutter',
    cache: false,
  );

  // Méthode pour choisir une image depuis la galerie ou la caméra
  Future<File?> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Méthode pour uploader une image sur Firebase Storage
  Future<String?> uploadImage({
    required File imageFile,
    required BuildContext context,
  }) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  // Note: La suppression publique sur Cloudinary nécessite généralement une signature côté serveur.
  // Cette méthode est simplifiée pour éviter les erreurs de compilation.
  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return;
    }
    debugPrint(
      'Demande de suppression pour : $imageUrl (Nécessite API Secret)',
    );
  }

  // Méthode pour optimiser les URLs Cloudinary
  String optimizeUrl(
    String url, {
    int? width,
    int? height,
    bool isAvatar = false,
  }) {
    if (!url.contains('cloudinary')) return url;

    String transformations = 'f_auto,q_auto';
    if (width != null) transformations += ',w_$width';
    if (height != null) transformations += ',h_$height';
    if (isAvatar)
      transformations += ',g_face,c_thumb';
    else if (width != null || height != null)
      transformations += ',c_fill';

    return url.replaceFirst('/upload/', '/upload/$transformations/');
  }
}
