class FundRequestModel {
  String id;
  double amount;
  String reason;
  String status; // 'Pending', 'Approved', 'Rejected'
  String date;
  String rejectionNote;

  FundRequestModel({
    required this.id,
    required this.amount,
    required this.reason,
    required this.status,
    required this.date,
    this.rejectionNote = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'reason': reason,
      'status': status,
      'date': date,
      'rejectionNote': rejectionNote,
    };
  }

  factory FundRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return FundRequestModel(
      id: id,
      amount: double.tryParse(map['amount'].toString()) ?? 0.0,
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'Pending',
      date: map['date'] ?? '',
      rejectionNote: map['rejectionNote'] ?? '',
    );
  }
}
