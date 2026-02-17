import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/medication.dart';
import '../models/drug.dart';
import '../models/user.dart';

class PrescribeMedicationScreen extends StatefulWidget {
  final User patient;

  const PrescribeMedicationScreen({super.key, required this.patient});

  @override
  State<PrescribeMedicationScreen> createState() => _PrescribeMedicationScreenState();
}

class _PrescribeMedicationScreenState extends State<PrescribeMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _instructionsController = TextEditingController();
  final List<String> _times = [];
  bool _isSaving = false;
  bool _isLoadingDrugs = true;
  Drug? _selectedDrug;

  @override
  void initState() {
    super.initState();
    // Load drugs when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDrugs();
    });
  }

  Future<void> _loadDrugs() async {
    setState(() => _isLoadingDrugs = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Always try to initialize and load drugs
      await authProvider.initializeDefaultDrugs();
      debugPrint('PrescribeMedicationScreen - Loaded ${authProvider.drugs.length} drugs');
    } catch (e) {
      debugPrint('PrescribeMedicationScreen - Error loading drugs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading drugs: ${e.toString().split('\n').first}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadDrugs,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDrugs = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _addTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select medication time',
    );

    if (picked != null) {
      // Format as HH:MM (24-hour format)
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final timeString = '$hour:$minute';
      
      setState(() {
        _times.add(timeString);
        // Sort times chronologically
        _times.sort();
      });
    }
  }

  void _removeTime(int index) {
    setState(() {
      _times.removeAt(index);
    });
  }

  Future<void> _prescribeMedication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one time')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final doctor = authProvider.currentUser!;

    // Get medication name from selected drug or custom input
    String medicationName;
    if (_selectedDrug != null) {
      medicationName = _selectedDrug!.name;
    } else {
      medicationName = _nameController.text.trim();
    }

    final medication = Medication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: medicationName,
      dosage: _dosageController.text.trim(),
      frequency: _frequencyController.text.trim(),
      times: _times,
      instructions: _instructionsController.text.trim(),
      startDate: DateTime.now(),
      prescribedBy: doctor.id,
      prescribedByName: doctor.name,
      patientId: widget.patient.id,
    );

    try {
      // Add medication directly to Firestore for the patient
      final firestoreService = FirestoreService();
      await firestoreService.addMedication(widget.patient.id, medication);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${medication.name} prescribed to ${widget.patient.name}! Reminders set for: ${_times.join(", ")}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error prescribing medication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescribe for ${widget.patient.name}'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _prescribeMedication,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient info card
                Card(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            widget.patient.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patient.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.patient.email,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Medication Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Drug selection dropdown
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (_isLoadingDrugs) {
                      return const InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Select Drug',
                          prefixIcon: Icon(Icons.medication),
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Loading drugs...'),
                          ],
                        ),
                      );
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<Drug>(
                          value: _selectedDrug,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Select Drug',
                            prefixIcon: const Icon(Icons.medication),
                            border: const OutlineInputBorder(),
                            hintText: authProvider.drugs.isEmpty 
                                ? 'No drugs available' 
                                : 'Choose from available drugs',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _loadDrugs,
                              tooltip: 'Refresh drug list',
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<Drug>(
                              value: null,
                              child: Text('Enter custom medication name'),
                            ),
                            ...authProvider.drugs.map((drug) {
                              return DropdownMenuItem<Drug>(
                                value: drug,
                                child: Text(drug.name),
                              );
                            }),
                          ],
                          onChanged: (drug) {
                            setState(() {
                              _selectedDrug = drug;
                              if (drug != null) {
                                _nameController.text = drug.name;
                              } else {
                                _nameController.clear();
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null && _nameController.text.isEmpty) {
                              return 'Please select a drug or enter a custom name';
                            }
                            return null;
                          },
                        ),
                        if (authProvider.drugs.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${authProvider.drugs.length} drugs available',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        if (_selectedDrug != null && _selectedDrug!.description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedDrug!.description!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Custom medication name (shown when no drug is selected)
                if (_selectedDrug == null)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name',
                      prefixIcon: Icon(Icons.medication),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter medication name';
                      }
                      return null;
                    },
                  ),
                if (_selectedDrug == null) const SizedBox(height: 16),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    prefixIcon: Icon(Icons.scale),
                    hintText: 'e.g., 100mg, 5ml',
                    border: OutlineInputBorder(),
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
                    hintText: 'e.g., Once daily, Twice daily',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter frequency';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Medication Times',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ElevatedButton.icon(
                      onPressed: _addTime,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Time'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_times.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'No times added yet. Tap "Add Time" to set medication schedule.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _times.asMap().entries.map((entry) {
                      return Chip(
                        avatar: const Icon(Icons.access_time, size: 18),
                        label: Text(entry.value),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeTime(entry.key),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Instructions (Optional)',
                    prefixIcon: Icon(Icons.info),
                    hintText: 'e.g., Take with food, Avoid alcohol',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _prescribeMedication,
                    icon: _isSaving 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Prescribing...' : 'Prescribe Medication'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
