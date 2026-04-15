import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropperScreen extends StatefulWidget {
  final String imagePath;

  const ImageCropperScreen({super.key, required this.imagePath});

  @override
  _ImageCropperScreenState createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cropImage();
    });
  }

  Future<void> _cropImage() async {
    if (!mounted) return;

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Rogner l\'image',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle,
            // ← NOUVEAU : désactive les gestes qui peuvent bloquer l'UI
            //   sur certains appareils Android
            showCropGrid: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Rogner l\'image',
            doneButtonTitle: 'Confirmer',
            cancelButtonTitle: 'Annuler',
            aspectRatioPickerButtonHidden: true,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            cropStyle: CropStyle.circle,
          ),
        ],
      );

      // ← CORRIGÉ : on vérifie que le widget est encore monté
      //   APRÈS l'await (opération asynchrone longue) avant de pop
      if (!mounted) return;

      // ← CORRIGÉ : on retourne le résultat qu'il soit null (annulation)
      //   ou non (image rognée) — le comportement est identique mais
      //   maintenant la vérification mounted est garantie
      Navigator.pop(context, croppedFile);
    } catch (e) {
      // ← NOUVEAU : si ImageCropper plante (permissions, fichier illisible,
      //   bug natif), on retourne null proprement au lieu de rester bloqué
      if (!mounted) return;
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // ← NOUVEAU : message ajouté pour que l'utilisateur comprenne
        //   ce qui se passe pendant le chargement
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Chargement de l\'image...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
