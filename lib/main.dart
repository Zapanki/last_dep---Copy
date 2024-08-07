import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:last_dep/screens/settings/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'screens/registration_and_login/login_screen.dart';
import 'screens/registration_and_login/reg_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                if (userData != null) {
                  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                  themeProvider.setThemeMode(userData['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light);
                }
              }
              return ProfileScreen(user: FirebaseAuth.instance.currentUser);
            },
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
