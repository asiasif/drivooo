class SalaryModel {
  final String id;
  final String instructorId;
  final String instructorName;
  final String instructorUpiId;
  final double amount;
  final String monthYear; // e.g. "March 2026"
  final String status;    // "Pending" | "Paid"
  final String? paidAt;   // ISO timestamp when marked paid

  SalaryModel({
    required this.id,
    required this.instructorId,
    required this.instructorName,
    required this.instructorUpiId,
    required this.amount,
    required this.monthYear,
    this.status = 'Pending',
    this.paidAt,
  });

  factory SalaryModel.fromMap(Map<String, dynamic> map, String docId) {
    return SalaryModel(
      id: docId,
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? '',
      instructorUpiId: map['instructorUpiId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      monthYear: map['monthYear'] ?? '',
      status: map['status'] ?? 'Pending',
      paidAt: map['paidAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'instructorUpiId': instructorUpiId,
      'amount': amount,
      'monthYear': monthYear,
      'status': status,
      'paidAt': paidAt,
    };
  }
}
