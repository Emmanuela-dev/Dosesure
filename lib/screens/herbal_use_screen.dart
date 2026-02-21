import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
import '../models/herbal_use.dart';
import '../services/photo_verification_service.dart';
import '../widgets/comment_section.dart';

class HerbalUseScreen extends StatefulWidget {
  const HerbalUseScreen({super.key});

  @override
  State<HerbalUseScreen> createState() => _HerbalUseScreenState();
}

class _HerbalUseScreenState extends State<HerbalUseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _purposeController = TextEditingController();
  final _notesController = TextEditingController();
  final _localNameController = TextEditingController();
  final _botanicalGenusController = TextEditingController();
  final _preparationController = TextEditingController();
  final _originController = TextEditingController();
  XFile? _productPhoto;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _purposeController.dispose();
    _notesController.dispose();
    _localNameController.dispose();
    _botanicalGenusController.dispose();
    _preparationController.dispose();
    _originController.dispose();
    super.dispose();
  }

  Future<void> _captureProductPhoto() async {
    try {
      final photoService = PhotoVerificationService();
      final photo = await photoService.capturePhoto();
      if (photo != null) {
        setState(() => _productPhoto = photo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo captured successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _addHerbalUse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser!.id;
      
      String? photoUrl;
      if (_productPhoto != null) {
        final photoService = PhotoVerificationService();
        photoUrl = await photoService.uploadPhoto(userId, 'herbal_${DateTime.now().millisecondsSinceEpoch}', _productPhoto!);
      }

      final herbalUse = HerbalUse(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        purpose: _purposeController.text.trim(),
        startDate: DateTime.now(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        localName: _localNameController.text.trim().isEmpty ? null : _localNameController.text.trim(),
        botanicalGenus: _botanicalGenusController.text.trim().isEmpty ? null : _botanicalGenusController.text.trim(),
        preparationMethod: _preparationController.text.trim().isEmpty ? null : _preparationController.text.trim(),
        geographicOrigin: _originController.text.trim().isEmpty ? null : _originController.text.trim(),
        photoUrl: photoUrl,
      );

      await Provider.of<HealthDataProvider>(context, listen: false)
          .addHerbalUse(userId, herbalUse);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Herbal medicine added successfully')),
        );
      }

      // Clear form
      _nameController.clear();
      _dosageController.clear();
      _frequencyController.clear();
      _purposeController.clear();
      _notesController.clear();
      _localNameController.clear();
      _botanicalGenusController.clear();
      _preparationController.clear();
      _originController.clear();
      setState(() => _productPhoto = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herbal Medicine'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Herbal Medicine',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Herbal Name',
                            prefixIcon: Icon(Icons.grass),
                            hintText: 'e.g., Ginger, Turmeric',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter herbal name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dosageController,
                          decoration: const InputDecoration(
                            labelText: 'Dosage',
                            prefixIcon: Icon(Icons.scale),
                            hintText: 'e.g., 1 teaspoon, 500mg',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter dosage';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _frequencyController,
                          decoration: const InputDecoration(
                            labelText: 'Frequency',
                            prefixIcon: Icon(Icons.schedule),
                            hintText: 'e.g., Once daily, 3 times daily',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter frequency';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _purposeController,
                          decoration: const InputDecoration(
                            labelText: 'Purpose',
                            prefixIcon: Icon(Icons.medical_services),
                            hintText: 'e.g., For digestion, Pain relief',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter purpose';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Scientific Identification',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Herbal compositions vary by geography and preparation. Provide local name and/or photo to help identify botanical genus.',
                                style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _localNameController,
                          decoration: const InputDecoration(
                            labelText: 'Local/Common Name (Optional)',
                            prefixIcon: Icon(Icons.language),
                            hintText: 'e.g., Dawa ya tumbo',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _botanicalGenusController,
                          decoration: const InputDecoration(
                            labelText: 'Botanical Genus (Optional)',
                            prefixIcon: Icon(Icons.science),
                            hintText: 'e.g., Zingiber',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _preparationController,
                          decoration: const InputDecoration(
                            labelText: 'Preparation (Optional)',
                            prefixIcon: Icon(Icons.blender),
                            hintText: 'e.g., Tea, Powder',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _originController,
                          decoration: const InputDecoration(
                            labelText: 'Origin (Optional)',
                            prefixIcon: Icon(Icons.location_on),
                            hintText: 'e.g., Kenya',
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _captureProductPhoto,
                          icon: Icon(_productPhoto == null ? Icons.camera_alt : Icons.check_circle, 
                            color: _productPhoto == null ? null : Colors.green),
                          label: Text(_productPhoto == null ? 'Add Product Photo' : 'Photo Added'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        if (_productPhoto != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Photo will help clinician identify the product',
                              style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                            ),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            prefixIcon: Icon(Icons.note),
                            hintText: 'Any additional information',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUploading ? null : _addHerbalUse,
                            child: _isUploading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Add Herbal Medicine'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Current Herbal Use',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<HealthDataProvider>(
                builder: (context, healthData, child) {
                  final herbalUses = healthData.herbalUses.where((h) => h.isActive).toList();
                  if (herbalUses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No herbal medicines added yet',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: herbalUses.length,
                    itemBuilder: (context, index) {
                      final herbal = herbalUses[index];
                      return _buildHerbalCard(context, herbal);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHerbalCard(BuildContext context, HerbalUse herbal) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.grass,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        herbal.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (herbal.localName != null)
                        Text(
                          'Local: ${herbal.localName}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                if (herbal.photoUrl != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.photo, size: 16, color: Colors.green.shade700),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${herbal.dosage} - ${herbal.frequency}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Purpose: ${herbal.purpose}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (herbal.botanicalGenus != null) ...[
              const SizedBox(height: 4),
              Text(
                'Genus: ${herbal.botanicalGenus}',
                style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontStyle: FontStyle.italic),
              ),
            ],
            if (herbal.preparationMethod != null || herbal.geographicOrigin != null) ...[
              const SizedBox(height: 4),
              Text(
                '${herbal.preparationMethod ?? ''} ${herbal.geographicOrigin != null ? '(${herbal.geographicOrigin})' : ''}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
            if (herbal.notes != null && herbal.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Notes: ${herbal.notes}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (herbal.id.isNotEmpty) Consumer<AuthProvider>(
              builder: (context, auth, _) => CommentSection(
                targetId: herbal.id,
                targetOwnerId: auth.currentUser?.id ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}