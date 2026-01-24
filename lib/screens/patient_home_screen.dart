import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'medication_list_screen.dart';
import 'side_effects_screen.dart';
import 'herbal_use_screen.dart';
import 'history_screen.dart';

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
}