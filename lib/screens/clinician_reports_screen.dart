import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';

class ClinicianReportsScreen extends StatelessWidget {
  const ClinicianReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Export reports
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
                'Medication Adherence Reports',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildAdherenceChart(context),
              const SizedBox(height: 32),
              Text(
                'Side Effects Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSideEffectsReport(context),
              const SizedBox(height: 32),
              Text(
                'Herbal Medicine Usage',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildHerbalUsageReport(context),
              const SizedBox(height: 32),
              Text(
                'Patient Compliance Trends',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildComplianceTrends(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdherenceChart(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        final adherence = healthData.getAdherencePercentage();
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Overall Adherence Rate',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: adherence / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    adherence >= 80 ? Colors.green : adherence >= 60 ? Colors.orange : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${adherence.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideEffectsReport(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        final sideEffects = healthData.sideEffects;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Reported Side Effects: ${sideEffects.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                if (sideEffects.isEmpty)
                  const Text('No side effects reported')
                else
                  Column(
                    children: sideEffects.map((effect) => ListTile(
                      title: Text(effect.description),
                      subtitle: Text('Severity: ${effect.severity}'),
                      trailing: Text(effect.reportedDate.toString().split(' ')[0]),
                    )).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHerbalUsageReport(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        final herbalUses = healthData.herbalUses.where((h) => h.isActive).toList();
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Active Herbal Medicines: ${herbalUses.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                if (herbalUses.isEmpty)
                  const Text('No active herbal medicine usage')
                else
                  Column(
                    children: herbalUses.map((herbal) => ListTile(
                      title: Text(herbal.name),
                      subtitle: Text('Purpose: ${herbal.purpose}'),
                      trailing: Text(herbal.startDate.toString().split(' ')[0]),
                    )).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplianceTrends(BuildContext context) {
    // Mock data for trends - in real app, this would be calculated from historical data
    final trends = [
      {'period': 'Last 7 days', 'compliance': 85.0},
      {'period': 'Last 30 days', 'compliance': 82.0},
      {'period': 'Last 90 days', 'compliance': 78.0},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: trends.map((trend) => ListTile(
            title: Text(trend['period'] as String),
            trailing: Text('${(trend['compliance'] as double).toStringAsFixed(1)}%'),
          )).toList(),
        ),
      ),
    );
  }
}