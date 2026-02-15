import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drug_interaction.dart';
import '../models/medication.dart';
import '../providers/health_data_provider.dart';
import '../widgets/drug_interaction_graph.dart';

class DrugInteractionScreen extends StatefulWidget {
  const DrugInteractionScreen({super.key});

  @override
  State<DrugInteractionScreen> createState() => _DrugInteractionScreenState();
}

class _DrugInteractionScreenState extends State<DrugInteractionScreen> {
  DrugInteractionGraph? _graph;

  @override
  void initState() {
    super.initState();
    _buildGraph();
  }

  void _buildGraph() {
    final healthData = context.read<HealthDataProvider>();
    final medications = healthData.medications.where((m) => m.isActive).toList();

    // Create drug nodes from medications
    final nodes = medications.map((med) {
      final category = _getDrugCategory(med.name);
      return DrugNode(
        id: med.id,
        name: med.name,
        category: category,
      );
    }).toList();

    // Create sample interactions based on known drug interactions
    final interactions = <DrugInteraction>[];

    // Check for common interactions
    for (int i = 0; i < medications.length; i++) {
      for (int j = i + 1; j < medications.length; j++) {
        final interaction = _checkInteraction(medications[i], medications[j]);
        if (interaction != null) {
          interactions.add(interaction);
        }
      }
    }

    setState(() {
      _graph = DrugInteractionGraph(nodes: nodes, interactions: interactions);
    });
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
    } else if (name.contains('magnesium hydroxide') || 
               name.contains('calcium carbonate') || 
               name.contains('sodium bicarbonate') || 
               name.contains('combination antacid') || 
               name.contains('aluminium hydroxide') ||
               name.contains('aluminum hydroxide') ||
               name.contains('antacid')) {
      return 'Antacid';
    }
    return 'Other';
  }

  DrugInteraction? _checkInteraction(Medication drug1, Medication drug2) {
    final name1 = drug1.name.toLowerCase();
    final name2 = drug2.name.toLowerCase();

    // Aspirin + Warfarin (if we had warfarin)
    if ((name1.contains('aspirin') && name2.contains('warfarin')) ||
        (name1.contains('warfarin') && name2.contains('aspirin'))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description:
            'Increased risk of bleeding. Aspirin enhances the anticoagulant effect of warfarin.',
        severity: InteractionSeverity.high,
        symptoms: ['Easy bruising', 'Nosebleeds', 'Black stools', 'Prolonged bleeding'],
        recommendation:
            'Avoid combination unless specifically prescribed by a physician. Monitor INR closely.',
      );
    }

    // Lisinopril + Potassium
    if ((name1.contains('lisinopril') && name2.contains('potassium')) ||
        (name1.contains('potassium') && name2.contains('lisinopril'))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description:
            'ACE inhibitors can cause potassium retention, leading to hyperkalemia.',
        severity: InteractionSeverity.moderate,
        symptoms: ['Muscle weakness', 'Irregular heartbeat', 'Fatigue'],
        recommendation: 'Monitor potassium levels regularly. Limit potassium-rich foods.',
      );
    }

    // Metformin + Contrast dye (simulated)
    if (name1.contains('metformin') && name2.contains('contrast')) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description:
            'Contrast dye can affect kidney function, increasing risk of lactic acidosis with metformin.',
        severity: InteractionSeverity.high,
        symptoms: ['Lactic acidosis', 'Muscle pain', 'Difficulty breathing', 'Abdominal pain'],
        recommendation:
            'Stop metformin 48 hours before and after contrast procedures. Check kidney function.',
      );
    }

    // Ibuprofen + Aspirin
    if ((name1.contains('ibuprofen') && name2.contains('aspirin')) ||
        (name1.contains('aspirin') && name2.contains('ibuprofen'))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description:
            'Ibuprofen may reduce the cardioprotective effects of aspirin by competing for binding sites.',
        severity: InteractionSeverity.moderate,
        symptoms: ['Reduced aspirin effectiveness', 'Increased cardiovascular risk'],
        recommendation: 'Take aspirin 30 minutes before ibuprofen, or use an alternative pain reliever.',
      );
    }

    // Simvastatin + Grapefruit (simulated)
    if (name1.contains('simvastatin') && name2.contains('grapefruit')) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description:
            'Grapefruit inhibits CYP3A4 enzyme, increasing statin levels and risk of muscle toxicity.',
        severity: InteractionSeverity.high,
        symptoms: ['Muscle pain', 'Dark urine', 'Fatigue', 'Liver problems'],
        recommendation: 'Avoid grapefruit and grapefruit juice while on simvastatin.',
      );
    }

    // Amlodipine + Simvastatin
    if ((name1.contains('amlodipine') && name2.contains('simvastatin')) ||
        (name1.contains('simvastatin') && name2.contains('amlodipine'))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description:
            'Amlodipine inhibits CYP3A4, increasing simvastatin concentration and risk of rhabdomyolysis.',
        severity: InteractionSeverity.contraindicated,
        symptoms: ['Severe muscle pain', 'Weakness', 'Dark urine', 'Kidney damage'],
        recommendation:
            'Limit simvastatin to 20mg daily when used with amlodipine. Consider alternative statin.',
      );
    }

    // Antacids + Antibiotics (e.g., Ciprofloxacin)
    if ((_isAntacid(name1) && _isAntibiotic(name2)) ||
        (_isAntacid(name2) && _isAntibiotic(name1))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description:
            'Antacids reduce the absorption of antibiotics like ciprofloxacin, making them less effective.',
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
        description:
            'Antacids significantly reduce iron absorption by binding to it in the gut.',
        severity: InteractionSeverity.moderate,
        symptoms: ['Reduced iron absorption', 'Anemia worsening', 'Fatigue'],
        recommendation: 'Take iron supplements 2 hours before or after antacids.',
      );
    }

    // Antacids + Thyroid medications (Levothyroxine)
    if ((_isAntacid(name1) && (name2.contains('thyroxine') || name2.contains('levothyroxine'))) ||
        ((name1.contains('thyroxine') || name1.contains('levothyroxine')) && _isAntacid(name2))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description:
            'Antacids reduce the absorption of thyroid medications, potentially causing hypothyroidism.',
        severity: InteractionSeverity.high,
        symptoms: ['Fatigue', 'Weight gain', 'Cold sensitivity', 'Depression'],
        recommendation: 'Take thyroid medication at least 4 hours before or after antacids.',
      );
    }

    // Multiple antacids interaction - using different types together
    if (_isAntacid(name1) && _isAntacid(name2)) {
      // Check if they are different antacids (not the same drug)
      if (name1 != name2) {
        return DrugInteraction(
          id: 'int_${drug1.id}_${drug2.id}',
          drug1Id: drug1.id,
          drug2Id: drug2.id,
          description:
              'Taking multiple antacids together can lead to excessive neutralization of stomach acid, affecting digestion and absorption of nutrients.',
          severity: InteractionSeverity.low,
          symptoms: ['Constipation', 'Diarrhea', 'Bloating', 'Electrolyte imbalance'],
          recommendation: 'Usually only one antacid is needed. Consult your healthcare provider about which antacid is best for you.',
        );
      }
    }

    // Calcium Carbonate + Magnesium Hydroxide specific interaction
    if ((name1.contains('calcium carbonate') && name2.contains('magnesium hydroxide')) ||
        (name1.contains('magnesium hydroxide') && name2.contains('calcium carbonate'))) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description:
            'Calcium carbonate may cause constipation while magnesium hydroxide has a laxative effect. The combination can balance these effects but may cause unpredictable GI symptoms.',
        severity: InteractionSeverity.low,
        symptoms: ['Alternating constipation and diarrhea', 'Bloating', 'Gas'],
        recommendation: 'Monitor GI symptoms. This combination is generally safe but may cause variable stool consistency.',
      );
    }

    // Aluminium Hydroxide + other medications (general slow absorption)
    if ((name1.contains('aluminium hydroxide') || name1.contains('aluminum hydroxide')) && 
        !_isAntacid(name2)) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description:
            'Aluminium hydroxide can reduce the absorption of many medications by binding to them in the gut.',
        severity: InteractionSeverity.moderate,
        symptoms: ['Reduced medication effectiveness'],
        recommendation: 'Take other medications 2 hours before or after aluminium hydroxide.',
      );
    }
    if ((name2.contains('aluminium hydroxide') || name2.contains('aluminum hydroxide')) && 
        !_isAntacid(name1)) {
      return DrugInteraction(
        id: 'int_${drug1.id}_${drug2.id}',
        drug1Id: drug1.id,
        drug2Id: drug2.id,
        description:
            'Aluminium hydroxide can reduce the absorption of many medications by binding to them in the gut.',
        severity: InteractionSeverity.moderate,
        symptoms: ['Reduced medication effectiveness'],
        recommendation: 'Take other medications 2 hours before or after aluminium hydroxide.',
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
        name.contains('gaviscon') ||
        // The 5 antacids from the database
        name.contains('magnesium hydroxide') ||
        name.contains('calcium carbonate') ||
        name.contains('sodium bicarbonate') ||
        name.contains('combination antacid') ||
        name.contains('aluminium hydroxide') ||
        name.contains('aluminum hydroxide'); // Alternative spelling
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

  @override
  Widget build(BuildContext context) {
    final healthData = context.read<HealthDataProvider>();
    final medications = healthData.medications.where((m) => m.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drug Interactions'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _buildGraph();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildMedicationList(medications, context),
              const SizedBox(height: 24),
              _buildGraphSection(context),
              const SizedBox(height: 24),
              _buildWarningsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final totalInteractions = _graph?.interactions.length ?? 0;
    final highRiskInteractions = _graph?.interactions
            .where((i) =>
                i.severity == InteractionSeverity.high ||
                i.severity == InteractionSeverity.contraindicated)
            .length ??
        0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medication,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Drug Interaction Analysis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('Active Drugs', '${_graph?.nodes.length ?? 0}', Icons.medication, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard('Interactions', '$totalInteractions', Icons.link, Colors.orange),
                const SizedBox(width: 12),
                _buildStatCard('High Risk', '$highRiskInteractions', Icons.warning, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationList(List<Medication> medications, BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Medications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (medications.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No active medications'),
                ),
              )
            else
              ...medications.map((med) => _buildMedicationItem(med, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItem(Medication med, BuildContext context) {
    final hasInteractions = _graph?.hasHighSeverityInteractions(med.id) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasInteractions ? Colors.red.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasInteractions ? Colors.red.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasInteractions ? Colors.red : Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasInteractions ? Icons.warning : Icons.medication,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${med.dosage} - ${med.frequency}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (hasInteractions)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Review',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGraphSection(BuildContext context) {
    if (_graph == null || _graph!.nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_tree,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Interaction Graph',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap on a drug node to see details. Tap on interaction lines to see interaction information.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 350,
              child: DrugInteractionGraphWidget(
                graph: _graph!,
                primaryColor: Theme.of(context).primaryColor,
                onInteractionSelected: _showInteractionDetails,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningsSection(BuildContext context) {
    final warnings = _graph?.interactions
            .where((i) =>
                i.severity == InteractionSeverity.high ||
                i.severity == InteractionSeverity.contraindicated)
            .toList() ??
        [];

    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.priority_high,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Important Warnings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...warnings.map((warning) => _buildWarningItem(warning)),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem(DrugInteraction interaction) {
    final drug1 = _graph?.nodes.firstWhere((n) => n.id == interaction.drug1Id);
    final drug2 = _graph?.nodes.firstWhere((n) => n.id == interaction.drug2Id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: interaction.severityColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                interaction.severity == InteractionSeverity.contraindicated
                    ? Icons.cancel
                    : Icons.warning,
                color: interaction.severityColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${drug1?.name ?? ''} + ${drug2?.name ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: interaction.severityColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: interaction.severityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  interaction.severity.displayName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            interaction.description,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.amber.shade700,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    interaction.recommendation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInteractionDetails(DrugInteraction interaction) {
    final drug1 = _graph?.nodes.firstWhere((n) => n.id == interaction.drug1Id);
    final drug2 = _graph?.nodes.firstWhere((n) => n.id == interaction.drug2Id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
                Icon(
                  Icons.warning,
                  color: interaction.severityColor,
                  size: 28,
                ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${drug1?.name} + ${drug2?.name}',
                style: TextStyle(
                  color: interaction.severityColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: interaction.severityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  interaction.severity.displayName,
                  style: TextStyle(
                    color: interaction.severityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(interaction.description),
              if (interaction.symptoms.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Possible Symptoms',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: interaction.symptoms
                      .map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.red.shade100,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.amber.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommendation',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            interaction.recommendation,
                            style: TextStyle(color: Colors.amber.shade900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Could navigate to contact doctor or more info
            },
            child: const Text('Contact Pharmacist'),
          ),
        ],
      ),
    );
  }
}
