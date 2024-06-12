import 'package:last_dep/screens/home.dart';
import 'package:last_dep/screens/login_screen.dart';
import 'package:last_dep/services/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';

  // Future<UserCredential> signInWithGoogle() async {
  //   try {
  //     print('Starting Google Sign-In process...');
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) {
  //       print('Google Sign-In aborted by user');
  //       throw FirebaseAuthException(
  //         code: 'ERROR_ABORTED_BY_USER',
  //         message: 'Sign in aborted by user',
  //       );
  //     }

  //     print('Google Sign-In successful, getting auth details...');
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  //     print('Creating new credential...');
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     print('Signing in with credential...');
  //     return await _auth.signInWithCredential(credential);
  //   } on FirebaseAuthException catch (e) {
  //     print('FirebaseAuthException: ${e.message}');
  //     _showErrorDialog('FirebaseAuthException: ${e.message}');
  //     rethrow;
  //   } on PlatformException catch (e) {
  //     print('PlatformException: ${e.message}');
  //     _showErrorDialog('PlatformException: ${e.message}');
  //     rethrow;
  //   } catch (e) {
  //     print('Unexpected error: ${e.toString()}');
  //     _showErrorDialog('Unexpected error: ${e.toString()}');
  //     rethrow;
  //   }
  // }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (password != confirmPassword) {
        _showErrorDialog('Passwords do not match');
        return;
      }
      try {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
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
                      validator: (value) =>
                          value!.length < 6 ? 'Enter a password 6+ chars long' : null,
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
                        SizedBox(height: 10.0),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implement Facebook Sign-In
                          },
                          icon: Image.asset(
                            'assets/images/facebook.png',
                            height: 24.0,
                            width: 24.0,
                          ),
                          label: Text('Sign in with Facebook'),
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
