import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<Map<String, dynamic>?> _getUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).get();
    if (!doc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).set({
        'display_name': widget.user!.displayName ?? 'No display name',
        'phone_number': widget.user!.phoneNumber ?? 'No phone number',
      });
      doc = await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).get();
    }
    return doc.data() as Map<String, dynamic>?;
  }

  void _updateUserData(String field, String value) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).update({
        field: value,
      });
      if (field == 'display_name') {
        await widget.user!.updateDisplayName(value);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      setState(() {}); // Обновить интерфейс
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: ${e.toString()}')));
    }
  }

  void _showEditDialog(String field, String initialValue) {
    final _controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${field == "display_name" ? "Nickname" : "Phone Number"}'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: field == "display_name" ? "Enter new nickname" : "Enter new phone number",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
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
      Reference storageReference = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(_imageFile!);
      await uploadTask.whenComplete(() async {
        String downloadURL = await storageReference.getDownloadURL();
        await _updateUserProfileImage(downloadURL);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: ${e.toString()}')));
    }
  }

  Future<void> _updateUserProfileImage(String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).update({
        'photo_url': imageUrl,
      });
      await widget.user!.updatePhotoURL(imageUrl);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile image updated successfully')));
      setState(() {}); // Обновить интерфейс
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile image: ${e.toString()}')));
    }
  }

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
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
        } else {
          _phoneController.text = widget.user?.phoneNumber ?? '';
          _displayNameController.text = widget.user?.displayName ?? '';
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.user?.photoURL != null
                        ? NetworkImage(widget.user!.photoURL!)
                        : AssetImage('assets/images/userprofile.png') as ImageProvider,
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _showEditDialog('display_name', _displayNameController.text),
                  child: Column(
                    children: [
                      Text(
                        _displayNameController.text.isEmpty ? 'No display name' : _displayNameController.text,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.user?.email ?? 'No email',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _showEditDialog('phone_number', _phoneController.text),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.phone),
                        title: Text('Phone Number'),
                        subtitle: Text(_phoneController.text.isEmpty ? 'No phone number' : _phoneController.text),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.date_range),
                  title: Text('Member Since'),
                  subtitle: Text(widget.user?.metadata.creationTime?.toLocal().toString() ?? 'N/A'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
