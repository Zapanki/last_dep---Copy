import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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
        'status': 'Nothing here',
        'theme': 'light', // Установка темы по умолчанию
      });
      doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .get();
    }
    return doc.data() as Map<String, dynamic>?;
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.updateFailed} ${e.toString()}')));
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.imageUploadFailed} ${e.toString()}')));
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.imageUpdatedSuccessfully)));
      setState(() {
        _profileImageUrl = imageUrl; // Обновить URL изображения в состоянии
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${AppLocalizations.of(context)!.imageUpdateFailed} ${e.toString()}')));
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
                _repostToProfile(post);
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text(AppLocalizations.of(context)!.sendToChat),
              onTap: () {
                // Логика отправки в чат
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
                subtitle: Text(widget.user?.email ?? AppLocalizations.of(context)!.noEmail),
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
        SnackBar(content: Text('${AppLocalizations.of(context)!.logoutFailed} ${e.toString()}')),
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
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.setThemeMode(ThemeMode.light); // Сброс темы на значение по умолчанию
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
                _statusController.text = userData['status'] ??
                    AppLocalizations.of(context)!.nothingHere; // Заполнение поля статуса
                _profileImageUrl =
                    userData['photo_url'] ?? widget.user?.photoURL;
              } else {
                _phoneController.text = widget.user?.phoneNumber ?? '';
                _displayNameController.text = widget.user?.displayName ?? '';
                _statusController.text =
                    AppLocalizations.of(context)!.nothingHere; // Заполнение поля статуса по умолчанию
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
                                          ? Text(AppLocalizations.of(context)!.reposted)
                                          : Text(AppLocalizations.of(context)!.originalPost),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.thumb_up),
                                        onPressed: () => _toggleLike(post),
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
