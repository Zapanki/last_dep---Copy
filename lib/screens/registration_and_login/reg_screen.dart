import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:last_dep/screens/registration_and_login/verify_email.dart';
import 'package:lottie/lottie.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isNameInvalid = false;
  bool _isEmailInvalid = false;
  bool _isPasswordInvalid = false;
  bool _isConfirmPasswordInvalid = false;
  String _nameError = '';
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  Future<void> _register(BuildContext context) async {
    setState(() {
      _isNameInvalid = false;
      _isEmailInvalid = false;
      _isPasswordInvalid = false;
      _isConfirmPasswordInvalid = false;
      _nameError = '';
      _emailError = '';
      _passwordError = '';
      _confirmPasswordError = '';
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _isPasswordInvalid = true;
        _isConfirmPasswordInvalid = true;
        _confirmPasswordError = "Passwords do not match";
      });
      return;
    }
    if (_passwordController.text.length < 8) {
      setState(() {
        _isPasswordInvalid = true;
        _passwordError = "Password must be at least 8 characters";
      });
      return;
    }
    if (_nameController.text.isEmpty) {
      setState(() {
        _isNameInvalid = true;
        _nameError = "Name is required";
      });
      return;
    }
    if (_emailController.text.isEmpty) {
      setState(() {
        _isEmailInvalid = true;
        _emailError = "Email is required";
      });
      return;
    }

    try {
      bool emailExists = await _checkEmailExists(_emailController.text);
      bool nameExists = await _checkNameExists(_nameController.text);
      if (emailExists) {
        setState(() {
          _isEmailInvalid = true;
          _emailError = "Email already exists";
        });
        return;
      }
      if (nameExists) {
        setState(() {
          _isNameInvalid = true;
          _nameError = "Name already exists";
        });
        return;
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text,
        'email': _emailController.text,
        'uid': userCredential.user!.uid,
        'language': 'en',
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => VerifyEmailPage(user: userCredential.user)),
      );
    } catch (e) {
      _showErrorDialog("Failed to register: $e");
    }
  }

  Future<bool> _checkEmailExists(String email) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<bool> _checkNameExists(String name) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .get();
    return result.docs.isNotEmpty;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "Register",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 20),
                Text(
                  "Register to your account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Column(
              children: <Widget>[
                inputField(
                    label: "Name",
                    controller: _nameController,
                    isInvalid: _isNameInvalid,
                    errorMessage: _nameError,
                    hasSuffixIcon: false),
                inputField(
                    label: "Email",
                    controller: _emailController,
                    isInvalid: _isEmailInvalid,
                    errorMessage: _emailError,
                    hasSuffixIcon: false),
                inputField(
                  label: "Password",
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  isPasswordVisible: _isPasswordVisible,
                  isInvalid: _isPasswordInvalid,
                  errorMessage: _passwordError,
                ),
                inputField(
                  label: "Confirm Password",
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  isPasswordVisible: _isConfirmPasswordVisible,
                  isInvalid: _isConfirmPasswordInvalid,
                  errorMessage: _confirmPasswordError,
                ),
              ],
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: MaterialButton(
                height: 70,
                onPressed: () {
                  _register(context);
                },
                color: Color(0xff0095FF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  "Register",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Already have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xff0095FF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget inputField({
  required String label,
  required TextEditingController controller,
  bool obscureText = false,
  VoidCallback? toggleVisibility,
  bool isPasswordVisible = false,
  bool isInvalid = false,
  String errorMessage = '',
  bool hasSuffixIcon = true,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: isInvalid ? Colors.red : Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: isInvalid ? Colors.red : Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: hasSuffixIcon && obscureText
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: toggleVisibility,
                )
              : IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: toggleVisibility),
        ),
      ),
      SizedBox(height: 20),
    ],
  );
}