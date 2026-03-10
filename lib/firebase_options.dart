import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (Platform.operatingSystem) {
      case 'android': return android;
      case 'ios': return ios;
      default:
        throw UnsupportedError('Platform not supported.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCMS3l9NoR0J2GAqvaERRXbuod_FNMYpAw",
    authDomain: "todo-list-app-c366c.firebaseapp.com",
    databaseURL: "https://todo-list-app-c366c-default-rtdb.firebaseio.com",
    projectId: "todo-list-app-c366c",
    storageBucket: "todo-list-app-c366c.firebasestorage.app",
    messagingSenderId: "403339769192",
    appId: "1:403339769192:web:ba80b080c6c087b30a92dd",
    measurementId: "G-ZBH50BL59J",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCMS3l9NoR0J2GAqvaERRXbuod_FNMYpAw',
    appId: '1:403339769192:android:bb5dffe2756535340a92dd',
    messagingSenderId: '403339769192',
    projectId: 'todo-list-app-c366c',
    databaseURL: 'https://todo-list-app-c366c-default-rtdb.firebaseio.com',
    storageBucket: 'todo-list-app-c366c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMS3l9NoR0J2GAqvaERRXbuod_FNMYpAw',
    appId: '1:403339769192:ios:950775a8672bc40b0a92dd',
    messagingSenderId: '403339769192',
    projectId: 'todo-list-app-c366c',
    databaseURL: 'https://todo-list-app-c366c-default-rtdb.firebaseio.com',
    storageBucket: 'todo-list-app-c366c.firebasestorage.app',
    iosBundleId: 'com.example.to_do_list',
  );
}