import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/image_upload_service.dart';

class AddEditServiceScreen extends StatefulWidget {
  final DocumentSnapshot? serviceDocument;

  const AddEditServiceScreen({super.key, this.serviceDocument});

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _iconController = TextEditingController();

  final _imageUploadService = ImageUploadService();
  File? _selectedImageFile;
  String? _networkImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.serviceDocument != null) {
      final data = widget.serviceDocument!.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _durationController.text = data['durationMinutes']?.toString() ?? '';
      _iconController.text = data['icon'] ?? '';
      if (data.containsKey('imageUrl') && data['imageUrl'].isNotEmpty) {
        _networkImageUrl = data['imageUrl'];
      }
    }
  }

  Future<void> _pickAndSetImage(ImageSource source) async {
    final file = await _imageUploadService.pickImage(source);
    if (file != null) {
      setState(() {
        _selectedImageFile = file;
        _networkImageUrl =
            null; // Effacer l'ancienne image réseau si une nouvelle est choisie
      });
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImageFile == null && _networkImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une image pour le service.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? finalImageUrl = _networkImageUrl;

    // Si une nouvelle image a été sélectionnée, l'uploader
    if (_selectedImageFile != null) {
      finalImageUrl = await _imageUploadService.uploadImage(
        imageFile: _selectedImageFile!,
        context: context,
      );
      if (finalImageUrl == null) {
        setState(() => _isLoading = false);
        return; // L'upload a échoué
      }
    }

    final serviceData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'durationMinutes': int.tryParse(_durationController.text.trim()) ?? 0,
      'icon': _iconController.text.trim(),
      'imageUrl': finalImageUrl,
    };

    try {
      if (widget.serviceDocument == null) {
        await FirebaseFirestore.instance
            .collection('salonServices')
            .add(serviceData);
      } else {
        await widget.serviceDocument!.reference.update(serviceData);
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.serviceDocument == null
              ? 'Ajouter un Service'
              : 'Modifier le Service',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildTextField(
                _nameController,
                'Nom du service',
                Icons.content_cut,
              ),
              _buildTextField(
                _descriptionController,
                'Description',
                Icons.description,
                maxLines: 3,
              ),
              _buildTextField(
                _priceController,
                'Prix (€)',
                Icons.euro,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                _durationController,
                'Durée (minutes)',
                Icons.timer,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                _iconController,
                'Emoji Icône (ex: ✨)',
                Icons.emoji_emotions,
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _saveService,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _selectedImageFile != null
                ? Image.file(_selectedImageFile!, fit: BoxFit.cover)
                : _networkImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: _networkImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.red),
                  )
                : const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Galerie'),
              onPressed: () => _pickAndSetImage(ImageSource.gallery),
            ),
            TextButton.icon(
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Appareil Photo'),
              onPressed: () => _pickAndSetImage(ImageSource.camera),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          // La validation de l'image se fait séparément
          if (label != 'URL de l\'image (optionnel)' &&
              (value == null || value.trim().isEmpty)) {
            return 'Ce champ est obligatoire';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _iconController.dispose();
    super.dispose();
  }
}
