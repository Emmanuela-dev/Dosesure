import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/medication.dart';
import '../models/dose_intake.dart';
import '../models/dose_log.dart';
import '../providers/health_data_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/medication_expiry_service.dart';
import '../services/photo_verification_service.dart';
import '../widgets/clinician_comments_widget.dart';
import 'medication_list_screen.dart';
import 'side_effects_screen.dart';
import 'herbal_use_screen.dart';
import 'history_screen.dart';
import 'adherence_screen.dart';
import 'export_report_screen.dart';
import 'role_selection_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExpiredMedications();
    });
  }

  Future<void> _checkExpiredMedications() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      if (userId == null) return;

      final expiredMeds = await MedicationExpiryService().checkAndDeactivateExpiredMedications(userId);
      
      if (expiredMeds.isNotEmpty && mounted) {
        final healthData = Provider.of<HealthDataProvider>(context, listen: false);
        healthData.initializeForUser(userId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${expiredMeds.length} medication(s) have expired and been removed'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking expired medications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userName = authProvider.currentUser?.name ?? '';
        final firstName = userName.isNotEmpty && userName != 'User' 
          ? userName.split(' ').first 
          : '';
        final greeting = DateTime.now().hour < 12 ? 'morning' : DateTime.now().hour < 17 ? 'afternoon' : 'evening';

        return Scaffold(
      appBar: AppBar(
        title: const Text('DawaTrack'),
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
              if (value == 'export') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExportReportScreen()),
                );
              } else if (value == 'logout') {
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
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      (route) => false,
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Export Report'),
                  ],
                ),
              ),
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
                'Good $greeting, ${firstName.isNotEmpty ? firstName : userName}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                today,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              if (authProvider.currentUser != null)
                ClinicianCommentsWidget(userId: authProvider.currentUser!.id),
              const SizedBox(height: 16),
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
              _buildMedicationProgressGraph(),
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
      },
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
                  const Icon(
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
    final expiryService = MedicationExpiryService();
    final daysRemaining = expiryService.getDaysRemaining(med);
    final isExpiringSoon = daysRemaining >= 0 && daysRemaining <= 2;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isExpiringSoon ? BorderSide(color: Colors.orange, width: 2) : BorderSide.none,
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
                if (daysRemaining >= 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpiringSoon ? Colors.orange : Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      daysRemaining == 0 ? 'Last day' : '$daysRemaining days left',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
        Consumer<HealthDataProvider>(
          builder: (context, healthData, child) {
            final adherence = healthData.getAdherencePercentage();
            return _buildActionCard(
              'Adherence',
              Icons.check_circle,
              adherence >= 80 ? Colors.green : adherence >= 60 ? Colors.orange : Colors.red,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdherenceScreen()),
                );
              },
            );
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
        final selfReportedAdherence = healthData.getAdherencePercentage();
        final verifiedAdherence = healthData.getVerifiedAdherencePercentage();

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
                      'Self-Reported', 
                      '${selfReportedAdherence.toStringAsFixed(0)}%', 
                      selfReportedAdherence >= 80 ? Colors.green : selfReportedAdherence >= 60 ? Colors.orange : Colors.red,
                      hasAlert: selfReportedAdherence < 60,
                    ),
                    _buildSummaryItem(
                      'Verified', 
                      '${verifiedAdherence.toStringAsFixed(0)}%', 
                      verifiedAdherence >= 80 ? Colors.green : verifiedAdherence >= 60 ? Colors.orange : Colors.red,
                      hasAlert: false,
                    ),
                    _buildSummaryItem(
                      'Medications', 
                      '${medications.length}', 
                      Colors.blue,
                      hasAlert: false,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Research shows self-reported adherence may overestimate by 20-30%. Use photo verification for accuracy.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildMedicationProgressGraph() {
    return Consumer<HealthDataProvider>(
      builder: (context, healthData, child) {
        final medications = healthData.medications.where((m) => m.isActive).toList();

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
                      'Medication Schedule',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                  ],
                ),
                const SizedBox(height: 16),
                if (medications.isEmpty)
                  _buildEmptyState('No active medications', Icons.medication_outlined)
                else
                  Column(
                    children: medications.map((med) => _buildMedicationTimeline(med, healthData)).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicationTimeline(Medication medication, HealthDataProvider healthData) {
    final now = DateTime.now();
    final doseLogs = healthData.getDoseLogsForMedication(medication.id);
    final todayLogs = doseLogs.where((log) {
      final logDate = log.scheduledTime;
      return logDate.year == now.year && logDate.month == now.month && logDate.day == now.day;
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${medication.dosage} - ${medication.frequency}',
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
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            'Today\'s Schedule',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ...medication.times.map((time) {
            final timeParts = time.split(':');
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            final scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);
            
            final isTaken = todayLogs.any((log) {
              final logTime = log.scheduledTime;
              return logTime.hour == hour && logTime.minute == minute && log.taken;
            });
            
            final isPast = now.isAfter(scheduleTime);
            final isUpcoming = !isPast && scheduleTime.difference(now).inMinutes <= 30;

            return _buildTimeSlot(time, isTaken, isPast, isUpcoming, medication, healthData);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time, bool isTaken, bool isPast, bool isUpcoming, Medication medication, HealthDataProvider healthData) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isTaken) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Taken';
    } else if (isUpcoming) {
      statusColor = Colors.orange;
      statusIcon = Icons.notifications_active;
      statusText = 'Time to take!';
    } else if (isPast) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Missed';
    } else {
      statusColor = Colors.blue;
      statusIcon = Icons.schedule;
      statusText = 'Scheduled';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: isUpcoming && !isTaken
          ? Card(
              elevation: 4,
              color: statusColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => _confirmDoseIntake(medication, time, healthData),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TAP TO CONFIRM',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$time - ${medication.dosage}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: statusColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
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

  void _showNotifications(BuildContext context) {
    final healthData = Provider.of<HealthDataProvider>(context, listen: false);
    final medications = healthData.medications.where((m) => m.isActive).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Notifications'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Divider(),
              _buildNotificationItem(
                'Active Medications',
                '${medications.length} medication${medications.length != 1 ? 's' : ''} in your schedule',
                Icons.schedule,
                Colors.orange,
              ),
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

  void _confirmDoseIntake(Medication medication, String time, HealthDataProvider healthData) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    // Show confirmation dialog with photo option
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Dose'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${medication.name} - ${medication.dosage}'),
            const SizedBox(height: 16),
            const Text(
              'Add photo proof for verified adherence tracking?',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Photo verification provides accurate adherence data',
                      style: TextStyle(fontSize: 10, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, {'withPhoto': false}),
            child: const Text('Skip Photo'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, {'withPhoto': true}),
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text('Take Photo'),
          ),
        ],
      ),
    );

    if (result == null) return;

    await _requestAlarmPermissions();

    String? photoUrl;
    bool isVerified = false;

    if (result['withPhoto'] == true) {
      try {
        final photoService = PhotoVerificationService();
        final photo = await photoService.capturePhoto();
        
        if (photo != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text('Uploading photo...'),
                  ],
                ),
                duration: Duration(seconds: 2),
              ),
            );
          }
          
          photoUrl = await photoService.uploadPhoto(userId, medication.id, photo);
          isVerified = true;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo upload failed: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }

    final now = DateTime.now();
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    DateTime nextDueTime = _calculateNextDoseTime(now, medication.frequency, medication.times, time);
    
    final intake = DoseIntake(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: medication.id,
      medicationName: medication.name,
      takenAt: now,
      scheduledTime: time,
      nextDueTime: nextDueTime,
      photoProofUrl: photoUrl,
      isVerified: isVerified,
    );

    final doseLog = DoseLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: medication.id,
      scheduledTime: DateTime(now.year, now.month, now.day, hour, minute),
      takenTime: now,
      taken: true,
      photoProofUrl: photoUrl,
      isVerified: isVerified,
    );

    try {
      await FirestoreService().recordDoseIntake(userId, intake);
      await healthData.logDose(userId, doseLog);
      await NotificationService().scheduleMedicationReminders(medication);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isVerified ? Icons.verified : Icons.check_circle,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${medication.name} dose confirmed${isVerified ? ' with photo verification' : ' (self-reported)'}!\nNext dose: ${DateFormat('MMM d, h:mm a').format(nextDueTime)}',
                  ),
                ),
              ],
            ),
            backgroundColor: isVerified ? Colors.green : Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestAlarmPermissions() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  DateTime _calculateNextDoseTime(DateTime current, String frequency, List<String> times, String currentTime) {
    final currentIndex = times.indexOf(currentTime);
    
    if (currentIndex < times.length - 1) {
      final nextTime = times[currentIndex + 1];
      final parts = nextTime.split(':');
      return DateTime(current.year, current.month, current.day, int.parse(parts[0]), int.parse(parts[1]));
    }
    
    final firstTime = times[0];
    final parts = firstTime.split(':');
    return DateTime(current.year, current.month, current.day + 1, int.parse(parts[0]), int.parse(parts[1]));
  }
}
