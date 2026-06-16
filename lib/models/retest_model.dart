
class RetestModel {
  String id;
  String userId;
  String userName;
  String phoneNumber;
  String learnersNumber;
  List<dynamic> selectedTests;
  double amount;
  String date;
  String paymentStatus;
  String testDate; // Added for scheduling

  RetestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.phoneNumber,
    required this.learnersNumber,
    required this.selectedTests,
    required this.amount,
    required this.date,
    required this.paymentStatus,
    this.testDate = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'learnersNumber': learnersNumber,
      'selectedTests': selectedTests,
      'amount': amount,
      'date': date,
      'paymentStatus': paymentStatus,
      'testDate': testDate,
    };
  }

  factory RetestModel.fromMap(Map<String, dynamic> map) {
    return RetestModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      learnersNumber: map['learnersNumber'] ?? '',
      selectedTests: map['selectedTests'] ?? [],
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: map['date'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
      testDate: map['testDate'] ?? '',
    );
  }
}
