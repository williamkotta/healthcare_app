class Appointment {
  final int? id;
  final int patientId;
  final int doctorId;
  final String appointmentTime;
  final String status;
  final String? notes;

  Appointment({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentTime,
    required this.status,
    this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      appointmentTime: json['appointment_time'],
      status: json['status'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'patient_id': patientId,
    'doctor_id': doctorId,
    'appointment_time': appointmentTime,
    'status': status,
    if (notes != null) 'notes': notes,
  };
}