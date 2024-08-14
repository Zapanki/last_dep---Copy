import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:last_dep/screens/registration_and_login/login_screen.dart';
import 'package:last_dep/screens/home.dart'; 
import 'package:provider/provider.dart';
import 'package:last_dep/screens/settings/theme/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Last Dep',
            themeMode: themeProvider.themeMode,
            locale: themeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: AuthChecker(), // Используем AuthChecker для выбора экрана
          );
        },
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Если данные пользователя загружаются, показываем экран загрузки
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Если пользователь уже авторизован, перенаправляем на HomeScreen
        if (snapshot.hasData) {
          return HomeScreen(); // Предположим, что это ваш главный экран для авторизованных пользователей
        }

        // Если пользователь не авторизован, показываем экран входа
        return LoginScreen();
      },
    );
  }
}
