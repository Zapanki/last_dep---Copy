import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

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
      'display_name': userData['display_name'] ?? 'No Name',
      'photo_url': userData['photo_url'] ?? 'https://via.placeholder.com/150',
      'imageUrl': downloadUrl,
      'caption': _captionController.text,
      'timestamp': Timestamp.now(),
      'likes': [], // добавляем поле лайков как пустой список
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _captionController,
            decoration: InputDecoration(hintText: 'Enter a caption'),
          ),
          SizedBox(height: 10),
          _image == null
              ? Text('No image selected.')
              : Image.file(_image!),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image'),
          ),
          ElevatedButton(
            onPressed: _uploadPost,
            child: Text('Post'),
          ),
        ],
      ),
    );
  }
}
