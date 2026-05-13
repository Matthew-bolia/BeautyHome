import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'services/image_upload_service.dart';
import 'models/service_models.dart';

class AddEditSalonServiceScreen extends StatefulWidget {
  final String categoryId;
  final DocumentSnapshot? serviceDocument;

  const AddEditSalonServiceScreen({
    super.key,
    required this.categoryId,
    this.serviceDocument,
  });

  @override
  State<AddEditSalonServiceScreen> createState() =>
      _AddEditSalonServiceScreenState();
}

class _AddEditSalonServiceScreenState extends State<AddEditSalonServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  String _currency = '\$';

  final _imageUploadService = ImageUploadService();
  final List<File> _selectedImageFiles = [];
  final List<ServiceImage> _networkImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.serviceDocument != null) {
      final data = widget.serviceDocument!.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      // Afficher la durée en minutes par défaut, mais permettre la saisie en heures (ex: 1h30)
      final durationMin = data['durationMinutes'] ?? 0;
      _durationController.text = durationMin.toString();
      _currency = data['currency'] ?? '\$';

      // Charger les images existantes
      if (data['images'] is List) {
        _networkImages.addAll(
          (data['images'] as List)
              .map((img) => ServiceImage.fromMap(img as Map<String, dynamic>))
              .toList(),
        );
      }
    }
  }

  Future<void> _pickAndAddImage(ImageSource source) async {
    final file = await _imageUploadService.pickImage(source);
    if (file != null) {
      setState(() {
        _selectedImageFiles.add(file);
      });
    }
  }

  void _removeLocalImage(int index) {
    setState(() {
      _selectedImageFiles.removeAt(index);
    });
  }

  void _removeNetworkImage(int index) {
    setState(() {
      _networkImages.removeAt(index);
    });
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImageFiles.isEmpty && _networkImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez ajouter au moins une image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<ServiceImage> allImages = List.from(_networkImages);

      // Uploader les nouvelles images
      for (File imageFile in _selectedImageFiles) {
        final imageUrl = await _imageUploadService.uploadImage(
          imageFile: imageFile,
          context: context,
        );
        if (imageUrl != null) {
          allImages.add(
            ServiceImage(
              id: const Uuid().v4(),
              imageUrl: imageUrl,
              uploadedAt: DateTime.now(),
            ),
          );
        }
      }

      final serviceData = {
        'categoryId': widget.categoryId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'durationMinutes': _parseDurationToMinutes(
          _durationController.text.trim(),
        ),
        'currency': _currency,
        'images': allImages.map((img) => img.toMap()).toList(),
        'createdAt': widget.serviceDocument == null
            ? DateTime.now()
            : (widget.serviceDocument!.data() as Map)['createdAt'],
        'isActive': true,
      };

      if (widget.serviceDocument == null) {
        await FirebaseFirestore.instance
            .collection('salonServices')
            .add(serviceData);
      } else {
        await widget.serviceDocument!.reference.update(serviceData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Service publié et ajouté au catalogue !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
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
                    widget.serviceDocument == null
                        ? 'Nouveau Service'
                        : 'Modifier Service',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                        : const Text('Enregistrer'),
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
                      Text(
                        'Images du service',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildImageGrid(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Galerie'),
                            onPressed: () =>
                                _pickAndAddImage(ImageSource.gallery),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Caméra'),
                            onPressed: () =>
                                _pickAndAddImage(ImageSource.camera),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        _nameController,
                        'Nom du service',
                        Icons.shopping_bag,
                      ),
                      _buildTextField(
                        _descriptionController,
                        'Description',
                        Icons.description,
                        maxLines: 3,
                      ),
                      _buildPricingRow(),
                      _buildDurationField(),
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

  Widget _buildImageGrid() {
    final totalCount = _selectedImageFiles.length + _networkImages.length;
    if (totalCount == 0) {
      return Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Icon(Icons.add_a_photo_outlined, color: Colors.grey),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index < _selectedImageFiles.length) {
          return _buildLocalImageItem(index);
        } else {
          return _buildNetworkImageItem(index - _selectedImageFiles.length);
        }
      },
    );
  }

  Widget _buildLocalImageItem(int index) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(_selectedImageFiles[index], fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeLocalImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImageItem(int index) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: _networkImages[index].imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeNetworkImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Prix',
                prefixIcon: const Icon(Icons.euro),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) => value!.trim().isEmpty ? 'Requis' : null,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: DropdownButtonFormField<String>(
              value: _currency,
              items: [
                DropdownMenuItem(value: '\$', child: Text('\$')),
                DropdownMenuItem(value: 'FC', child: Text('FC')),
              ],
              onChanged: (v) => setState(() => _currency = v ?? '\$'),
              decoration: InputDecoration(
                labelText: 'Devise',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _durationController,
        decoration: InputDecoration(
          labelText: 'Durée (ex: 1h, 1h30 ou 90)',
          prefixIcon: const Icon(Icons.timer),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value!.trim().isEmpty) return 'Requis';
          final v = value.trim();
          if (v.contains('h')) return null;
          if (int.tryParse(v) != null) return null;
          return 'Format invalide';
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) => value!.trim().isEmpty ? 'Requis' : null,
      ),
    );
  }

  int _parseDurationToMinutes(String input) {
    final v = input.trim().toLowerCase();
    if (v.isEmpty) return 0;
    if (v.contains('h')) {
      try {
        final parts = v.split('h');
        final hours = int.tryParse(parts[0].trim()) ?? 0;
        final mins = parts.length > 1 && parts[1].isNotEmpty
            ? int.tryParse(parts[1].trim()) ?? 0
            : 0;
        return hours * 60 + mins;
      } catch (_) {
        return 0;
      }
    }
    return int.tryParse(v) ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
