import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../models/dose_log.dart';
import '../models/medication.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dose History'),
      ),
      body: Consumer<HealthDataProvider>(
        builder: (context, healthData, child) {
          final doseLogs = healthData.doseLogs;

          if (doseLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No dose history yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your logged doses will appear here',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Group by date
          final groupedLogs = <String, List<DoseLog>>{};
          for (final log in doseLogs) {
            final dateKey = '${log.scheduledTime.year}-${log.scheduledTime.month}-${log.scheduledTime.day}';
            groupedLogs.putIfAbsent(dateKey, () => []).add(log);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedLogs.length,
            itemBuilder: (context, index) {
              final dateKey = groupedLogs.keys.elementAt(index);
              final logs = groupedLogs[dateKey]!;
              final date = logs.first.scheduledTime;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('${logs.length} doses logged'),
                  children: logs.map((log) => _buildDoseLogItem(context, log, healthData)).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDoseLogItem(BuildContext context, DoseLog log, HealthDataProvider healthData) {
    // Log dose feature removed
    final medication = Medication(
      id: 'unknown',
      name: 'Unknown Medication',
      dosage: '',
      frequency: '',
      times: [],
      instructions: '',
      startDate: DateTime.now(),
    );

    return ListTile(
      leading: Icon(
        log.taken ? Icons.check_circle : Icons.cancel,
        color: log.taken ? Colors.green : Colors.red,
      ),
      title: Text(medication.name),
      subtitle: Text(
        'Scheduled: ${log.scheduledTime.hour}:${log.scheduledTime.minute.toString().padLeft(2, '0')} | '
        '${log.taken ? 'Taken' : 'Missed'}',
      ),
      trailing: log.takenTime != null
          ? Text(
              '${log.takenTime!.hour}:${log.takenTime!.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
    );
  }
}