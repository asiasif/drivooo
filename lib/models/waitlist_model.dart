import 'package:cloud_firestore/cloud_firestore.dart';

class WaitlistModel {
  String waitlistID;
  String slotID;
  String date;
  String userID;
  String fcmToken;
  Timestamp createdAt;

  WaitlistModel({
    required this.waitlistID,
    required this.slotID,
    required this.date,
    required this.userID,
    required this.fcmToken,
    required this.createdAt,
  });

  factory WaitlistModel.fromMap(Map<String, dynamic> map) {
    return WaitlistModel(
      waitlistID: map['waitlistID'] ?? '',
      slotID: map['slotID'] ?? '',
      date: map['date'] ?? '',
      userID: map['userID'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'waitlistID': waitlistID,
      'slotID': slotID,
      'date': date,
      'userID': userID,
      'fcmToken': fcmToken,
      'createdAt': createdAt,
    };
  }
}
