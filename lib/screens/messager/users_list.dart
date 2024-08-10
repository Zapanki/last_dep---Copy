import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:last_dep/screens/messager/chat.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class UserList extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

          var users = snapshot.data!.docs.where((doc) => doc.id != currentUserId).toList();

          if (users.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.no_other_users_available));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = users[index].data() as Map<String, dynamic>;
              String displayName = data['display_name'] ?? AppLocalizations.of(context)!.no_name;
              String photoUrl = data['photo_url'] ?? "https://firebasestorage.googleapis.com/v0/b/last-dep.appspot.com/o/profile_images%2Fuserprofile.png?alt=media&token=ff97d361-d7e1-4845-8b5e-f5865b5522ae"; 

              return Card(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  title: Text(displayName),
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
      ),
    );
  }
}