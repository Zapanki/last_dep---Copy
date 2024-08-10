import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:last_dep/screens/Home_screens/CreatePostScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> getUserData(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    } else {
      throw Exception("User not found");
    }
  }

  void _toggleLike(DocumentSnapshot post) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(post.id);
    final postDoc = await postRef.get();
    List likes = postDoc['likes'] ?? [];

    if (likes.contains(userId)) {
      // Remove like
      postRef.update({'likes': FieldValue.arrayRemove([userId])});
    } else {
      // Add like
      postRef.update({'likes': FieldValue.arrayUnion([userId])});
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, DocumentSnapshot post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deletion_confirmation),
          content: Text(AppLocalizations.of(context)!.are_you_sure_you_want_to_delete_the_post),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost(post);
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePost(DocumentSnapshot post) async {
    await FirebaseFirestore.instance.collection('posts').doc(post.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.home_page),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                var posts = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    if (!post.data().containsKey('userId')) {
                      return ListTile(
                        title: Text(AppLocalizations.of(context)!.invalid_post_user_id_not_found),
                      );
                    }
                    return FutureBuilder(
                      future: getUserData(post['userId']),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) return CircularProgressIndicator();
                        var userData = userSnapshot.data!;
                        bool isLiked = (post['likes'] ?? []).contains(FirebaseAuth.instance.currentUser!.uid);
                        int likeCount = (post['likes'] ?? []).length;
                        bool isOwner = post['userId'] == FirebaseAuth.instance.currentUser!.uid;

                        return Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(userData['photo_url'] ?? 'https://via.placeholder.com/150'),
                                ),
                                title: Text(userData['display_name'] ?? AppLocalizations.of(context)!.no_name),
                                trailing: isOwner
                                    ? IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => _showDeleteConfirmationDialog(context, post),
                                      )
                                    : null,
                              ),
                              Image.network(post['imageUrl']),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(post['caption']),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                                    onPressed: () => _toggleLike(post),
                                  ),
                                  Text('$likeCount likes'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
