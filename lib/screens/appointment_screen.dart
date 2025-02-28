import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/appointment.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Appointment>> _appointments;
  bool _isSidebarOpen = true;
  List<Appointment> _filteredAppointments = [];
  Appointment? _selectedAppointment;
  final TextEditingController _searchController = TextEditingController();
  Map<int, bool> _checklist = {};

  @override
  void initState() {
    super.initState();
    _refreshAppointments();
    _searchController.addListener(_filterAppointments);
  }

  void _refreshAppointments() {
    setState(() {
      _appointments = _apiService.getAppointments().then((appointments) {
        _filteredAppointments = appointments;
        _checklist = {for (var app in appointments) app.id!: false};
        return appointments;
      });
    });
  }

  void _filterAppointments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _appointments.then((appointments) {
        _filteredAppointments = appointments.where((appointment) {
          return appointment.appointmentTime.toLowerCase().contains(query) ||
              appointment.patientId.toString().contains(query) ||
              appointment.doctorId.toString().contains(query) ||
              appointment.status.toLowerCase().contains(query) ||
              (appointment.notes?.toLowerCase().contains(query) ?? false);
        }).toList();
      });
    });
  }

  Future<void> _showAppointmentDialog({Appointment? appointment}) async {
    final TextEditingController patientIdController =
    TextEditingController(text: appointment?.patientId.toString() ?? '');
    final TextEditingController doctorIdController =
    TextEditingController(text: appointment?.doctorId.toString() ?? '');
    final TextEditingController timeController =
    TextEditingController(text: appointment?.appointmentTime ?? '');
    final TextEditingController notesController =
    TextEditingController(text: appointment?.notes ?? '');
    String status = appointment?.status ?? 'pending';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(appointment == null ? 'New Appointment' : 'Edit Appointment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(patientIdController, 'Patient ID', TextInputType.number),
              _buildTextField(doctorIdController, 'Doctor ID', TextInputType.number),
              _buildDateField(timeController),
              _buildStatusDropdown(status, (newValue) => status = newValue!),
              _buildTextField(notesController, 'Notes', TextInputType.multiline, maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAppointment = Appointment(
                id: appointment?.id,
                patientId: int.parse(patientIdController.text),
                doctorId: int.parse(doctorIdController.text),
                appointmentTime: timeController.text,
                status: status,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );

              try {
                if (appointment == null) {
                  await _apiService.createAppointment(newAppointment);
                } else {
                  await _apiService.updateAppointment(newAppointment);
                }
                Navigator.pop(context);
                _refreshAppointments();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text(appointment == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    setState(() {
      _selectedAppointment = appointment;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Appointment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${appointment.appointmentTime}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Patient ID: ${appointment.patientId}'),
            Text('Doctor ID: ${appointment.doctorId}'),
            Text('Status: ${appointment.status}'),
            if (appointment.notes != null) ...[
              const SizedBox(height: 8),
              Text('Notes: ${appointment.notes}'),
            ],
          ],
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

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: type,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Appointment Time',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2026),
          );
          if (picked != null) {
            controller.text = picked.toIso8601String();
          }
        },
      ),
    );
  }

  Widget _buildStatusDropdown(String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: ['pending', 'confirmed', 'cancelled']
            .map((String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        ))
            .toList(),
        onChanged: (String? newValue) => onChanged(newValue!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarOpen ? 250 : 70,
            child: Container(
              color: Colors.lightBlue[900],
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                        ),
                        if (_isSidebarOpen) ...[
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Dr.Karen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('Doctor', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.white),
                    title: _isSidebarOpen ? const Text('Appointments', style: TextStyle(color: Colors.white)) : null,
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.people, color: Colors.white),
                    title: _isSidebarOpen ? const Text('Patients', style: TextStyle(color: Colors.white)) : null,
                    onTap: () {},
                  ),
                  const Spacer(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: _isSidebarOpen ? const Text('Logout', style: TextStyle(color: Colors.white)) : null,
                    onTap: () async {
                      await _apiService.logout();
                      // Navigate to login screen
                    },
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
                        onPressed: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search appointments...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _refreshAppointments,
                      ),
                    ],
                  ),
                ),

                // Appointments Table
                Expanded(
                  child: FutureBuilder<List<Appointment>>(
                    future: _appointments,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || _filteredAppointments.isEmpty) {
                        return const Center(child: Text('No appointments found'));
                      }

                      return ReorderableListView(
                        header: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const SizedBox(width: 40), // Space for checkbox
                                const Expanded(flex: 2, child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                                const Expanded(child: Text('Patient', style: TextStyle(fontWeight: FontWeight.bold))),
                                const Expanded(child: Text('Doctor', style: TextStyle(fontWeight: FontWeight.bold))),
                                const Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Container()), // Space for actions
                              ],
                            ),
                          ),
                        ),
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _filteredAppointments.removeAt(oldIndex);
                            _filteredAppointments.insert(newIndex, item);
                            // Note: This only reorders locally. To persist, you'd need to update the backend
                          });
                        },
                        children: _filteredAppointments.map((appointment) {
                          return Card(
                            key: ValueKey(appointment.id),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: InkWell(
                              onTap: () => _showAppointmentDetails(appointment),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _checklist[appointment.id] ?? false,
                                      onChanged: (value) {
                                        setState(() {
                                          _checklist[appointment.id!] = value!;
                                        });
                                      },
                                    ),
                                    Expanded(flex: 2, child: Text(appointment.appointmentTime)),
                                    Expanded(child: Text('P${appointment.patientId}')),
                                    Expanded(child: Text('D${appointment.doctorId}')),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: appointment.status == 'confirmed'
                                              ? Colors.green.withOpacity(0.1)
                                              : appointment.status == 'cancelled'
                                              ? Colors.red.withOpacity(0.1)
                                              : Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          appointment.status,
                                          style: TextStyle(
                                            color: appointment.status == 'confirmed'
                                                ? Colors.green
                                                : appointment.status == 'cancelled'
                                                ? Colors.red
                                                : Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showAppointmentDialog(appointment: appointment),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () async {
                                              try {
                                                await _apiService.deleteAppointment(appointment.id!);
                                                _refreshAppointments();
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error: $e')),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showAppointmentDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}