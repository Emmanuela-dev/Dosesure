import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
import '../models/herbal_use.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _purposeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addHerbalUse() async {
    if (!_formKey.currentState!.validate()) return;

    final herbalUse = HerbalUse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _frequencyController.text.trim(),
      purpose: _purposeController.text.trim(),
      startDate: DateTime.now(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<HealthDataProvider>(context, listen: false)
        .addHerbalUse(authProvider.currentUser!.id, herbalUse);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Herbal use added successfully')),
    );

    // Clear form
    _nameController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _purposeController.clear();
    _notesController.clear();
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
                            onPressed: _addHerbalUse,
                            child: const Text('Add Herbal Medicine'),
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
                  child: Text(
                    herbal.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    // TODO: Edit herbal use
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    // TODO: Delete herbal use
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${herbal.dosage} - ${herbal.frequency}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 2),
            Text(
              'Purpose: ${herbal.purpose}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (herbal.notes != null && herbal.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Notes: ${herbal.notes}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}