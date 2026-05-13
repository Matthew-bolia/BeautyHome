import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/image_upload_service.dart';

class AddEditSpecialistScreen extends StatefulWidget {
  final DocumentSnapshot? specialistDocument;

  const AddEditSpecialistScreen({super.key, this.specialistDocument});

  @override
  State<AddEditSpecialistScreen> createState() => _AddEditSpecialistScreenState();
}

class _AddEditSpecialistScreenState extends State<AddEditSpecialistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();

  final _imageUploadService = ImageUploadService();
  File? _selectedImageFile;
  String? _networkImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.specialistDocument != null) {
      final data = widget.specialistDocument!.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _roleController.text = data['role'] ?? '';
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
        _networkImageUrl = null; // Clear old network image
      });
    }
  }

  Future<void> _saveSpecialist() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImageFile == null && _networkImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner une image pour le spécialiste.')),
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
      if (finalImageUrl == null) {
        setState(() => _isLoading = false);
        return; // Upload failed
      }
    }

    final specialistData = {
      'name': _nameController.text.trim(),
      'role': _roleController.text.trim(),
      'imageUrl': finalImageUrl,
    };

    try {
      if (widget.specialistDocument == null) {
        await FirebaseFirestore.instance.collection('specialists').add(specialistData);
      } else {
        await widget.specialistDocument!.reference.update(specialistData);
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.specialistDocument == null ? 'Ajouter un Spécialiste' : 'Modifier le Spécialiste'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'Nom du spécialiste', Icons.person),
              _buildTextField(_roleController, 'Rôle (ex: Coiffeur, Styliste)', Icons.work),
              const SizedBox(height: 30),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _saveSpecialist,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        // Utilisation d'un CircleAvatar pour la prévisualisation
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          backgroundImage: _selectedImageFile != null
              ? FileImage(_selectedImageFile!) as ImageProvider
              : _networkImageUrl != null
                  ? CachedNetworkImageProvider(_networkImageUrl!)
                  : null,
          child: (_selectedImageFile == null && _networkImageUrl == null)
              ? Icon(Icons.person, size: 60, color: Colors.grey[400])
              : null,
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
        )
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
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
    _roleController.dispose();
    super.dispose();
  }
}
