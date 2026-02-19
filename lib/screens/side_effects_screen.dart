import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
import '../models/side_effect.dart';
import '../models/medication.dart';
import '../widgets/comment_section.dart';

class SideEffectsScreen extends StatefulWidget {
  const SideEffectsScreen({super.key});

  @override
  State<SideEffectsScreen> createState() => _SideEffectsScreenState();
}

class _SideEffectsScreenState extends State<SideEffectsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedMedicationId;
  int _severity = 1;

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _reportSideEffect() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMedicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a medication')),
      );
      return;
    }

    final sideEffect = SideEffect(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: _selectedMedicationId!,
      description: _descriptionController.text.trim(),
      severity: _severity,
      reportedDate: DateTime.now(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<HealthDataProvider>(context, listen: false)
        .addSideEffect(authProvider.currentUser!.id, sideEffect);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Side effect reported successfully')),
    );

    // Clear form
    _descriptionController.clear();
    _notesController.clear();
    setState(() {
      _selectedMedicationId = null;
      _severity = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Side Effects'),
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
                          'Report a Side Effect',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<HealthDataProvider>(
                          builder: (context, healthData, child) {
                            final medications = healthData.medications;
                            return DropdownButtonFormField<String>(
                              value: _selectedMedicationId,
                              decoration: const InputDecoration(
                                labelText: 'Related Medication',
                                prefixIcon: Icon(Icons.medication),
                              ),
                              items: medications.map((med) {
                                return DropdownMenuItem(
                                  value: med.id,
                                  child: Text('${med.name} (${med.dosage})'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMedicationId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a medication';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.description),
                            hintText: 'Describe the side effect',
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please describe the side effect';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Severity Level',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Mild'),
                            Expanded(
                              child: Slider(
                                value: _severity.toDouble(),
                                min: 1,
                                max: 5,
                                divisions: 4,
                                label: _severity.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _severity = value.toInt();
                                  });
                                },
                              ),
                            ),
                            const Text('Severe'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Additional Notes (Optional)',
                            prefixIcon: Icon(Icons.note),
                            hintText: 'Any additional information',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _reportSideEffect,
                            child: const Text('Report Side Effect'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Recent Side Effects',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<HealthDataProvider>(
                builder: (context, healthData, child) {
                  final sideEffects = healthData.sideEffects;
                  if (sideEffects.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No side effects reported yet',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sideEffects.length,
                    itemBuilder: (context, index) {
                      final effect = sideEffects[index];
                      final medication = healthData.medications
                          .firstWhere((med) => med.id == effect.medicationId);
                      return _buildSideEffectCard(context, effect, medication);
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

  Widget _buildSideEffectCard(BuildContext context, SideEffect effect, Medication medication) {
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
                  Icons.warning,
                  color: _getSeverityColor(effect.severity),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    medication.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${effect.reportedDate.day}/${effect.reportedDate.month}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              effect.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (effect.notes != null && effect.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Notes: ${effect.notes}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Doctor/clinician comments section
            if (effect.id.isNotEmpty)
              CommentSection(targetId: effect.id),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}