// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user.dart';
// import '../models/doctor.dart';
// import '../models/patient.dart';
// import '../models/appointment.dart';
//
// class ApiService {
//   static const String baseUrl = 'http://127.0.0.1:8000/api'; // Base URL adjusted
//
//   // Helper to get the stored token
//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
//
//   // Register
//   Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/register'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
//     );
//     return jsonDecode(response.body);
//   }
//
//   // Login
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/login'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email, 'password': password}),
//     );
//     final data = jsonDecode(response.body);
//     if (data['token'] != null) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('token', data['token']);
//     }
//     return data;
//   }
//
//   // Logout
//   Future<void> logout() async {
//     final token = await _getToken();
//     await http.post(
//       Uri.parse('$baseUrl/logout'),
//       headers: {'Authorization': 'Bearer $token'},
//     );
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//   }
//
//   // Fetch Doctors
//   Future<List<Doctor>> getDoctors() async {
//     final token = await _getToken();
//     final response = await http.get(
//       Uri.parse('$baseUrl/doctors'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((json) => Doctor.fromJson(json)).toList();
//     }
//     throw Exception('Failed to load doctors: ${response.statusCode}');
//   }
//
//   // Fetch Patients
//   Future<List<Patient>> getPatients() async {
//     final token = await _getToken();
//     final response = await http.get(
//       Uri.parse('$baseUrl/patients'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((json) => Patient.fromJson(json)).toList();
//     }
//     throw Exception('Failed to load patients: ${response.statusCode}');
//   }
//
//   // Fetch Appointments
//   Future<List<Appointment>> getAppointments() async {
//     final token = await _getToken();
//     final response = await http.get(
//       Uri.parse('$baseUrl/appointments'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((json) => Appointment.fromJson(json)).toList();
//     }
//     throw Exception('Failed to load appointments: ${response.statusCode}');
//   }
//
//   // Create Appointment
//   Future<Appointment> createAppointment(Appointment appointment) async {
//     final token = await _getToken();
//     final response = await http.post(
//       Uri.parse('$baseUrl/appointments'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//       body: jsonEncode(appointment.toJson()),
//     );
//     if (response.statusCode == 201) {
//       return Appointment.fromJson(jsonDecode(response.body));
//     }
//     throw Exception('Failed to create appointment: ${response.statusCode} - ${response.body}');
//   }
//
//   // Update Appointment
//   Future<Appointment> updateAppointment(Appointment appointment) async {
//     final token = await _getToken();
//     final response = await http.put(
//       Uri.parse('$baseUrl/appointments/${appointment.id}'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//       body: jsonEncode(appointment.toJson()),
//     );
//     if (response.statusCode == 200) {
//       return Appointment.fromJson(jsonDecode(response.body));
//     }
//     throw Exception('Failed to update appointment: ${response.statusCode} - ${response.body}');
//   }
//
//   // Delete Appointment
//   Future<void> deleteAppointment(int id) async {
//     final token = await _getToken();
//     final response = await http.delete(
//       Uri.parse('$baseUrl/appointments/$id'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete appointment: ${response.statusCode} - ${response.body}');
//     }
//   }
//
//   // Fetch Single Appointment
//   Future<Appointment> getAppointment(int id) async {
//     final token = await _getToken();
//     final response = await http.get(
//       Uri.parse('$baseUrl/appointments/$id'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );
//     if (response.statusCode == 200) {
//       return Appointment.fromJson(jsonDecode(response.body));
//     }
//     throw Exception('Failed to load appointment: ${response.statusCode}');
//   }
// }

// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/appointment.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Updated base URL

  // Helper to get the stored token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Authentication methods
  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
    }
    return data;
  }

  Future<void> logout() async {
    final token = await _getToken();
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Original Doctor methods with authentication
  Future<List<Doctor>> getDoctors() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/doctors'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Doctor.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load doctors: ${response.statusCode}');
    }
  }

  Future<Doctor> createDoctor(Doctor doctor) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/doctors'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(doctor.toJson()),
    );

    if (response.statusCode == 201) {
      return Doctor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create doctor: ${response.statusCode}');
    }
  }

  Future<Doctor> getDoctor(String id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/doctors/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Doctor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load doctor: ${response.statusCode}');
    }
  }

  Future<Doctor> updateDoctor(String id, Doctor doctor) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/doctors/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(doctor.toJson()),
    );

    if (response.statusCode == 200) {
      return Doctor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update doctor: ${response.statusCode}');
    }
  }

  Future<void> deleteDoctor(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/doctors/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete doctor: ${response.statusCode}');
    }
  }

  // Additional methods for Patients
  Future<List<Patient>> getPatients() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/patients'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Patient.fromJson(json)).toList();
    }
    throw Exception('Failed to load patients: ${response.statusCode}');
  }

  // Additional methods for Appointments
  Future<List<Appointment>> getAppointments() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/appointments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    }
    throw Exception('Failed to load appointments: ${response.statusCode}');
  }

  Future<Appointment> createAppointment(Appointment appointment) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(appointment.toJson()),
    );
    if (response.statusCode == 201) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create appointment: ${response.statusCode} - ${response.body}');
  }

  Future<Appointment> updateAppointment(Appointment appointment) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/appointments/${appointment.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(appointment.toJson()),
    );
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update appointment: ${response.statusCode} - ${response.body}');
  }

  Future<void> deleteAppointment(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete appointment: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Appointment> getAppointment(int id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load appointment: ${response.statusCode}');
  }
}