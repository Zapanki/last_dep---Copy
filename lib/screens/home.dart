import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:last_dep/screens/messager/chat.dart';
import 'package:last_dep/screens/messager/users_list.dart';
import 'package:last_dep/screens/Home_screens/home_screen.dart';
import 'package:last_dep/screens/music/music_screen.dart';
import 'package:last_dep/screens/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      const HomeScreenContent(),
      UserList(),
      MusicScreen(), // Используем MusicScreen для вкладки "Music"
      ProfileScreen(user: _user),
    ];

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: GNav(
          gap: 8,
          activeColor: Colors.white,
          color: Colors.black,
          backgroundColor: Colors.white,
          tabBackgroundColor: Colors.yellow[800]!,
          padding: const EdgeInsets.all(16),
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.chat,
              text: 'Chat',
            ),
            GButton(
              icon: Icons.music_note,
              text: 'Music',
            ),
            GButton(
              icon: Icons.person,
              text: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
