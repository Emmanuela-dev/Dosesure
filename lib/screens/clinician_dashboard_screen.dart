import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/user.dart';
import 'clinician_patients_screen.dart';
import 'clinician_reports_screen.dart';
import 'drug_interaction_screen.dart';
import '../models/drug_interaction.dart';
import '../widgets/drug_interaction_graph.dart';
import '../models/medication.dart';

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
              // TODO: Navigate to alerts
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to profile
            },
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
            : (currentUser?.email?.split('@').first ?? 'Doctor');
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
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        final medications = healthData.medications.length;
        final sideEffects = healthData.sideEffects.length;
        final herbalUses = healthData.herbalUses.length;
        final adherence = healthData.getAdherencePercentage().toStringAsFixed(0);

        return Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Medications',
                medications.toString(),
                Icons.medication,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOverviewCard(
                'Side Effects',
                sideEffects.toString(),
                Icons.warning,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOverviewCard(
                'Herbal Use',
                herbalUses.toString(),
                Icons.grass,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOverviewCard(
                'Adherence',
                '$adherence%',
                Icons.check_circle,
                Colors.purple,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrugInteractionPreview(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        var medications = healthData.medications.where((m) => m.isActive).toList();

        // Use sample medications if none exist (for demo purposes)
        if (medications.isEmpty) {
          medications = [
            Medication(
              id: '1',
              name: 'Aspirin',
              dosage: '100mg',
              frequency: 'Once daily',
              times: ['08:00'],
              instructions: 'Take with food',
              startDate: DateTime.now().subtract(const Duration(days: 30)),
            ),
            Medication(
              id: '2',
              name: 'Lisinopril',
              dosage: '10mg',
              frequency: 'Once daily',
              times: ['08:00'],
              instructions: 'Take in the morning',
              startDate: DateTime.now().subtract(const Duration(days: 30)),
            ),
            Medication(
              id: '3',
              name: 'Metformin',
              dosage: '500mg',
              frequency: 'Twice daily',
              times: ['08:00', '20:00'],
              instructions: 'Take with meals',
              startDate: DateTime.now().subtract(const Duration(days: 30)),
            ),
            Medication(
              id: '4',
              name: 'Tums',
              dosage: '500mg',
              frequency: 'As needed',
              times: ['12:00'],
              instructions: 'Take after meals for heartburn',
              startDate: DateTime.now().subtract(const Duration(days: 15)),
            ),
            Medication(
              id: '5',
              name: 'Ciprofloxacin',
              dosage: '500mg',
              frequency: 'Twice daily',
              times: ['08:00', '20:00'],
              instructions: 'Complete full course',
              startDate: DateTime.now().subtract(const Duration(days: 7)),
            ),
          ];
        }

        // Build graph data
        final nodes = medications.map((med) => DrugNode(
              id: med.id,
              name: med.name,
              category: _getDrugCategory(med.name),
            )).toList();

        final interactions = <DrugInteraction>[];
        for (int i = 0; i < medications.length; i++) {
          for (int j = i + 1; j < medications.length; j++) {
            final interaction = _checkInteraction(medications[i], medications[j]);
            if (interaction != null) {
              interactions.add(interaction);
            }
          }
        }

        final graph = DrugInteractionGraph(nodes: nodes, interactions: interactions);
        final hasHighRisk = interactions.any(
            (i) => i.severity == InteractionSeverity.high || i.severity == InteractionSeverity.contraindicated);

        return Card(
          elevation: 4,
          color: hasHighRisk ? Colors.red.shade50 : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasHighRisk ? Icons.warning : Icons.medication,
                      color: hasHighRisk ? Colors.red : Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Drug Interactions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: DrugInteractionGraphWidget(
                    graph: graph,
                    primaryColor: Theme.of(context).primaryColor,
                  ),
                ),
                if (hasHighRisk) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.priority_high, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${interactions.where((i) => i.severity == InteractionSeverity.high || i.severity == InteractionSeverity.contraindicated).length} high-risk interactions detected',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDrugCategory(String drugName) {
    final name = drugName.toLowerCase();
    if (name.contains('aspirin') || name.contains('warfarin') || name.contains('heparin')) {
      return 'Anticoagulant';
    } else if (name.contains('metformin') || name.contains('glipizide') || name.contains('insulin')) {
      return 'Antidiabetic';
    } else if (name.contains('lisinopril') || name.contains('amlodipine') || name.contains('atenolol')) {
      return 'Cardiovascular';
    } else if (name.contains('omeprazole') || name.contains('pantoprazole') || name.contains('tums') || name.contains('maalox')) {
      return 'Antacid/GI';
    } else if (name.contains('acetaminophen') || name.contains('ibuprofen')) {
      return 'Analgesic';
    } else if (name.contains('atorvastatin') || name.contains('simvastatin')) {
      return 'Statin';
    } else if (name.contains('ciprofloxacin') || name.contains('amoxicillin') || name.contains('azithromycin')) {
      return 'Antibiotic';
    }
    return 'Other';
  }

  DrugInteraction? _checkInteraction(Medication drug1, Medication drug2) {
    final name1 = drug1.name.toLowerCase();
    final name2 = drug2.name.toLowerCase();

    // Aspirin + Warfarin
    if ((name1.contains('aspirin') && name2.contains('warfarin')) ||
        (name1.contains('warfarin') && name2.contains('aspirin'))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description: 'Increased risk of bleeding. Aspirin enhances the anticoagulant effect of warfarin.',
        severity: InteractionSeverity.high,
        symptoms: ['Easy bruising', 'Nosebleeds', 'Black stools', 'Prolonged bleeding'],
        recommendation: 'Avoid combination unless specifically prescribed by a physician. Monitor INR closely.',
      );
    }

    // Lisinopril + Potassium
    if ((name1.contains('lisinopril') && name2.contains('potassium')) ||
        (name1.contains('potassium') && name2.contains('lisinopril'))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description: 'ACE inhibitors can cause potassium retention, leading to hyperkalemia.',
        severity: InteractionSeverity.moderate,
        symptoms: ['Muscle weakness', 'Irregular heartbeat', 'Fatigue'],
        recommendation: 'Monitor potassium levels regularly. Limit potassium-rich foods.',
      );
    }

    // Ibuprofen + Aspirin
    if ((name1.contains('ibuprofen') && name2.contains('aspirin')) ||
        (name1.contains('aspirin') && name2.contains('ibuprofen'))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description: 'Ibuprofen may reduce the cardioprotective effects of aspirin.',
        severity: InteractionSeverity.moderate,
        symptoms: ['Reduced aspirin effectiveness', 'Increased cardiovascular risk'],
        recommendation: 'Take aspirin 30 minutes before ibuprofen, or use an alternative pain reliever.',
      );
    }

    // Amlodipine + Simvastatin
    if ((name1.contains('amlodipine') && name2.contains('simvastatin')) ||
        (name1.contains('simvastatin') && name2.contains('amlodipine'))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description: 'Amlodipine inhibits CYP3A4, increasing simvastatin concentration.',
        severity: InteractionSeverity.contraindicated,
        symptoms: ['Severe muscle pain', 'Weakness', 'Dark urine', 'Kidney damage'],
        recommendation: 'Limit simvastatin to 20mg daily when used with amlodipine.',
      );
    }

    // Antacids + Antibiotics (e.g., Ciprofloxacin)
    if ((_isAntacid(name1) && _isAntibiotic(name2)) ||
        (_isAntacid(name2) && _isAntibiotic(name1))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description: 'Antacids reduce the absorption of antibiotics, making them less effective.',
        severity: InteractionSeverity.moderate,
        symptoms: ['Reduced antibiotic effectiveness', 'Treatment failure', 'Recurrent infection'],
        recommendation: 'Take antibiotic at least 2 hours before or 6 hours after antacids.',
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
    return name.contains('tums') ||
        name.contains('maalox') ||
        name.contains('pepcid') ||
        name.contains('zantac') ||
        name.contains('prilosec') ||
        name.contains('omeprazole') ||
        name.contains('pantoprazole') ||
        name.contains('lansoprazole') ||
        name.contains('antacid') ||
        name.contains('gaviscon');
  }

  bool _isAntibiotic(String drugName) {
    final name = drugName.toLowerCase();
    return name.contains('ciprofloxacin') ||
        name.contains('amoxicillin') ||
        name.contains('azithromycin') ||
        name.contains('doxycycline') ||
        name.contains('cephalexin') ||
        name.contains('antibiotic');
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

    if (_patients.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No patients yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Patients who select you as their doctor will appear here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _patients.map((patient) => _buildPatientCard(context, patient)).toList(),
    );
  }

  Widget _buildPatientCard(BuildContext context, User patient) {
    // TODO: In a real app, fetch actual patient health data
    // For now, showing patient info without health metrics
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
        subtitle: Text(patient.email),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to patient details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('View details for ${patient.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
