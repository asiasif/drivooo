class RcRenewalModel {
  String id;
  String userId;
  String userName;
  String phoneNumber;
  String rcNumber;
  String expiryDate;
  String applicationDate;
  String status;
  String vehicleClass;
  String idProofUrl;
  double amount;
  String paymentStatus;
  String engineNumber;
  String chassisNumber;
  String pollutionCertificateUrl;

  RcRenewalModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.phoneNumber,
    required this.rcNumber,
    required this.expiryDate,
    required this.applicationDate,
    required this.status,
    required this.vehicleClass,
    required this.idProofUrl,
    required this.amount,
    required this.paymentStatus,
    required this.engineNumber,
    required this.chassisNumber,
    required this.pollutionCertificateUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'rcNumber': rcNumber,
      'expiryDate': expiryDate,
      'applicationDate': applicationDate,
      'status': status,
      'vehicleClass': vehicleClass,
      'idProofUrl': idProofUrl,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'engineNumber': engineNumber,
      'chassisNumber': chassisNumber,
      'pollutionCertificateUrl': pollutionCertificateUrl,
    };
  }

  factory RcRenewalModel.fromMap(Map<String, dynamic> map) {
    return RcRenewalModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      rcNumber: map['rcNumber'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      applicationDate: map['applicationDate'] ?? '',
      status: map['status'] ?? '',
      vehicleClass: map['vehicleClass'] ?? '',
      idProofUrl: map['idProofUrl'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? '',
      engineNumber: map['engineNumber'] ?? '',
      chassisNumber: map['chassisNumber'] ?? '',
      pollutionCertificateUrl: map['pollutionCertificateUrl'] ?? '',
    );
  }
}
