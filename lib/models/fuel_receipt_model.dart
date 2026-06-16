class FuelReceiptModel {
  String id;
  String instructorId;
  String instructorName;
  String vehicleId;
  String vehiclePlate;
  String amount;
  String liters;
  String date;
  String receiptImageUrl;
  String status; // 'Pending', 'Approved', 'Rejected'

  FuelReceiptModel({
    required this.id,
    required this.instructorId,
    required this.instructorName,
    required this.vehicleId,
    required this.vehiclePlate,
    required this.amount,
    required this.liters,
    required this.date,
    required this.receiptImageUrl,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'vehicleId': vehicleId,
      'vehiclePlate': vehiclePlate,
      'amount': amount,
      'liters': liters,
      'date': date,
      'receiptImageUrl': receiptImageUrl,
      'status': status,
    };
  }

  factory FuelReceiptModel.fromMap(Map<String, dynamic> map, String id) {
    return FuelReceiptModel(
      id: id,
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      amount: map['amount'] ?? '',
      liters: map['liters'] ?? '',
      date: map['date'] ?? '',
      receiptImageUrl: map['receiptImageUrl'] ?? '',
      status: map['status'] ?? 'Pending',
    );
  }
}
