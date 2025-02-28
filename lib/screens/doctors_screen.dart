import 'package:flutter/material.dart';
import 'package:healthcare_app/models/doctor.dart';
import 'package:healthcare_app/services/api_service.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  Map<int, bool> _selectedDoctors = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDoctors);
  }

  void _filterDoctors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        return doctor.specialization.toLowerCase().contains(query) ||
            (doctor.phone?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDoctorDialog,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                gradient: LinearGradient(
                  colors: [Colors.blue[800]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.local_hospital,
                      size: 40,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Healthcare App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Doctors'),
              selected: true,
              selectedTileColor: Colors.blue[100],
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Already on Doctors screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Patients'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Patients screen
                // Navigator.push(context, MaterialPageRoute(builder: (_) => PatientsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Appointments'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Appointments screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Settings screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement logout functionality
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by specialization or phone',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total Doctors: ${_filteredDoctors.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Doctor>>(
              future: apiService.getDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No doctors found'));
                }

                _allDoctors = snapshot.data!;
                if (_filteredDoctors.isEmpty && _searchController.text.isEmpty) {
                  _filteredDoctors = _allDoctors;
                }

                return ListView.builder(
                  itemCount: _filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _filteredDoctors[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _selectedDoctors[doctor.id] ?? false,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDoctors[doctor.id!] = value!;
                                });
                              },
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                doctor.specialization[0].toUpperCase(),
                                style: TextStyle(color: Colors.blue[800]),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          doctor.specialization,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Phone: ${doctor.phone ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDoctorDialog(doctor),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDoctor(doctor.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDoctorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Doctor'),
        content: _buildDialogContent(),
        actions: _buildDialogActions(isEdit: false),
      ),
    );
  }

  void _showEditDoctorDialog(Doctor doctor) {
    _userIdController.text = doctor.userId.toString();
    _specializationController.text = doctor.specialization;
    _phoneController.text = doctor.phone ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Doctor'),
        content: _buildDialogContent(),
        actions: _buildDialogActions(isEdit: true, doctor: doctor),
      ),
    );
  }

  Widget _buildDialogContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _userIdController,
            decoration: _inputDecoration('User ID'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _specializationController,
            decoration: _inputDecoration('Specialization'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: _inputDecoration('Phone (optional)'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  List<Widget> _buildDialogActions({required bool isEdit, Doctor? doctor}) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () async {
          try {
            final newDoctor = Doctor(
              id: isEdit ? doctor!.id : null,
              userId: int.parse(_userIdController.text),
              specialization: _specializationController.text,
              phone: _phoneController.text.isEmpty ? null : _phoneController.text,
            );
            if (isEdit) {
              await apiService.updateDoctor(doctor!.id!.toString(), newDoctor);
            } else {
              await apiService.createDoctor(newDoctor);
            }
            Navigator.pop(context);
            setState(() {});
            _clearControllers();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        },
        child: Text(isEdit ? 'Update' : 'Add'),
      ),
    ];
  }

  void _deleteDoctor(int id) async {
    try {
      await apiService.deleteDoctor(id.toString());
      setState(() {
        _selectedDoctors.remove(id);
        _allDoctors.removeWhere((doctor) => doctor.id == id);
        _filteredDoctors.removeWhere((doctor) => doctor.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting doctor: $e')),
      );
    }
  }

  void _clearControllers() {
    _userIdController.clear();
    _specializationController.clear();
    _phoneController.clear();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDoctors);
    _searchController.dispose();
    _userIdController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}