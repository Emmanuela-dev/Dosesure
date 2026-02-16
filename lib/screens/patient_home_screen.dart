import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/drug_interaction.dart';
import '../models/medication.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
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
              _showNotifications(context);
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
              _buildMedicationsFromProvider(),
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

  Widget _buildMedicationsFromProvider() {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        final medications = healthData.medications.where((m) => m.isActive).toList();
        
        if (medications.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No medications prescribed yet',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your doctor will prescribe medications for you',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        
        return Column(
          children: medications.map((med) => _buildMedicationCardFromModel(med)).toList(),
        );
      },
    );
  }

  Widget _buildMedicationCardFromModel(Medication med) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${med.dosage} - ${med.frequency}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Times: ${med.times.join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (med.prescribedByName != null && med.prescribedByName!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Prescribed by: Dr. ${med.prescribedByName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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

  Widget _buildHealthSummary() {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        final medications = healthData.medications.where((m) => m.isActive).toList();
        final graph = _buildInteractionGraph(medications);
        final interactionCount = graph.interactions.length;
        final hasHighRisk = graph.interactions.any((i) => 
          i.severity == InteractionSeverity.high || 
          i.severity == InteractionSeverity.contraindicated
        );
        final adherence = healthData.getAdherencePercentage();

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
                    _buildSummaryItem(
                      'Adherence', 
                      '${adherence.toStringAsFixed(0)}%', 
                      adherence >= 80 ? Colors.green : adherence >= 60 ? Colors.orange : Colors.red,
                      hasAlert: adherence < 60,
                    ),
                    _buildSummaryItem(
                      'Interactions', 
                      interactionCount > 0 ? '$interactionCount' : 'None', 
                      hasHighRisk ? Colors.red : (interactionCount > 0 ? Colors.orange : Colors.blue),
                      hasAlert: hasHighRisk,
                    ),
                    _buildSummaryItem(
                      'Side Effects', 
                      '${healthData.sideEffects.length}', 
                      healthData.sideEffects.length > 3 ? Colors.red : Colors.orange,
                      hasAlert: healthData.sideEffects.length > 3,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, {bool hasAlert = false}) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasAlert)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.priority_high,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
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
        final hasHighRisk = graph.interactions.any((i) => 
          i.severity == InteractionSeverity.high || 
          i.severity == InteractionSeverity.contraindicated
        );

        return Card(
          elevation: hasHighRisk ? 8 : 2,
          color: hasHighRisk ? Colors.red.shade50 : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: hasHighRisk ? BorderSide(color: Colors.red, width: 2) : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (hasHighRisk) ...[
                          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          'Drug Interactions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: hasHighRisk ? Colors.red.shade900 : null,
                          ),
                        ),
                      ],
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
                if (hasHighRisk) ...[
                  const SizedBox(height: 12),
                  _buildAlertBanner(graph.interactions),
                ],
                const SizedBox(height: 16),
                if (medications.isEmpty)
                  _buildEmptyState('No active medications', Icons.medication_outlined)
                else if (!hasInteractions)
                  _buildNoInteractionsState()
                else
                  Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: DrugInteractionGraphWidget(
                          graph: graph,
                          primaryColor: hasHighRisk ? Colors.red : Theme.of(context).primaryColor,
                          onDrugSelected: (drugId) {
                            // Handle drug selection if needed
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInteractionSummary(graph.interactions),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertBanner(List<DrugInteraction> interactions) {
    final highRiskCount = interactions.where((i) => 
      i.severity == InteractionSeverity.high || 
      i.severity == InteractionSeverity.contraindicated
    ).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.priority_high, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALERT: High-Risk Interaction Detected!',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$highRiskCount serious interaction${highRiskCount > 1 ? 's' : ''} found. Contact your doctor immediately.',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionSummary(List<DrugInteraction> interactions) {
    final severityCounts = {
      InteractionSeverity.low: 0,
      InteractionSeverity.moderate: 0,
      InteractionSeverity.high: 0,
      InteractionSeverity.contraindicated: 0,
    };

    for (var interaction in interactions) {
      severityCounts[interaction.severity] = (severityCounts[interaction.severity] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interaction Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (severityCounts[InteractionSeverity.contraindicated]! > 0)
                _buildSeverityBadge('Contraindicated', severityCounts[InteractionSeverity.contraindicated]!, Colors.red.shade900),
              if (severityCounts[InteractionSeverity.high]! > 0)
                _buildSeverityBadge('High', severityCounts[InteractionSeverity.high]!, Colors.red),
              if (severityCounts[InteractionSeverity.moderate]! > 0)
                _buildSeverityBadge('Moderate', severityCounts[InteractionSeverity.moderate]!, Colors.orange),
              if (severityCounts[InteractionSeverity.low]! > 0)
                _buildSeverityBadge('Low', severityCounts[InteractionSeverity.low]!, Colors.yellow.shade700),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityBadge(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
        ),
      ],
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
    } else if (name.contains('aluminium hydroxide') || name.contains('calcium carbonate') || 
               name.contains('magnesium hydroxide') || name.contains('sodium bicarbonate') || 
               name.contains('combination antacid') || name.contains('antacid')) {
      return 'Antacid';
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

  void _showNotifications(BuildContext context) {
    final healthData = Provider.of<HealthDataProvider>(context, listen: false);
    final medications = healthData.medications.where((m) => m.isActive).toList();
    final graph = _buildInteractionGraph(medications);
    final hasHighRisk = graph.interactions.any((i) => 
      i.severity == InteractionSeverity.high || 
      i.severity == InteractionSeverity.contraindicated
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              hasHighRisk ? Icons.warning : Icons.notifications,
              color: hasHighRisk ? Colors.red : Colors.blue,
            ),
            const SizedBox(width: 8),
            const Text('Notifications'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasHighRisk) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.priority_high, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'High-risk drug interaction detected!',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildNotificationItem(
                'Medication Reminder',
                'Time to take your medications',
                Icons.medication,
                Colors.blue,
              ),
              const Divider(),
              _buildNotificationItem(
                'Adherence Update',
                'Your adherence rate: ${healthData.getAdherencePercentage().toStringAsFixed(0)}%',
                Icons.check_circle,
                Colors.green,
              ),
              if (graph.interactions.isNotEmpty) ...[
                const Divider(),
                _buildNotificationItem(
                  'Drug Interactions',
                  '${graph.interactions.length} interaction${graph.interactions.length > 1 ? 's' : ''} detected',
                  Icons.warning,
                  hasHighRisk ? Colors.red : Colors.orange,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}