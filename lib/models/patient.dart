class Patient {
  final int id;
  final int userId;
  final String phone;
  final DateTime? dateOfBirth;

  Patient({
    required this.id,
    required this.userId,
    required this.phone,
    this.dateOfBirth,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      userId: json['user_id'],
      phone: json['phone'] ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'user_id': userId,
  //     'phone': phone,
  //     'date_of_birth': dateOfBirth?.toIso8601String(),
  //   };
  // }
}