class InstructorLeaveModel {
  String id;
  String instructorId;
  String instructorName;
  String startDate;
  String endDate;
  String reason;
  String status; // 'Pending', 'Approved', 'Rejected'
  String appliedOn;

  InstructorLeaveModel({
    required this.id,
    required this.instructorId,
    required this.instructorName,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.appliedOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
      'status': status,
      'appliedOn': appliedOn,
    };
  }

  factory InstructorLeaveModel.fromMap(Map<String, dynamic> map, String id) {
    return InstructorLeaveModel(
      id: id,
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? 'Unknown',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'Pending',
      appliedOn: map['appliedOn'] ?? '',
    );
  }
}
