import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class Message {
  final String senderId;
  final String senderEmail;
  final String senderName;
  final String message;
  final Timestamp timestamp;
  final String receiverId;
  final bool isFile; // Добавьте это поле
  final String? fileName; // Добавьте это поле, если нужно сохранять имя файла
  final String? imageUrl;      // New: Image URL for the post
  final String? postAuthor;    // New: Author of the original post
  final String? postDescription;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.receiverId,
    this.isFile = false, // Значение по умолчанию — false
    this.fileName, // Это поле может быть null, если сообщение — не файл
    this.imageUrl,            // New: Initialize this
    this.postAuthor,          // New: Initialize this
    this.postDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'receiverId': receiverId,
      'isFile': isFile, // Добавьте это в Map
      'fileName': fileName, // Добавьте это в Map, если нужно
      'imageUrl': imageUrl,            // New: Convert this to map
      'postAuthor': postAuthor,        // New: Convert this to map
      'postDescription': postDescription,
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
      isFile: map['isFile'] ?? false, // Добавьте это в Map
      fileName: map['fileName'], // Добавьте это в Map, если нужно
      imageUrl: map['imageUrl'],            // New: Convert this to map
      postAuthor: map['postAuthor'],        // New: Convert this to map
      postDescription: map['postDescription'],
    );
  }
}
