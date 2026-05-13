import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();

  // Valeurs mises à jour avec vos informations Cloudinary
  final String _cloudName = 'dnn1lzluo';
  final String _uploadPreset = 'medias_flutter';

  late final CloudinaryPublic _cloudinary;

  ImageUploadService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  /// Ouvre la galerie ou l'appareil photo pour sélectionner une image.
  ///
  /// Retourne le fichier de l'image sélectionnée ou null si aucune image n'est choisie.
  Future<File?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 65, // Compression optimisée pour l'upload
      maxWidth:
          800, // Résolution suffisante pour mobile tout en réduisant le poids
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// Optimise l'URL Cloudinary en ajoutant des transformations (redimensionnement, qualité auto, format auto).
  String optimizeUrl(
    String url, {
    int? width,
    int? height,
    bool isAvatar = false, // Ajout de isAvatar pour le recadrage intelligent
  }) {
    if (!url.contains('res.cloudinary.com') || !url.contains('/upload/')) {
      return url;
    }

    List<String> params = [];
    if (width != null) params.add('w_$width');
    if (height != null) params.add('h_$height');

    if (isAvatar) {
      params.add('c_fill');
      params.add('g_face');
    } else if (width != null || height != null) {
      params.add('c_limit');
    }

    params.add('q_auto');
    params.add('f_auto');

    final transformString = params.join(',');
    return url.replaceFirst('/upload/', '/upload/$transformString/');
  }

  /// Uploade une image sur Cloudinary et retourne l'URL sécurisée.
  ///
  /// Affiche une SnackBar en cas d'erreur.
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
    } on CloudinaryException catch (e) {
      // Fournir plus d'informations pour le debug (preset / cloud name)
      final msg =
          'Erreur Cloudinary: ${e.message}. Vérifiez cloudName et uploadPreset.';
      debugPrint('CloudinaryException: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return null;
    } catch (e) {
      debugPrint('Upload error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur d\'upload: $e')));
      return null;
    }
  }

  /// Supprime une image (Logique simplifiée pour l'interface).
  /// Note: La suppression Cloudinary côté client nécessite normalement une signature API.
  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty || !imageUrl.contains('cloudinary')) {
      debugPrint('Pas une image Cloudinary ou URL vide, suppression ignorée.');
      return;
    }
    try {
      debugPrint('Image marquée pour suppression dans Cloudinary : $imageUrl');
    } catch (e) {
      debugPrint('Erreur lors de la suppression Cloudinary : $e');
    }
  }
}
