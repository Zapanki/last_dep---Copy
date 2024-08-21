import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<Map<String, dynamic>> getUserData(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  Future _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future _uploadPost() async {
    if (_image == null) return;

    String userId = FirebaseAuth.instance.currentUser!.uid;
    Map<String, dynamic> userData = await getUserData(userId);

    String fileName = 'posts/${DateTime.now().toString()}.jpg';
    UploadTask uploadTask = FirebaseStorage.instance.ref().child(fileName).putFile(_image!);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('posts').add({
      'userId': userId,
      'display_name': userData['display_name'] ?? AppLocalizations.of(context)!.no_name,
      'photo_url': userData['photo_url'] ?? 'https://via.placeholder.com/150',
      'imageUrl': downloadUrl,
      'caption': _captionController.text,
      'timestamp': Timestamp.now(),
      'likes': [], // добавляем поле лайков как пустой список
    });

    Navigator.of(context).pop();
  }

  void _showFullImage(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(backgroundColor: Colors.transparent),
          backgroundColor: Colors.black,
          body: Center(
            child: Image.file(image),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.create_post),
        backgroundColor: Colors.transparent, // Remove color from AppBar
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
          children: [
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enter_a_caption,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Colors.grey[400]!,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            _image == null
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.no_image_selected,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : GestureDetector(
                    onTap: () => _showFullImage(_image!), // Open image in full screen on tap
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        _image!,
                        height: 350, // Make the image larger
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Add padding inside button
                ),
                child: Text(
                  AppLocalizations.of(context)!.pick_Image,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _uploadPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Add padding inside button
                ),
                child: Text(
                  AppLocalizations.of(context)!.post,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
