import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:last_dep/screens/home.dart';
import 'package:last_dep/screens/registration_and_login/reset_pass.dart';
import 'package:last_dep/screens/settings/theme/theme_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'reg_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null) {
        themeProvider.setThemeMode(
            userData['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light);
        final locale = Locale(userData['language'] ?? 'en');
        themeProvider.setLocale(locale);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      _showErrorDialog("Failed to login: $e");
    }
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'uid': userCredential.user!.uid,
          'theme':
              'light', // Установка темы по умолчанию при первом входе с Google
        });
        themeProvider.setThemeMode(ThemeMode.light);
        themeProvider.setLocale(const Locale('en'));
      } else {
        final userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null) {
          themeProvider.setThemeMode(
              userData['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light);

          final locale = Locale(userData['language'] ?? 'en');
          themeProvider.setLocale(locale);
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      _showErrorDialog("Failed to sign in with Google: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 20),
            Column(
              children: <Widget>[
                const Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(
                  height: 150, // Укажите подходящую высоту для анимации
                  width: 150, // Укажите подходящую ширину для анимации
                  child: Lottie.asset(
                      'assets/animations/Animation - 1721162487226.json'),
                ),
                const SizedBox(height: 20),
                Text(
                  "Login to your account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Column(
              children: <Widget>[
                inputField(
                    label: "Email",
                    controller: _emailController,
                    isInvalid: false,
                    errorMessage: '',
                    hasSuffixIcon: false),
                inputField(
                  label: "Password",
                  controller: _passwordController,
                  obscureText: true,
                  toggleVisibility: () {},
                  isPasswordVisible: false,
                  isInvalid: false,
                  errorMessage: '',
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: MaterialButton(
                height: 70,
                onPressed: () {
                  _login(context);
                },
                color: Color(0xff0095FF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Or continue with:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity, // Кнопка занимает всю ширину экрана
              height: 70, // Устанавливаем высоту кнопки
              child: SignInButton(
                Buttons.google,
                text: "Login with Google",
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                onPressed: () {
                  _loginWithGoogle(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), // Скругленные углы
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()),
                          );
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff0095FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      const SizedBox(
                          height:
                              20), // Добавляет отступ сверху для правой колонки
                      Text("Forgot Password?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResetPasswordScreen()),
                          );
                        },
                        child: Text(
                          "Reset",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff0095FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
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
