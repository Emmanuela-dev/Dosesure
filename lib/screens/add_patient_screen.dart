import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

class AddPatientScreen extends StatefulWidget {
  final String clinicianId;
  final void Function(User) onPatientAdded;
  const AddPatientScreen({super.key, required this.clinicianId, required this.onPatientAdded});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _firestoreService = FirestoreService();
  List<User> _availablePatients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAvailablePatients();
  }

  Future<void> _loadAvailablePatients() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: UserRole.patient.index)
          .get();
      
      _availablePatients = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return User.fromJson(data);
          })
          .where((user) => user.doctorId == null || user.doctorId!.isEmpty)
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patients: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _assignPatient(User patient) async {
    try {
      final updatedPatient = patient.copyWith(doctorId: widget.clinicianId);
      await _firestoreService.updateUser(updatedPatient);
      widget.onPatientAdded(updatedPatient);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${patient.name} added successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<User> get _filteredPatients {
    if (_searchQuery.isEmpty) return _availablePatients;
    return _availablePatients.where((p) => 
      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      p.email.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Patient')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No available patients\nAll registered patients are assigned'
                                  : 'No patients found',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  patient.name[0].toUpperCase(),
                                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(patient.email),
                              trailing: ElevatedButton(
                                onPressed: () => _assignPatient(patient),
                                child: const Text('Add'),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
