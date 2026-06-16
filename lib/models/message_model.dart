import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String senderId;
  String text;
  DateTime timestamp;
  bool isRead;

  MessageModel({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isRead,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
