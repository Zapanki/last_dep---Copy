// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgx2soyIB7K_6YDihXCKRws0xW3EI6oD4',
    appId: '1:709720878421:android:6ca29555c67687341993dc',
    messagingSenderId: '709720878421',
    projectId: 'last-dep',
    storageBucket: 'last-dep.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD12CEyn6NQwbZp90Ax8r-tk1fxzJ1Djm4',
    appId: '1:709720878421:ios:185dce14691ac1001993dc',
    messagingSenderId: '709720878421',
    projectId: 'last-dep',
    storageBucket: 'last-dep.appspot.com',
    androidClientId: '709720878421-3lbue4bm98fkslebtdr7ess0cs41tvfd.apps.googleusercontent.com',
    iosClientId: '709720878421-31uk3f42ag2o9d08ehd3nd7ivka7bgje.apps.googleusercontent.com',
    iosBundleId: 'com.example.lastDep',
  );
}
