import 'package:intl/intl.dart';

class UserModel {
  String userID;
  String userName;
  String userEmail;
  int userNumber;
  String? userProPic;
  String? selectedCourse;
  String? selectedInstructor;
  String? instructorSelectionDate;
  List? userAttendance;
  bool? hasUnreadMessages;
  bool? isCourseCompleted;

  UserModel({
    required this.userID,
    required this.userName,
    required this.userEmail,
    required this.userNumber,
    this.userProPic,
    this.selectedCourse,
    this.selectedInstructor,
    this.instructorSelectionDate,
    this.userAttendance,
    this.hasUnreadMessages,
    this.isCourseCompleted,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String? assignedInstructor = map['selectedInstructor'];
    String? assignedDate = map['instructorSelectionDate'];

    // DAILY RESET: If the instructor was selected on a previous day, reset it locally.
    if (assignedInstructor != null && assignedInstructor != 'No Instructor Selected') {
      if (assignedDate != today) {
        assignedInstructor = 'No Instructor Selected';
        assignedDate = null;
      }
    }

    return UserModel(
      userID: map['userID'],
      userName: map['userName'],
      userEmail: map['userEmail'],
      userNumber: map['userNumber'],
      userProPic: map['userProPic'],
      selectedCourse: map['selectedCourse'],
      selectedInstructor: assignedInstructor,
      instructorSelectionDate: assignedDate,
      userAttendance: map['userAttendance'] ?? [],
      hasUnreadMessages: map['hasUnreadMessages'] ?? false,
      isCourseCompleted: map['isCourseCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'userName': userName,
      'userEmail': userEmail,
      'userNumber': userNumber,
      'userProPic': userProPic,
      'selectedCourse': selectedCourse,
      'selectedInstructor': selectedInstructor,
      'instructorSelectionDate': instructorSelectionDate,
      'userAttendance': userAttendance,
      'hasUnreadMessages': hasUnreadMessages,
      'isCourseCompleted': isCourseCompleted,
    };
  }
}
