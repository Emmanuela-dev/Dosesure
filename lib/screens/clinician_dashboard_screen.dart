import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
import 'clinician_patients_screen.dart';
import 'clinician_reports_screen.dart';

class ClinicianDashboardScreen extends StatefulWidget {
  const ClinicianDashboardScreen({super.key});

  @override
  State<ClinicianDashboardScreen> createState() => _ClinicianDashboardScreenState();
}

class _ClinicianDashboardScreenState extends State<ClinicianDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardContent(),
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

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Dr. Smith',
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
            Text(
              'Patient List',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPatientList(context),
          ],
        ),
      ),
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

  Widget _buildPatientList(BuildContext context) {
    return Consumer2<HealthDataProvider, AuthProvider>(
      builder: (context, healthData, authProvider, child) {
        final medications = healthData.medications;
        final sideEffects = healthData.sideEffects;
        final herbalUses = healthData.herbalUses.where((h) => h.isActive).toList();
        final adherence = healthData.getAdherencePercentage();

        // Mock patient data - in real app, this would come from API filtered by current clinician
        final patients = [
          {
            'name': 'John Doe',
            'doctorId': 'clinician_1',
            'medications': medications.length,
            'sideEffects': sideEffects.length,
            'herbalUses': herbalUses.length,
            'adherence': adherence,
            'status': adherence >= 80 ? 'Good' : 'Needs Attention'
          },
        ];

        return Column(
          children: patients.map((patient) => _buildPatientCard(context, patient, authProvider)).toList(),
        );
      },
    );
  }

  Widget _buildPatientCard(BuildContext context, Map<String, dynamic> patient, AuthProvider authProvider) {
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
                Builder(
                  builder: (context) {
                    final doctorId = patient['doctorId'] as String?;
                    final clinician = doctorId != null ? authProvider.getClinicianById(doctorId) : null;
                    final doctorName = clinician?['name'] ?? 'Unknown Doctor';
                    return Text('Doctor: $doctorName');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}