import 'package:last_dep/screens/home.dart';
import 'package:last_dep/screens/registration_and_login/additional_info_screen.dart';
import 'package:last_dep/screens/registration_and_login/login_screen.dart';
import 'package:last_dep/services/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (password != confirmPassword) {
        _showErrorDialog('Passwords do not match');
        return;
      }
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': email,
            'uid': user.uid, // Сохранение UID пользователя
            'display_name': '', // Добавьте display_name и другие поля, если они необходимы
            'photo_url': '', // Добавьте photo_url, если оно необходимо
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdditionalInfoScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        _showErrorDialog('FirebaseAuthException: ${e.message}');
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
        title: Text('Register'),
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
                      decoration: InputDecoration(labelText: 'Email'),
                      onChanged: (value) {
                        email = value;
                      },
                      validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Password'),
                      onChanged: (value) {
                        password = value;
                      },
                      obscureText: true,
                      validator: (value) => value!.length < 6 ? 'Enter a password 6+ chars long' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Confirm Password'),
                      onChanged: (value) {
                        confirmPassword = value;
                      },
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'Confirm your password' : null,
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: _register,
                      child: Text('Register', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          ),
                          child: Text('Login', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Column(
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await FirebaseServices().signInWithGoogle();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            } catch (e) {
                              // Ошибка уже будет показана в signInWithGoogle()
                            }
                          },
                          icon: Image.asset(
                            'assets/images/google.png',
                            height: 24.0,
                            width: 24.0,
                          ),
                          label: Text('Sign in with Google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ],
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
