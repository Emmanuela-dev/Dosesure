
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../services/medication_expiry_service.dart';
import '../services/report_export_service.dart';
import '../models/user.dart';
import 'clinician_patients_screen.dart';
import 'clinician_reports_screen.dart';
import 'drug_interaction_screen.dart';
import 'patient_details_screen.dart';
import 'role_selection_screen.dart';
import 'add_patient_screen.dart';
import '../models/drug_interaction.dart';
import '../models/medication.dart';
import '../widgets/comment_section.dart';

class ClinicianDashboardScreen extends StatefulWidget {
  const ClinicianDashboardScreen({super.key});

  @override
  State<ClinicianDashboardScreen> createState() => _ClinicianDashboardScreenState();
}

class _ClinicianDashboardScreenState extends State<ClinicianDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardContent(),
    const DrugInteractionScreen(),
    const ClinicianPatientsScreen(),
    const ClinicianReportsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinician Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.person),
            onSelected: (value) async {
              if (value == 'logout') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await Provider.of<AuthProvider>(context, listen: false).signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      (route) => false,
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Interactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  final FirestoreService _firestoreService = FirestoreService();
  List<User> _patients = [];
  bool _isLoadingPatients = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser != null && currentUser.role == UserRole.clinician) {
      try {
        final patients = await _firestoreService.getPatientsForClinician(currentUser.id);
        
        // Check and deactivate expired medications for all patients
        for (final patient in patients) {
          await MedicationExpiryService().checkAndDeactivateExpiredMedications(patient.id);
        }
        
        if (mounted) {
          setState(() {
            _patients = patients;
            _isLoadingPatients = false;
          });
        }
      } catch (e) {
        debugPrint('Error loading patients: $e');
        if (mounted) {
          setState(() {
            _isLoadingPatients = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoadingPatients = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;
        final userName = (currentUser?.name != null && 
                          currentUser!.name.isNotEmpty && 
                          currentUser.name != 'User') 
            ? currentUser.name 
            : (currentUser?.email.split('@').first ?? 'Doctor');
        debugPrint('Dashboard - Current user name: ${currentUser?.name}, Displayed: $userName');
        
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $userName',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
            const SizedBox(height: 8),
            Text(
              'Monitor your patients\' medication adherence',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            _buildOverviewCards(context),
            const SizedBox(height: 32),
            _buildDrugInteractionPreview(context),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Patient List',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadPatients,
                  tooltip: 'Refresh patient list',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPatientList(context),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    if (_selectedPatient == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Select a patient to view overview',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        final patientId = _selectedPatient!.id;
        final medications = healthData.medications.where((m) => m.patientId == patientId && m.isActive).toList();
        final medIds = medications.map((m) => m.id).toSet();
        final sideEffects = healthData.sideEffects.where((s) => medIds.contains(s.medicationId)).toList();
        final herbalUses = healthData.herbalUses;
        final doseLogs = healthData.doseLogs.where((d) => medIds.contains(d.medicationId)).toList();
        final selfReportedAdherence = doseLogs.isEmpty ? 0.0 : (doseLogs.where((d) => d.taken).length / doseLogs.length) * 100;
        final verifiedAdherence = doseLogs.isEmpty ? 0.0 : (doseLogs.where((d) => d.taken && d.isVerified).length / doseLogs.length) * 100;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: (MediaQuery.of(context).size.width - 64) / 2,
              child: _buildOverviewCard('Medications', medications.length.toString(), Icons.medication, Colors.blue),
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width - 64) / 2,
              child: _buildOverviewCard('Side Effects', sideEffects.length.toString(), Icons.warning, Colors.orange),
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width - 64) / 2,
              child: _buildOverviewCard('Herbal Use', herbalUses.length.toString(), Icons.grass, Colors.green),
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width - 64) / 2,
              child: _buildOverviewCard('Adherence', '${selfReportedAdherence.toStringAsFixed(0)}%', Icons.check_circle, Colors.blueAccent),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (_selectedPatient == null) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 400,
                height: 500,
                child: _buildDetailListForCard(title, _selectedPatient!.id),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailListForCard(String title, String patientId) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        final meds = healthData.medications.where((m) => m.patientId == patientId).toList();
        final medIds = meds.map((m) => m.id).toSet();
        
        if (title == 'Side Effects') {
          final sideEffects = healthData.sideEffects.where((s) => medIds.contains(s.medicationId)).toList();
          if (sideEffects.isEmpty) return const Center(child: Text('No side effects reported.'));
          return ListView(
            shrinkWrap: true,
            children: sideEffects.map((effect) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(effect.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (effect.notes != null && effect.notes!.isNotEmpty)
                      Text('Notes: ${effect.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 4),
                    CommentSection(targetId: effect.id, targetOwnerId: patientId),
                  ],
                ),
              ),
            )).toList(),
          );
        } else if (title == 'Herbal Use') {
          final herbalUses = healthData.herbalUses;
          if (herbalUses.isEmpty) return const Center(child: Text('No herbal drug use reported.'));
          return ListView(
            shrinkWrap: true,
            children: herbalUses.map((herbal) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(herbal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${herbal.dosage} - ${herbal.frequency}'),
                    if (herbal.localName != null)
                      Text('Local: ${herbal.localName}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    if (herbal.botanicalGenus != null)
                      Text('Genus: ${herbal.botanicalGenus}', style: TextStyle(fontSize: 11, color: Colors.blue[700])),
                    if (herbal.notes != null && herbal.notes!.isNotEmpty)
                      Text('Notes: ${herbal.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 4),
                    CommentSection(targetId: herbal.id, targetOwnerId: patientId),
                  ],
                ),
              ),
            )).toList(),
          );
        } else if (title == 'Medications') {
          final activeMeds = meds.where((m) => m.isActive).toList();
          if (activeMeds.isEmpty) return const Center(child: Text('No active medications prescribed.'));
          return ListView(
            shrinkWrap: true,
            children: activeMeds.map((med) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(med.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${med.dosage} - ${med.frequency}'),
                    Text('Times: ${med.times.join(', ')}', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            )).toList(),
          );
        } else if (title == 'Adherence') {
          final doseLogs = healthData.doseLogs.where((d) => medIds.contains(d.medicationId)).toList();
          final takenLogs = doseLogs.where((log) => log.taken).toList();
          final verifiedLogs = doseLogs.where((log) => log.taken && log.isVerified).toList();
          final adherence = doseLogs.isEmpty ? 0.0 : (takenLogs.length / doseLogs.length) * 100;
          final verifiedAdherence = doseLogs.isEmpty ? 0.0 : (verifiedLogs.length / doseLogs.length) * 100;
          
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adherence: ${adherence.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Total doses: ${doseLogs.length}'),
                Text('Confirmed doses: ${takenLogs.length}'),
                Text('Verified doses: ${verifiedLogs.length}'),
                const SizedBox(height: 8),
                const Text(
                  'Verified doses have photo proof',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildDrugInteractionPreview(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        final medications = healthData.medications;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medication, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Drug Interactions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Check for Interactions'),
                  onPressed: () {
                    final List<String> interactions = [];
                    for (int i = 0; i < medications.length; i++) {
                      for (int j = i + 1; j < medications.length; j++) {
                        final interaction = _checkInteraction(medications[i], medications[j]);
                        if (interaction != null) {
                          interactions.add('Drug ${medications[i].name} interacts with Drug ${medications[j].name}');
                        }
                      }
                    }
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Drug Interactions'),
                        content: interactions.isEmpty
                            ? const Text('No interactions detected among prescribed drugs.')
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: interactions.map((e) => Text(e)).toList(),
                              ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getAntacidType(String name) {
    if (name.contains('aluminium hydroxide')) {
      return 'Aluminium Hydroxide';
    } else if (name.contains('magnesium hydroxide')) {
      return 'Magnesium Hydroxide';
    } else if (name.contains('calcium carbonate')) {
      return 'Calcium Carbonate';
    } else if (name.contains('sodium bicarbonate')) {
      return 'Sodium Bicarbonate';
    } else if (name.contains('combination antacid')) {
      return 'Combination Antacid';
    }
    return 'Other';
  }

  DrugInteraction? _checkInteraction(Medication drug1, Medication drug2) {
    final name1 = drug1.name.toLowerCase();
    final name2 = drug2.name.toLowerCase();

    // Antacid + Antacid (example interaction)
    if (_isAntacid(name1) && _isAntacid(name2) && name1 != name2) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description: 'Concurrent use of multiple antacids may increase the risk of side effects such as constipation or diarrhea.',
        severity: InteractionSeverity.moderate,
        symptoms: ['Constipation', 'Diarrhea', 'Stomach cramps'],
        recommendation: 'Avoid using multiple antacids together unless prescribed. Monitor for gastrointestinal symptoms.',
      );
    }

    // Antacids + Iron supplements
    if ((_isAntacid(name1) && name2.contains('iron')) ||
        (name2.contains('iron') && _isAntacid(name1)) ||
        (name1.contains('ferrous') && _isAntacid(name2)) ||
        (name2.contains('ferrous') && _isAntacid(name1))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description: 'Antacids significantly reduce iron absorption by binding to it in the gut.',
        severity: InteractionSeverity.moderate,
        symptoms: ['Reduced iron absorption', 'Anemia worsening', 'Fatigue'],
        recommendation: 'Take iron supplements 2 hours before or after antacids.',
      );
    }

    return null;
  }

  bool _isAntacid(String drugName) {
    final name = drugName.toLowerCase();
    return name.contains('aluminium hydroxide') ||
        name.contains('magnesium hydroxide') ||
        name.contains('calcium carbonate') ||
        name.contains('sodium bicarbonate') ||
        name.contains('combination antacid') ||
        name.contains('antacid');
  }

  bool _isAntibiotic(String drugName) {
    final name = drugName.toLowerCase();
    return name.contains('amoxicillin') ||
        name.contains('azithromycin') ||
        name.contains('doxycycline') ||
        name.contains('cephalexin') ||
        name.contains('antibiotic');
  }

  User? _selectedPatient;

  Future<void> _generatePatientReport(BuildContext context, User patient) async {
    try {
      final healthData = Provider.of<HealthDataProvider>(context, listen: false);
      final exportService = ReportExportService();
      
      final medications = healthData.medications.where((m) => m.patientId == patient.id).toList();
      final doseLogs = healthData.doseLogs;
      final sideEffects = healthData.sideEffects;
      
      final file = await exportService.generatePdfReport(
        patientName: patient.name,
        patientId: patient.id,
        medications: medications,
        doseLogs: doseLogs,
        sideEffects: sideEffects,
        selfReportedAdherence: healthData.getAdherencePercentage(),
        verifiedAdherence: healthData.getVerifiedAdherencePercentage(),
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );
      
      await exportService.shareReport(file, 'PDF');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient report generated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildPatientList(BuildContext context) {
    if (_isLoadingPatients) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<User>(
                    isExpanded: true,
                    value: _selectedPatient,
                    hint: const Text('Select a patient'),
                    items: _patients.map((patient) {
                      return DropdownMenuItem<User>(
                        value: patient,
                        child: Text(patient.name),
                      );
                    }).toList(),
                    onChanged: (user) {
                      setState(() {
                        _selectedPatient = user;
                        if (user != null) {
                          Provider.of<HealthDataProvider>(context, listen: false)
                              .initializeForUser(user.id);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add New'),
                  onPressed: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final currentUser = authProvider.currentUser;
                    if (currentUser == null) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPatientScreen(
                          clinicianId: currentUser.id,
                          onPatientAdded: (user) async {
                            await _loadPatients();
                            setState(() {
                              _selectedPatient = user;
                            });
                            if (mounted) {
                              Provider.of<HealthDataProvider>(context, listen: false)
                                  .initializeForUser(user.id);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedPatient != null)
              _buildPatientCard(context, _selectedPatient!),
            if (_selectedPatient != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _generatePatientReport(context, _selectedPatient!),
                  icon: const Icon(Icons.file_download),
                  label: const Text('Generate Patient Report'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            if (_patients.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'No patients yet. Add a new patient to get started.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, User patient) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        // Filter data for this patient - only active medications
        final meds = healthData.medications.where((m) => m.patientId == patient.id && m.isActive).toList();
        final herbal = healthData.herbalUses;
        final doseLogs = healthData.doseLogs;
        final adherence = doseLogs.isEmpty ? 0.0 :
          (doseLogs.where((log) => log.taken).length / doseLogs.length) * 100;
        // Medication pattern: show times/frequency summary
        String pattern = meds.isNotEmpty
          ? meds.map((m) => '${m.name}: ${m.frequency}').join(', ')
          : 'No active medications';
        // Herbal use summary
        String herbalSummary = herbal.isNotEmpty
          ? herbal.map((h) => h.name).join(', ')
          : 'None';
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                patient.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(patient.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.email),
                const SizedBox(height: 4),
                Text('Adherence: ${adherence.toStringAsFixed(0)}%'),
                Text('Pattern: $pattern'),
                Text('Herbal drugs: $herbalSummary'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientDetailsScreen(patient: patient),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
