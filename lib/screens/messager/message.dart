import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String senderName;
  final String message;
  final Timestamp timestamp;
  final String receiverId;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.receiverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'receiverId': receiverId,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      receiverId: map['receiverId'] ?? '',
    );
  }
}
