import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;

  const ChatScreen({
    Key? key,
    required this.receiverUserEmail,
    required this.receiverUserId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  DocumentSnapshot? _replyingToMessage;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        _sendFile(filePath);
      }
    }
  }

  Future<void> _sendFile(String filePath) async {
    File file = File(filePath);
    String fileName = path.basename(file.path);
    Reference storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    _sendMessage(downloadUrl, isFile: true);
  }

  void _sendMessage(String content, {bool isFile = false}) async {
    if (content.isNotEmpty) {
      String currentUserId = _firebaseAuth.currentUser!.uid;
      String currentUserEmail = _firebaseAuth.currentUser!.email ?? 'Unknown';
      String currentUserName = await _getUserName(currentUserId);
      DocumentReference messageRef = FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(_generateChatRoomId(currentUserId, widget.receiverUserId))
          .collection('messages')
          .doc();

      String? replyToId = _replyingToMessage?.id;

      await messageRef.set({
        'senderId': currentUserId,
        'senderEmail': currentUserEmail,
        'senderName': currentUserName,
        'message': content,
        'timestamp': Timestamp.now(),
        'isFile': isFile,
        'fileUrl': isFile ? content : null,
        'replyingTo': _replyingToMessage?['senderName'],
        'replyText': _replyingToMessage?['message'],
        'replyToId': replyToId, // Store the message ID this message replies to
      });

      setState(() {
        _messageController.clear();
        _replyingToMessage = null;
      });
    }
  }

  Future<String> _getUserName(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['display_name'] ?? 'Unknown';
  }

  void _showMessageOptionsDialog(DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Option"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _replyToMessage(document);
              },
              child: Row(
                children: [
                  Icon(Icons.reply),
                  SizedBox(width: 8),
                  Text("Reply"),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _copyMessage(document);
              },
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text("Copy"),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteMessage(document.id);
              },
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text("Delete"),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _replyToMessage(DocumentSnapshot message) {
    setState(() {
      _replyingToMessage = message;
    });
  }

  void _copyMessage(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    Clipboard.setData(ClipboardData(text: data['message'] ?? ''));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message copied")));
  }

  void _deleteMessage(String messageId) async {
    String currentUserId = _firebaseAuth.currentUser!.uid;
    String chatRoomId = _generateChatRoomId(currentUserId, widget.receiverUserId);

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  String _generateChatRoomId(String user1Id, String user2Id) {
    return user1Id.compareTo(user2Id) < 0 ? "$user1Id\_$user2Id" : "$user2Id\_$user1Id";
  }

  Widget _buildMessageList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(_generateChatRoomId(_firebaseAuth.currentUser!.uid, widget.receiverUserId))
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text("No messages yet"));
      }
      return ListView.builder(
        reverse: true,
        controller: _scrollController,
        padding: EdgeInsets.all(10),
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final document = snapshot.data!.docs[index];
          return _buildMessageItem(document);
        },
      );
    },
  );
}


  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isFile = data['isFile'] ?? false;
    String? replyToId = data['replyToId']; // Get the ID of the replied-to message

    // Retrieve and format the timestamp
    Timestamp timestamp = data['timestamp'];
    String formattedTime = DateFormat('HH:mm').format(timestamp.toDate());

    var alignment = (data['senderId'] == FirebaseAuth.instance.currentUser!.uid)
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    var containerAlignment = (data['senderId'] == FirebaseAuth.instance.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return GestureDetector(
      onLongPress: () => _showMessageOptionsDialog(document), // Open options on long press
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        alignment: containerAlignment,
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
              decoration: BoxDecoration(
                color: (data['senderId'] == FirebaseAuth.instance.currentUser!.uid)
                    ? Colors.grey[300]
                    : Colors.blue[200],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (replyToId != null) ...[
                    GestureDetector(
                      onTap: () => _scrollToMessage(replyToId,), // Scroll to the message
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['replyingTo'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12, // Smaller font size
                                  color: Colors.black,
                                )),
                            SizedBox(height: 4),
                            Text(data['replyText'] ?? '',
                                style: TextStyle(
                                  fontSize: 12, // Smaller font size
                                  color: Colors.black,
                                )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8), // Add a bit of space between the reply and the main message
                  ],
                  if (isFile) ...[
                    if (data['fileUrl'] != null)
                      Image.network(data['fileUrl'], fit: BoxFit.cover),
                    SizedBox(height: 5),
                    Text(data['postAuthor'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(data['postCaption'] ?? ''),
                  ] else ...[
                    Text(data['message'] ?? ''),
                  ],
                  SizedBox(height: 4), // Add space between the message and the timestamp
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollToMessage(String messageId) {
  FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(_generateChatRoomId(_firebaseAuth.currentUser!.uid, widget.receiverUserId))
      .collection('messages')
      .get()
      .then((querySnapshot) {
    final messageIndex = querySnapshot.docs.indexWhere((doc) => doc.id == messageId);
    if (messageIndex != -1) {
      final position = messageIndex * 72.0;  // Assuming an average height of 72.0 for each message
      _scrollController.animateTo(
        position,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  });
}


  Widget _buildMessageInput() {
    return Column(
      children: [
        if (_replyingToMessage != null) ...[
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Row(
              children: [
                Icon(Icons.reply, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Replying to: ${_replyingToMessage!['senderName']}',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _replyingToMessage = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.attach_file),
                onPressed: _pickFile,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _sendMessage(_messageController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverUserEmail)),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
