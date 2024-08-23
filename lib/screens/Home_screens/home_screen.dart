import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:last_dep/screens/Home_screens/CreatePostScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> getUserData(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
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
      postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      // Add like
      postRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });
    }
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, DocumentSnapshot post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deletion_confirmation),
          content: Text(AppLocalizations.of(context)!
              .are_you_sure_you_want_to_delete_the_post),
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

  void _showFullImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(backgroundColor: Colors.transparent),
          backgroundColor: Colors.black,
          body: Center(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }

  void _addComment(String postId, String commentText) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

      // Создание объекта комментария
      Map<String, dynamic> commentData = {
        'commentText': commentText,
        'photo_url': user.photoURL ?? 'https://via.placeholder.com/150',
        'commentAuthor': user.displayName ?? 'Anonymous',
        'timestamp': Timestamp.now(),  // Время на сервере
      };

      // Обновление документа поста с добавлением комментария
      await postRef.update({
        'comments': FieldValue.arrayUnion([commentData])
      });
    }
  }

  void _showCommentOptionsDialog(BuildContext context, String postId, int commentIndex, String commentText, String commentAuthor) {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectAction),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.copy),
                title: Text(AppLocalizations.of(context)!.copyComment),
                onTap: () {
                  Navigator.of(context).pop();
                  Clipboard.setData(ClipboardData(text: commentText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.commentCopied)),
                  );
                },
              ),
              if (user != null && user.displayName == commentAuthor)
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text(AppLocalizations.of(context)!.deleteComment),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteCommentDialog(context, postId, commentIndex);
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCommentDialog(BuildContext context, String postId, int commentIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDelete),
          content: Text(AppLocalizations.of(context)!.confirmDeleteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteComment(postId, commentIndex);
              },
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }

  void _deleteComment(String postId, int commentIndex) async {
    DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    DocumentSnapshot postDoc = await postRef.get();
    List comments = postDoc['comments'];

    if (comments != null && comments.length > commentIndex) {
      comments.removeAt(commentIndex);
      await postRef.update({'comments': comments});
    }
  }

  void _showComments(BuildContext context, DocumentSnapshot post) {
    final TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.comments),
          content: Container(
            width: double.maxFinite,
            height: 300.0,
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(post.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      var postData = snapshot.data;
                      var comments = postData?['comments'] ?? [];

                      if (comments.isEmpty) {
                        return Center(
                            child: Text(AppLocalizations.of(context)!.noCommentsYet));
                      }

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final photoUrl = comment['photo_url'] ?? 'https://via.placeholder.com/150';

                          return ListTile(
                            title: Text(comment['commentAuthor']),
                            subtitle: Text(comment['commentText']),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(photoUrl),
                            ),
                            trailing: Text(
                              comment['timestamp'] != null
                                  ? DateFormat('dd MMM kk:mm')
                                      .format(comment['timestamp'].toDate())
                                  : '',
                            ),
                            onLongPress: () {
                              _showCommentOptionsDialog(
                                context,
                                post.id,
                                index,
                                comment['commentText'],
                                comment['commentAuthor'],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.addComment,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          _addComment(post.id, _commentController.text);
                          _commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
              stream:
                  FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                var posts = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    if (!post.data().containsKey('userId')) {
                      return ListTile(
                        title: Text(AppLocalizations.of(context)!
                            .invalid_post_user_id_not_found),
                      );
                    }
                    return FutureBuilder(
                      future: getUserData(post['userId']),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData)
                          return CircularProgressIndicator();
                        var userData = userSnapshot.data!;
                        bool isLiked = (post['likes'] ?? [])
                            .contains(FirebaseAuth.instance.currentUser!.uid);
                        int likeCount = (post['likes'] ?? []).length;
                        bool isOwner = post['userId'] ==
                            FirebaseAuth.instance.currentUser!.uid;

                        return Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      userData['photo_url'] ??
                                          'https://via.placeholder.com/150'),
                                ),
                                title: Text(userData['display_name'] ??
                                    AppLocalizations.of(context)!.no_name),
                                trailing: isOwner
                                    ? IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () =>
                                            _showDeleteConfirmationDialog(
                                                context, post),
                                      )
                                    : null,
                              ),
                              GestureDetector(
                                onTap: () => _showFullImage(
                                    context,
                                    post[
                                        'imageUrl']), // Open image in full screen on tap
                                child: Image.network(post['imageUrl']),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  post['caption'],
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border),
                                    onPressed: () => _toggleLike(post),
                                  ),
                                  Text('$likeCount likes'),
                                  IconButton(
                                    icon: Icon(Icons.comment),
                                    onPressed: () => _showComments(context, post),
                                  ),
                                  Text('${post['comments'].length} comments'),
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
