class TripLogModel {
  final String id;
  final String vehicleId;
  final String vehiclePlate;
  final String instructorId;
  final String instructorName;
  final String destination;
  final int startKm;
  final int endKm;
  final DateTime tripDate;
  final String startTime;
  final String endTime;

  TripLogModel({
    required this.id,
    required this.vehicleId,
    required this.vehiclePlate,
    required this.instructorId,
    required this.instructorName,
    required this.destination,
    required this.startKm,
    required this.endKm,
    required this.tripDate,
    required this.startTime,
    required this.endTime,
  });

  int get distanceCovered => endKm - startKm;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehiclePlate': vehiclePlate,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'destination': destination,
      'startKm': startKm,
      'endKm': endKm,
      'tripDate': tripDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory TripLogModel.fromMap(Map<String, dynamic> map, String id) {
    return TripLogModel(
      id: id,
      vehicleId: map['vehicleId'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? '',
      destination: map['destination'] ?? '',
      startKm: map['startKm'] ?? 0,
      endKm: map['endKm'] ?? 0,
      tripDate: map['tripDate'] != null
          ? DateTime.tryParse(map['tripDate']) ?? DateTime.now()
          : DateTime.now(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
    );
  }
}
