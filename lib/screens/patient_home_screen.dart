import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/drug_interaction.dart';
import '../models/medication.dart';
import '../providers/health_data_provider.dart';
import '../widgets/drug_interaction_graph.dart';
import 'medication_list_screen.dart';
import 'side_effects_screen.dart';
import 'herbal_use_screen.dart';
import 'history_screen.dart';
import 'drug_interaction_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final List<Map<String, dynamic>> _todayMedications = [
    {
      'name': 'Aspirin',
      'dosage': '100mg',
      'time': '08:00',
      'taken': false,
    },
    {
      'name': 'Metformin',
      'dosage': '500mg',
      'time': '12:00',
      'taken': true,
    },
    {
      'name': 'Lisinopril',
      'dosage': '10mg',
      'time': '18:00',
      'taken': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('DoseSure'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to reminders
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good ${DateTime.now().hour < 12 ? 'morning' : DateTime.now().hour < 17 ? 'afternoon' : 'evening'}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                today,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              _buildQuickActions(),
              const SizedBox(height: 32),
              Text(
                'Today\'s Medications',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._todayMedications.map((med) => _buildMedicationCard(med)),
              const SizedBox(height: 32),
              _buildHealthSummary(),
              const SizedBox(height: 32),
              _buildDrugInteractionSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MedicationListScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionCard(
          'Log Dose',
          Icons.check_circle,
          Colors.green,
          () {
            // TODO: Navigate to log dose
          },
        ),
        _buildActionCard(
          'Medications',
          Icons.list,
          Colors.blue,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicationListScreen()),
            );
          },
        ),
        _buildActionCard(
          'Side Effects',
          Icons.warning,
          Colors.orange,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SideEffectsScreen()),
            );
          },
        ),
        _buildActionCard(
          'Herbal Use',
          Icons.grass,
          Colors.purple,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HerbalUseScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> med) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.medication,
              color: Theme.of(context).primaryColor,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med['name'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${med['dosage']} at ${med['time']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Checkbox(
              value: med['taken'],
              onChanged: (value) {
                setState(() {
                  med['taken'] = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Adherence', '85%', Colors.green),
                _buildSummaryItem('Interactions', 'None', Colors.blue),
                _buildSummaryItem('Side Effects', '2', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDrugInteractionSection() {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        final medications = healthData.medications.where((m) => m.isActive).toList();
        final graph = _buildInteractionGraph(medications);
        final hasInteractions = graph.interactions.isNotEmpty;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Drug Interactions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DrugInteractionScreen()),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (medications.isEmpty)
                  _buildEmptyState('No active medications', Icons.medication_outlined)
                else if (!hasInteractions)
                  _buildNoInteractionsState()
                else
                  SizedBox(
                    height: 300,
                    child: DrugInteractionGraphWidget(
                      graph: graph,
                      primaryColor: Theme.of(context).primaryColor,
                      onDrugSelected: (drugId) {
                        // Handle drug selection if needed
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  DrugInteractionGraph _buildInteractionGraph(List<Medication> medications) {
    // Create drug nodes from medications
    final nodes = medications.map((med) {
      final category = _getDrugCategory(med.name);
      return DrugNode(
        id: med.id,
        name: med.name,
        category: category,
      );
    }).toList();

    // Create interactions based on known drug interactions
    final interactions = <DrugInteraction>[];

    for (int i = 0; i < medications.length; i++) {
      for (int j = i + 1; j < medications.length; j++) {
        final interaction = _checkInteraction(medications[i], medications[j]);
        if (interaction != null) {
          interactions.add(interaction);
        }
      }
    }

    return DrugInteractionGraph(nodes: nodes, interactions: interactions);
  }

  String _getDrugCategory(String drugName) {
    final name = drugName.toLowerCase();
    if (name.contains('aspirin') || name.contains('warfarin') || name.contains('heparin')) {
      return 'Anticoagulant';
    } else if (name.contains('metformin') || name.contains('glipizide') || name.contains('insulin')) {
      return 'Antidiabetic';
    } else if (name.contains('lisinopril') || name.contains('amlodipine') || name.contains('atenolol')) {
      return 'Cardiovascular';
    } else if (name.contains('omeprazole') || name.contains('pantoprazole')) {
      return 'Proton Pump Inhibitor';
    } else if (name.contains('acetaminophen') || name.contains('ibuprofen')) {
      return 'Analgesic';
    } else if (name.contains('atorvastatin') || name.contains('simvastatin')) {
      return 'Statin';
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
        recommendation: 'Avoid combination unless specifically prescribed. Monitor INR closely.',
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

    // Metformin + Alcohol (note: not typically a "medication" but for demonstration)
    if ((name1.contains('metformin') && name2.contains('alcohol')) ||
        (name1.contains('alcohol') && name2.contains('metformin'))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description: 'Alcohol increases the risk of lactic acidosis with metformin.',
        severity: InteractionSeverity.high,
        symptoms: ['Lactic acidosis', 'Nausea', 'Abdominal pain', 'Difficulty breathing'],
        recommendation: 'Limit alcohol consumption while taking metformin.',
      );
    }

    // Simvastatin + Grapefruit
    if ((name1.contains('simvastatin') && name2.contains('grapefruit')) ||
        (name1.contains('grapefruit') && name2.contains('simvastatin'))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description: 'Grapefruit inhibits CYP3A4 enzyme, increasing statin levels and risk of muscle toxicity.',
        severity: InteractionSeverity.high,
        symptoms: ['Muscle pain', 'Dark urine', 'Fatigue', 'Liver problems'],
        recommendation: 'Avoid grapefruit and grapefruit juice while on simvastatin.',
      );
    }

    return null;
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoInteractionsState() {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 48, color: Colors.green),
          const SizedBox(height: 8),
          Text(
            'No drug interactions detected',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your medications are safe to take together',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}