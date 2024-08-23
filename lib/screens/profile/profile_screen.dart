import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:last_dep/screens/registration_and_login/login_screen.dart';
import 'package:last_dep/screens/Home_screens/CreatePostScreen.dart';
import 'package:last_dep/screens/settings/settings_screen.dart';
import 'package:last_dep/screens/settings/theme/theme_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final User? user;

  ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _displayNameController;
  late TextEditingController _statusController;
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _profileImageUrl;

  Future<Map<String, dynamic>?> _getUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user!.uid)
        .get();
    if (!doc.exists) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .set({
        'display_name': widget.user!.displayName ?? 'No display name',
        'phone_number': widget.user!.phoneNumber ?? 'No phone number',
        'photo_url': widget.user!.photoURL ?? '',
        'status': 'nothing here',
        'theme': 'light', // Установка темы по умолчанию
      });
      doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .get();
    }
    return doc.data() as Map<String, dynamic>?;
  }

  Future<void> _addComment(String postId, String commentText) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);

      // Создание объекта комментария
      Map<String, dynamic> commentData = {
        'commentText': commentText,
        'photo_url': user.photoURL ?? 'assets/images/userprofile.png',
        'commentAuthor': user.displayName,
        'timestamp': Timestamp.now(), // Время на сервере
      };

      // Обновление документа поста с добавлением комментария
      await postRef.update({
        'comments': FieldValue.arrayUnion([commentData])
      });

      _commentController.clear();
    }
  }

  Future<void> _deleteComment(String postId, int commentIndex) async {
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('posts').doc(postId);

    DocumentSnapshot postSnapshot = await postRef.get();
    List<dynamic> comments = postSnapshot['comments'];

    comments.removeAt(commentIndex);

    await postRef.update({'comments': comments});
  }

  void _showDeleteCommentDialog(String postId, int commentIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deletion_confirmation_comment),
          content: Text(AppLocalizations.of(context)!.deletion_confirmation_comment),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.no),
            ),
            TextButton(
              onPressed: () async {
                await _deleteComment(postId, commentIndex);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.yes),
            ),
          ],
        );
      },
    );
  }

  void _showCommentOptionsDialog(BuildContext context, String postId,
      int commentIndex, String commentText, String commentAuthor) {
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
                    SnackBar(
                        content:
                            Text(AppLocalizations.of(context)!.commentCopied)),
                  );
                },
              ),
              if (user != null && user.displayName == commentAuthor)
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text(AppLocalizations.of(context)!.deleteComment),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteCommentDialog(postId, commentIndex);
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

  void _showComments(DocumentSnapshot post) {
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
                            child: Text(
                                AppLocalizations.of(context)!.noCommentsYet));
                      }

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final photoUrl = comment['photo_url'] ??
                              'assets/images/userprofile.png';

                          return ListTile(
                            title: Text(comment['commentAuthor']),
                            subtitle: Text(comment['commentText']),
                            leading: CircleAvatar(
                              backgroundImage: photoUrl.startsWith('http')
                                  ? NetworkImage(photoUrl)
                                  : AssetImage('assets/images/userprofile.png')
                                      as ImageProvider,
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

  void _updateUserData(String field, String value) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .update({
        field: value,
      });
      if (field == 'display_name') {
        await widget.user!.updateDisplayName(value);
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.updateSuccess)));
      setState(() {}); // Обновить интерфейс
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${AppLocalizations.of(context)!.updateFailed} ${e.toString()}')));
    }
  }

  void _showEditDialog(String field, String initialValue) {
    final _controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              '${AppLocalizations.of(context)!.edit} ${field == "display_name" ? AppLocalizations.of(context)!.name : field == "phone_number" ? AppLocalizations.of(context)!.phoneNumber : AppLocalizations.of(context)!.status}'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: field == "display_name"
                  ? AppLocalizations.of(context)!.enterNewName
                  : field == "phone_number"
                      ? AppLocalizations.of(context)!.enterNewPhoneNumber
                      : AppLocalizations.of(context)!.enterNewStatus,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                _updateUserData(field, _controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadImageToFirebase();
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_imageFile == null) return;

    try {
      String fileName = path.basename(_imageFile!.path);
      Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(_imageFile!);
      await uploadTask.whenComplete(() async {
        String downloadURL = await storageReference.getDownloadURL();
        await _updateUserProfileImage(downloadURL);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${AppLocalizations.of(context)!.imageUploadFailed} ${e.toString()}')));
    }
  }

  Future<void> _updateUserProfileImage(String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .update({
        'photo_url': imageUrl,
      });
      await widget.user!.updatePhotoURL(imageUrl);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.imageUpdatedSuccessfully)));
      setState(() {
        _profileImageUrl = imageUrl; // Обновить URL изображения в состоянии
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${AppLocalizations.of(context)!.imageUpdateFailed} ${e.toString()}')));
    }
  }

  void _toggleLike(DocumentSnapshot post) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(post.id);
    final postDoc = await postRef.get();
    List likes = postDoc['likes'] ?? [];

    if (likes.contains(userId)) {
      postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
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
          title: Text(AppLocalizations.of(context)!.confirmDelete),
          content: Text(AppLocalizations.of(context)!.confirmDeleteMessage),
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

  void _showUserSelection(BuildContext context, DocumentSnapshot post) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            var users = snapshot.data!.docs
                .where(
                    (doc) => doc.id != FirebaseAuth.instance.currentUser!.uid)
                .toList();

            if (users.isEmpty) {
              return Center(
                  child: Text(
                      AppLocalizations.of(context)!.no_other_users_available));
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> userData =
                    users[index].data() as Map<String, dynamic>;
                String displayName = userData['display_name'] ?? 'Unknown';
                String photoUrl = userData['photo_url'] ??
                    "https://firebasestorage.googleapis.com/v0/b/last-dep.appspot.com/o/profile_images%2Fuserprofile.png?alt=media&token=ff97d361-d7e1-4845-8b5e-f5865b5522ae";
                String userId = users[index].id;

                return ListTile(
                  title: Text(displayName),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  trailing: ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.send),
                    onPressed: () {
                      _sendPostToChat(userId, post);
                      Navigator.pop(context); // Close the bottom sheet
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _sendPostToChat(String receiverUserId, DocumentSnapshot post) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final String currentUserEmail =
        FirebaseAuth.instance.currentUser!.email ?? 'Unknown';
    final String currentUserName = await _getUserName(currentUserId);
    final Timestamp timestamp = Timestamp.now();

    // Create the message content for the post
    String message =
        '${AppLocalizations.of(context)!.sharedPost}: ${post['caption']}';
    String imageUrl = post['imageUrl'];

    // Send the post as a message
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(_generateChatRoomId(currentUserId, receiverUserId))
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'senderEmail': currentUserEmail,
      'senderName': currentUserName,
      'message': message,
      'timestamp': timestamp,
      'isFile': true,
      'fileUrl': imageUrl,
      'postCaption': post['caption'],
      'postAuthor': currentUserName,
    });
  }

  String _generateChatRoomId(String user1Id, String user2Id) {
    return user1Id.compareTo(user2Id) < 0
        ? "$user1Id\_$user2Id"
        : "$user2Id\_$user1Id";
  }

  Future<String> _getUserName(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['display_name'] ?? 'Unknown';
  }

  void _showRepostOptions(BuildContext context, DocumentSnapshot post) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.share),
              title: Text(AppLocalizations.of(context)!.repostToProfile),
              onTap: () {
                Navigator.pop(context);
                _showRepostConfirmationDialog(post);
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text(AppLocalizations.of(context)!.sendToChat),
              onTap: () {
                Navigator.pop(context);
                _showUserSelection(context, post);
              },
            ),
          ],
        );
      },
    );
  }

  void _showRepostConfirmationDialog(DocumentSnapshot post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmRepost),
          content: Text(AppLocalizations.of(context)!.confirmRepostMessage),
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
                _repostToProfile(post);
              },
            ),
          ],
        );
      },
    );
  }

  void _repostToProfile(DocumentSnapshot post) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('posts').add({
      'userId': user!.uid,
      'originalPostId': post.id,
      'caption': post['caption'],
      'imageUrl': post['imageUrl'],
      'timestamp': FieldValue.serverTimestamp(),
      "likes": [],
    });
  }

  void _showUserDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.userDetails),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.email),
                title: Text(AppLocalizations.of(context)!.email),
                subtitle: Text(widget.user?.email ??
                    AppLocalizations.of(context)!.noEmail),
              ),
              GestureDetector(
                onTap: () => _showEditDialog('status', _statusController.text),
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text(AppLocalizations.of(context)!.status),
                  subtitle: Text(_statusController.text),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    _showEditDialog('phone_number', _phoneController.text),
                child: ListTile(
                  leading: Icon(Icons.phone),
                  title: Text(AppLocalizations.of(context)!.phoneNumber),
                  subtitle: Text(_phoneController.text.isEmpty
                      ? AppLocalizations.of(context)!.noPhoneNumber
                      : _phoneController.text),
                ),
              ),
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text(AppLocalizations.of(context)!.memberSince),
                subtitle: Text(
                    widget.user?.metadata.creationTime?.toLocal().toString() ??
                        AppLocalizations.of(context)!.na),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _displayNameController = TextEditingController();
    _statusController =
        TextEditingController(); // Инициализация контроллера статуса
    _profileImageUrl = widget.user?.photoURL; // Инициализация URL изображения
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _displayNameController.dispose();
    _statusController.dispose(); // Освобождение контроллера статуса
    super.dispose();
  }

  Future<void> _logoutUser() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Reset any additional user-specific settings or data here

      // Navigate back to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.logoutFailed} ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              final themeProvider =
                  Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.setThemeMode(
                  ThemeMode.light); // Сброс темы на значение по умолчанию
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final userData = snapshot.data;
              if (userData != null) {
                _phoneController.text = userData['phone_number'] ?? '';
                _displayNameController.text = userData['display_name'] ?? '';
                _statusController.text =
                    userData['status'] ?? ''; // Заполнение поля статуса
                _profileImageUrl =
                    userData['photo_url'] ?? widget.user?.photoURL;
              } else {
                _phoneController.text = widget.user?.phoneNumber ?? '';
                _displayNameController.text = widget.user?.displayName ?? '';
                _statusController.text = AppLocalizations.of(context)!
                    .nothingHere; // Заполнение поля статуса по умолчанию
                _profileImageUrl = widget.user?.photoURL;
              }

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : AssetImage('assets/images/userprofile.png')
                              as ImageProvider,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _showEditDialog('display_name',
                        _displayNameController.text), // Редактирование имени
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text(AppLocalizations.of(context)!.name),
                          subtitle: Text(_displayNameController.text),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showEditDialog('status',
                        _statusController.text), // Редактирование статуса
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.info),
                          title: Text(AppLocalizations.of(context)!.status),
                          subtitle: Text(_statusController.text),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _showUserDetailsDialog,
                    child: Text(AppLocalizations.of(context)!.allInformation),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('userId', isEqualTo: widget.user!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      var posts = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          var post = posts[index];
                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(post['caption']),
                                  subtitle:
                                      post.data().containsKey('originalPostId')
                                          ? Text(AppLocalizations.of(context)!
                                              .reposted)
                                          : Text(AppLocalizations.of(context)!
                                              .originalPost),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.thumb_up),
                                        onPressed: () => _toggleLike(post),
                                      ),
                                      Text('${post['likes'].length}'),
                                      IconButton(
                                        icon: Icon(Icons.comment),
                                        onPressed: () => _showComments(post),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () =>
                                            _showDeleteConfirmationDialog(
                                                context, post),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.share),
                                        onPressed: () =>
                                            _showRepostOptions(context, post),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.network(post['imageUrl']),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePostScreen()),
                );
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
