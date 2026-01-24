import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';

class ClinicianPatientsScreen extends StatelessWidget {
  const ClinicianPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<HealthDataProvider, AuthProvider>(
          builder: (context, healthData, authProvider, child) {
            final medications = healthData.medications.length;
            final sideEffects = healthData.sideEffects.length;
            final herbalUses = healthData.herbalUses.where((h) => h.isActive).toList().length;
            final adherence = healthData.getAdherencePercentage();

            // Mock patient data - in real app, this would come from API filtered by current clinician
            // For demo, showing patients linked to "Dr. Smith" (clinician_1)
            final patients = [
              {
                'name': 'John Doe',
                'doctorId': 'clinician_1',
                'medications': medications,
                'sideEffects': sideEffects,
                'herbalUses': herbalUses,
                'adherence': adherence,
                'status': adherence >= 80 ? 'Good' : 'Needs Attention',
                'lastCheckIn': '2 hours ago',
                'nextAppointment': 'Tomorrow, 10:00 AM'
              },
              {
                'name': 'Jane Smith',
                'doctorId': 'clinician_1',
                'medications': 3,
                'sideEffects': 1,
                'herbalUses': 0,
                'adherence': 75.0,
                'status': 'Needs Attention',
                'lastCheckIn': '1 day ago',
                'nextAppointment': 'Next week'
              },
              {
                'name': 'Bob Johnson',
                'doctorId': 'clinician_1',
                'medications': 2,
                'sideEffects': 0,
                'herbalUses': 1,
                'adherence': 90.0,
                'status': 'Good',
                'lastCheckIn': '30 min ago',
                'nextAppointment': 'In 3 days'
              },
            ];

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return _buildPatientCard(context, patient);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, Map<String, dynamic> patient) {
    Color statusColor;
    final status = patient['status'] as String;
    switch (status) {
      case 'Excellent':
        statusColor = Colors.green;
        break;
      case 'Good':
        statusColor = Colors.blue;
        break;
      case 'Needs Attention':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            (patient['name'] as String).split(' ').map((e) => e[0]).join(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(patient['name'] as String),
        subtitle: Text('Adherence: ${(patient['adherence'] as double).toStringAsFixed(0)}%'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Medications: ${patient['medications']}'),
                Text('Side Effects Reported: ${patient['sideEffects']}'),
                Text('Herbal Medicines: ${patient['herbalUses']}'),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final doctorId = patient['doctorId'] as String?;
                    final clinician = doctorId != null ? authProvider.getClinicianById(doctorId) : null;
                    final doctorName = clinician?['name'] ?? 'Unknown Doctor';
                    return Text('Doctor: $doctorName');
                  },
                ),
                Text('Last Check-in: ${patient['lastCheckIn']}'),
                Text('Next Appointment: ${patient['nextAppointment']}'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to patient details
                        },
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Contact patient
                        },
                        child: const Text('Contact'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}