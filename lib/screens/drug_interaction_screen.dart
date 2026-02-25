import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drug_interaction.dart';
import '../models/medication.dart';
import '../models/drug.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildGraph();
    });
  }

  void _buildGraph() {
    final healthData = context.read<HealthDataProvider>();
    final authProvider = context.read<AuthProvider>();
    final medications = healthData.medications.where((m) => m.isActive).toList();

    // Create drug nodes from medications
    final nodes = medications.map((med) {
      final drug = _findDrugInDatabase(med.name, authProvider.drugs);
      return DrugNode(
        id: med.id,
        name: med.name,
        category: drug?.categoryDisplay ?? 'Other',
      );
    }).toList();

    // Check interactions using database
    final interactions = <GraphInteraction>[];
    for (int i = 0; i < medications.length; i++) {
      for (int j = i + 1; j < medications.length; j++) {
        final interaction = _checkInteractionFromDatabase(
          medications[i], 
          medications[j], 
          authProvider.drugs
        );
        if (interaction != null) {
          interactions.add(interaction);
        }
      }
    }

    setState(() {
      _graph = DrugInteractionGraph(nodes: nodes, interactions: interactions);
    });
  }

  Drug? _findDrugInDatabase(String medicationName, List<Drug> drugs) {
    final name = medicationName.toLowerCase();
    return drugs.firstWhere(
      (d) => name.contains(d.name.toLowerCase()) || name.contains(d.genericName.toLowerCase()),
      orElse: () => drugs.firstWhere(
        (d) => d.name.toLowerCase().contains(name) || d.genericName.toLowerCase().contains(name),
        orElse: () => Drug(
          id: 'unknown',
          name: medicationName,
          genericName: medicationName,
          category: DrugCategory.other,
          isHighAlert: false,
          commonDosages: [],
          interactions: [],
          warnings: '',
        ),
      ),
    );
  }

  GraphInteraction? _checkInteractionFromDatabase(
    Medication med1, 
    Medication med2, 
    List<Drug> drugs
  ) {
    final drug1 = _findDrugInDatabase(med1.name, drugs);
    final drug2 = _findDrugInDatabase(med2.name, drugs);

    if (drug1 == null || drug2 == null) return null;

    // Check if drug1 lists drug2 in its interactions
    if (drug1.interactions.contains(drug2.id)) {
      return _createInteraction(med1, med2, drug1, drug2);
    }

    // Check if drug2 lists drug1 in its interactions
    if (drug2.interactions.contains(drug1.id)) {
      return _createInteraction(med1, med2, drug2, drug1);
    }

    return null;
  }

  GraphInteraction _createInteraction(
    Medication med1,
    Medication med2,
    Drug interactingDrug,
    Drug otherDrug,
  ) {
    // Determine severity based on drug properties
    InteractionSeverity severity;
    if (interactingDrug.isHighAlert || otherDrug.isHighAlert) {
      severity = InteractionSeverity.high;
    } else {
      severity = InteractionSeverity.moderate;
    }

    return GraphInteraction(
      id: 'int_${med1.id}_${med2.id}',
      drug1Id: med1.id,
      drug2Id: med2.id,
      description: '${interactingDrug.name} may interact with ${otherDrug.name}. ${interactingDrug.warnings}',
      severity: severity,
      symptoms: [],
      recommendation: 'Consult your healthcare provider. ${interactingDrug.warnings}',
    );
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

  Widget _buildWarningItem(GraphInteraction interaction) {
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

  void _showInteractionDetails(GraphInteraction interaction) {
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
