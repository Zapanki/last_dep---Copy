import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:last_dep/screens/messager/chat.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart'; // Импортируем пакет intl для форматирования времени

class UserList extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateChatRoomId(String user1Id, String user2Id) {
    // Генерация уникального chatRoomId
    return user1Id.compareTo(user2Id) < 0
        ? "$user1Id\_$user2Id"
        : "$user2Id\_$user1Id";
  }

  Future<Map<String, String>> _getLastMessageData(
      String chatRoomId, BuildContext context) async {
    // Получение последнего сообщения из чата и его времени
    QuerySnapshot querySnapshot = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var lastMessage = querySnapshot.docs.first['message'] as String;
      var timestamp = querySnapshot.docs.first['timestamp'] as Timestamp;

      // Форматируем время в часы и минуты
      var formattedTime = DateFormat('HH:mm').format(timestamp.toDate());

      return {'message': lastMessage, 'time': formattedTime};
    } else {
      return {
        'message': AppLocalizations.of(context)!.no_messages_yet,
        'time': ''
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _firebaseAuth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.choose_user),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var users = snapshot.data!.docs
              .where((doc) => doc.id != currentUserId)
              .toList();

          if (users.isEmpty) {
            return Center(
                child: Text(
                    AppLocalizations.of(context)!.no_other_users_available));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  users[index].data() as Map<String, dynamic>;
              String displayName =
                  data['display_name'] ?? AppLocalizations.of(context)!.no_name;
              String photoUrl = data['photo_url'] ??
                  "https://firebasestorage.googleapis.com/v0/b/last-dep.appspot.com/o/profile_images%2Fuserprofile.png?alt=media&token=ff97d361-d7e1-4845-8b5e-f5865b5522ae";

              // Генерация chatRoomId
              String chatRoomId =
                  _generateChatRoomId(currentUserId, users[index].id);

              return FutureBuilder<Map<String, String>>(
                future: _getLastMessageData(chatRoomId, context),
                builder: (context, messageSnapshot) {
                  if (messageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(photoUrl),
                      ),
                      title: Text(displayName),
                      subtitle:
                          Text(AppLocalizations.of(context)!.no_messages_yet),
                    );
                  }

                  String lastMessage = messageSnapshot.data?['message'] ??
                      AppLocalizations.of(context)!.no_messages_yet;
                  if (lastMessage.length > 22) {
                    lastMessage = lastMessage.substring(0, 22) + '...';
                  }
                  String time = messageSnapshot.data?['time'] ?? '';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(photoUrl),
                      ),
                      title: Text(displayName),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(lastMessage)),
                          if (time.isNotEmpty)
                            Text(time), // Отображаем время, если оно есть
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              receiverUserEmail: displayName,
                              receiverUserId: users[index].id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showUserSelection(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showUserSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            var users = snapshot.data!.docs
                .where((doc) => doc.id != _firebaseAuth.currentUser!.uid)
                .toList();

            if (users.isEmpty) {
              return Center(
                  child: Text(
                      AppLocalizations.of(context)!.no_other_users_available));
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    users[index].data() as Map<String, dynamic>;
                String displayName = data['display_name'] ??
                    AppLocalizations.of(context)!.no_name;
                String photoUrl = data['photo_url'] ??
                    "https://firebasestorage.googleapis.com/v0/b/last-dep.appspot.com/o/profile_images%2Fuserprofile.png?alt=media&token=ff97d361-d7e1-4845-8b5e-f5865b5522ae";

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  title: Text(displayName),
                  onTap: () {
                    Navigator.pop(context); // Закрываем bottom sheet
                    String chatRoomId = _generateChatRoomId(
                        _firebaseAuth.currentUser!.uid, users[index].id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiverUserEmail: displayName,
                          receiverUserId: users[index].id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
