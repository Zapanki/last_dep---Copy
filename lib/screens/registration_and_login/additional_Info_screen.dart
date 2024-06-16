import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:last_dep/screens/home.dart';

class AdditionalInfoScreen extends StatefulWidget {
  @override
  _AdditionalInfoScreenState createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String phoneNumber = '';
  String gender = 'Male';
  String displayName = '';

  void _submitAdditionalInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = _auth.currentUser;
        await _firestore.collection('users').doc(user!.uid).set({
          'phone_number': phoneNumber,
          'gender': gender,
          'display_name': displayName,
        });
        await user.updateDisplayName(displayName); // Обновляем displayName в Firebase Auth
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        _showErrorDialog('Unexpected error: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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
        title: Text('Additional Information'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        phoneNumber = value;
                      },
                      validator: (value) => value!.isEmpty
                          ? 'Enter your phone number'
                          : null,
                    ),
                    SizedBox(height: 10.0),
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: InputDecoration(labelText: 'Gender'),
                      onChanged: (String? newValue) {
                        setState(() {
                          gender = newValue!;
                        });
                      },
                      items: <String>['Male', 'Female', 'Other']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Display Name'),
                      onChanged: (value) {
                        displayName = value;
                      },
                      validator: (value) => value!.isEmpty
                          ? 'Enter your display name'
                          : null,
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _submitAdditionalInfo,
                      child: Text('Submit',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
