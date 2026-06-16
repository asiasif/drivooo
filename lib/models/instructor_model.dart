class InstructorModel {
  String instructorID;
  String instructorName;
  int instructorNumber;
  String? instructorEmail;
  String? instructorProPic;
  String status;
  String? upiId;

  InstructorModel({
    required this.instructorID,
    required this.instructorName,
    required this.instructorNumber,
    this.instructorEmail,
    this.instructorProPic,
    this.status = 'Available',
    this.upiId,
  });

  factory InstructorModel.fromMap(Map<String, dynamic> map) {
    return InstructorModel(
      instructorID: map['instructorID'],
      instructorName: map['instructorName'],
      instructorNumber: map['instructorNumber'],
      instructorEmail: map['instructorEmail'],
      instructorProPic: map['instructorProPic'],
      status: map['status'] ?? 'Available',
      upiId: map['upiId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'instructorID': instructorID,
      'instructorName': instructorName,
      'instructorNumber': instructorNumber,
      'instructorEmail': instructorEmail,
      'instructorProPic': instructorProPic,
      'status': status,
      'upiId': upiId,
    };
  }
}
