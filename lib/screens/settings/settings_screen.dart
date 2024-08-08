import 'package:flutter/material.dart';
import 'package:last_dep/screens/settings/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          ListTile(
            title: Text('Language'),
            subtitle: Text('Select your preferred language'),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('English'),
                onTap: () {
                  // Handle language change to English
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Russian'),
                onTap: () {
                  // Handle language change to Russian
                  Navigator.of(context).pop();
                },
              ),
              // Add more languages here
            ],
          ),
        );
      },
    );
  }
}
