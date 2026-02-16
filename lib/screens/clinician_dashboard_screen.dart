import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/user.dart';
import 'clinician_patients_screen.dart';
import 'clinician_reports_screen.dart';
import 'drug_interaction_screen.dart';
import 'patient_details_screen.dart';
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
                    Navigator.of(context).pushReplacementNamed('/login');
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
    // Always show sample antacid medications for demo
    final medications = [
      Medication(
        id: '1',
        name: 'Aluminium Hydroxide',
        dosage: '400mg',
        frequency: 'Three times daily',
        times: ['08:00', '14:00', '20:00'],
        instructions: 'Take after meals',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Medication(
        id: '2',
        name: 'Calcium Carbonate',
        dosage: '500mg',
        frequency: 'As needed',
        times: ['12:00'],
        instructions: 'Take for heartburn relief',
        startDate: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Medication(
        id: '3',
        name: 'Magnesium Hydroxide',
        dosage: '400mg',
        frequency: 'Twice daily',
        times: ['08:00', '20:00'],
        instructions: 'Take with water',
        startDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Medication(
        id: '4',
        name: 'Sodium Bicarbonate',
        dosage: '650mg',
        frequency: 'As needed',
        times: ['12:00'],
        instructions: 'Dissolve in water before taking',
        startDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Medication(
        id: '5',
        name: 'Combination Antacid',
        dosage: '1 tablet',
        frequency: 'Four times daily',
        times: ['08:00', '12:00', '18:00', '22:00'],
        instructions: 'Chew thoroughly before swallowing',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

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
                    'Drug Interactions (Sample Antacids)',
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
  }

  String _getDrugCategory(String drugName) {
    final name = drugName.toLowerCase();
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
    // Navigate to patient details screen to view/add prescriptions
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailsScreen(patient: patient),
            ),
          );
        },
      ),
    );
  }
}
