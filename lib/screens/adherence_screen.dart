import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';

class AdherenceScreen extends StatelessWidget {
  const AdherenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adherence'),
      ),
      body: Consumer<HealthDataProvider>(
        builder: (context, healthData, child) {
          final adherence = healthData.getAdherencePercentage();
          final medications = healthData.medications.where((m) => m.isActive).toList();
          final totalDoses = healthData.doseLogs.length;
          final takenDoses = healthData.doseLogs.where((log) => log.taken).length;
          final missedDoses = totalDoses - takenDoses;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          '${adherence.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: adherence >= 80 ? Colors.green : adherence >= 60 ? Colors.orange : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Overall Adherence',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatCard('Total Doses', totalDoses.toString(), Icons.medication, Colors.blue),
                _buildStatCard('Taken Doses', takenDoses.toString(), Icons.check_circle, Colors.green),
                _buildStatCard('Missed Doses', missedDoses.toString(), Icons.cancel, Colors.red),
                _buildStatCard('Active Medications', medications.length.toString(), Icons.list, Colors.purple),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
