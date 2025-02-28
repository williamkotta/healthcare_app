// class Doctor {
//   final int id;
//   final int userId;
//   final String specialization;
//   final String? phone;
//
//   Doctor({required this.id, required this.userId, required this.specialization, this.phone});
//
//   factory Doctor.fromJson(Map<String, dynamic> json) {
//     return Doctor(
//       id: json['id'],
//       userId: json['user_id'],
//       specialization: json['specialization'],
//       phone: json['phone'],
//     );
//   }
// }

// doctor.dart
class Doctor {
  final int? id;
  final int userId;
  final String specialization;
  final String? phone;
  final User? user; // Assuming there's a related User model

  Doctor({
    this.id,
    required this.userId,
    required this.specialization,
    this.phone,
    this.user,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      userId: json['user_id'],
      specialization: json['specialization'],
      phone: json['phone'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'specialization': specialization,
      'phone': phone,
    };
  }
}

// Simple User model (adjust according to your actual user structure)
class User {
  final int id;
  final String name; // Add other user fields as needed

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '', // Adjust based on your user fields
    );
  }
}