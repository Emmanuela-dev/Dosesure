import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
import '../models/side_effect.dart';
import '../models/medication.dart';
import '../services/symptom_triage_service.dart';
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

    final description = _descriptionController.text.trim();
    final triageLevel = SymptomTriage.classifySymptom(description);

    // Show triage-based dialog
    if (triageLevel == TriageLevel.emergency) {
      await _showEmergencyDialog();
      return; // Don't just log, require emergency action
    } else if (triageLevel == TriageLevel.urgent) {
      await _showUrgentDialog();
    }

    final sideEffect = SideEffect(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: _selectedMedicationId!,
      description: description,
      severity: _severity,
      reportedDate: DateTime.now(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      triageLevel: triageLevel.name,
      requiresEmergencyAction: triageLevel == TriageLevel.emergency,
      clinicianNotified: triageLevel == TriageLevel.urgent || triageLevel == TriageLevel.emergency,
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<HealthDataProvider>(context, listen: false)
        .addSideEffect(authProvider.currentUser!.id, sideEffect);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            triageLevel == TriageLevel.routine
                ? 'Side effect reported to your healthcare provider'
                : 'Report logged. Follow the guidance provided.',
          ),
          backgroundColor: triageLevel == TriageLevel.routine ? Colors.green : Colors.orange,
        ),
      );
    }

    // Clear form
    _descriptionController.clear();
    _notesController.clear();
    setState(() {
      _selectedMedicationId = null;
      _severity = 1;
    });
  }

  Future<void> _showEmergencyDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red.shade700, size: 32),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'MEDICAL EMERGENCY',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SymptomTriage.getEmergencyMessage(),
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300, width: 2),
              ),
              child: const Text(
                'This app does NOT replace emergency medical services. Your clinician will NOT be notified in real-time.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              final uri = Uri(scheme: 'tel', path: '911');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.phone),
            label: const Text('CALL 911'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I understand'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUrgentDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.orange.shade50,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 8),
            const Text('Urgent Medical Attention'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SymptomTriage.getUrgentMessage(),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Your healthcare provider will be notified, but may not see this immediately. Contact them directly.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I understand'),
          ),
        ],
      ),
    );
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.emergency, color: Colors.red.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Emergency Symptoms',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'If experiencing: difficulty breathing, chest pain, severe allergic reaction, seizures, loss of consciousness, or severe bleeding - CALL 911 IMMEDIATELY.',
                                style: TextStyle(fontSize: 11, color: Colors.red.shade900),
                              ),
                            ],
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
    final isEmergency = effect.triageLevel == 'emergency';
    final isUrgent = effect.triageLevel == 'urgent';
    
    return Card(
      elevation: isEmergency || isUrgent ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isEmergency 
            ? BorderSide(color: Colors.red, width: 2)
            : isUrgent
                ? BorderSide(color: Colors.orange, width: 2)
                : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEmergency ? Icons.emergency : Icons.warning,
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
                if (isEmergency || isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isEmergency ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isEmergency ? 'EMERGENCY' : 'URGENT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
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
            if (effect.id.isNotEmpty) Consumer<AuthProvider>(
              builder: (context, auth, _) => CommentSection(
                targetId: effect.id,
                targetOwnerId: auth.currentUser?.id ?? '',
              ),
            ),
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