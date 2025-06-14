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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBFfLUbdN5-qCp9_4kUt3zeTW-CFF8ws0Y',
    appId: '1:719218262726:web:1b81bd5909e0c313940dc7',
    messagingSenderId: '719218262726',
    projectId: 'memory-b35b1',
    authDomain: 'memory-b35b1.firebaseapp.com',
    databaseURL: 'https://memory-b35b1-default-rtdb.firebaseio.com',
    storageBucket: 'memory-b35b1.firebasestorage.app',
    measurementId: 'G-53363EVE6S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYWoiChq_0hPhoPHuQVhgYiKFfoiYmJ64',
    appId: '1:719218262726:android:1878616a7ee0eab5940dc7',
    messagingSenderId: '719218262726',
    projectId: 'memory-b35b1',
    databaseURL: 'https://memory-b35b1-default-rtdb.firebaseio.com',
    storageBucket: 'memory-b35b1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkjyhtROGbEEcOwuywIma96ayNRYoZSQk',
    appId: '1:719218262726:ios:1d0c5661333c39af940dc7',
    messagingSenderId: '719218262726',
    projectId: 'memory-b35b1',
    databaseURL: 'https://memory-b35b1-default-rtdb.firebaseio.com',
    storageBucket: 'memory-b35b1.firebasestorage.app',
    iosBundleId: 'com.example.untitled3',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAkjyhtROGbEEcOwuywIma96ayNRYoZSQk',
    appId: '1:719218262726:ios:1d0c5661333c39af940dc7',
    messagingSenderId: '719218262726',
    projectId: 'memory-b35b1',
    databaseURL: 'https://memory-b35b1-default-rtdb.firebaseio.com',
    storageBucket: 'memory-b35b1.firebasestorage.app',
    iosBundleId: 'com.example.untitled3',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBFfLUbdN5-qCp9_4kUt3zeTW-CFF8ws0Y',
    appId: '1:719218262726:web:f7ac9f34c388d059940dc7',
    messagingSenderId: '719218262726',
    projectId: 'memory-b35b1',
    authDomain: 'memory-b35b1.firebaseapp.com',
    databaseURL: 'https://memory-b35b1-default-rtdb.firebaseio.com',
    storageBucket: 'memory-b35b1.firebasestorage.app',
    measurementId: 'G-H533FRJ6S4',
  );

}