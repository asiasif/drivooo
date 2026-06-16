import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceReceiptModel {
  String id;
  String instructorId;
  String instructorName;
  String vehicleId;
  String vehiclePlate;
  double amount;
  String description;
  String imageUrl;
  DateTime date;
  String status;

  MaintenanceReceiptModel({
    required this.id,
    required this.instructorId,
    required this.instructorName,
    required this.vehicleId,
    required this.vehiclePlate,
    required this.amount,
    required this.description,
    required this.imageUrl,
    required this.date,
    this.status = 'Pending', // Pending, Approved, Rejected
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'vehicleId': vehicleId,
      'vehiclePlate': vehiclePlate,
      'amount': amount,
      'description': description,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }

  factory MaintenanceReceiptModel.fromMap(Map<String, dynamic> map, String docId) {
    return MaintenanceReceiptModel(
      id: docId,
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? 'Unknown',
      vehicleId: map['vehicleId'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? 'Unknown',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: map['status'] ?? 'Pending',
    );
  }
}
