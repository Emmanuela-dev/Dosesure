import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/user.dart';

class ClinicianPatientsScreen extends StatefulWidget {
  const ClinicianPatientsScreen({super.key});

  @override
  State<ClinicianPatientsScreen> createState() => _ClinicianPatientsScreenState();
}

class _ClinicianPatientsScreenState extends State<ClinicianPatientsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<User> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser != null && currentUser.role == UserRole.clinician) {
      try {
        final patients = await _firestoreService.getPatientsForClinician(currentUser.id);
        setState(() {
          _patients = patients;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          String errorMessage = 'Error loading patients';
          
          // Check for specific Firestore errors
          if (e.toString().contains('PERMISSION_DENIED') || 
              e.toString().contains('has not been used') ||
              e.toString().contains('is disabled')) {
            errorMessage = 'Firestore is not enabled. Please enable Cloud Firestore in Firebase Console and restart the app.';
          } else if (e.toString().contains('network')) {
            errorMessage = 'Network error. Please check your internet connection.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _loadPatients,
              ),
            ),
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _patients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No patients linked yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Patients will appear here when they\nselect you as their doctor during registration',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _patients.length,
                    itemBuilder: (context, index) {
                      final patient = _patients[index];
                      return _buildPatientCard(context, patient);
                    },
                  ),
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, User patient) {
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
            patient.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(patient.name),
        subtitle: Text(patient.email),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Patient',
            style: TextStyle(
              color: Colors.blue,
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
                Text('Email: ${patient.email}'),
                Text('Patient ID: ${patient.id}'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to patient details/health data
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Viewing ${patient.name}\'s health data')),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Health Data'),
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