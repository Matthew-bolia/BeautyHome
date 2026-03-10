 // ce fichier permet de configurer Firebase à mon application Flutter.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

 
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCHMTwH71-wgBPotFkOFzVsdEQ2p9Omfo4',
    appId: '1:586148290831:web:dea77484b428bc1aee9e7a',
    messagingSenderId: '586148290831',
    projectId: 'beauty-home-e2ea4',
    authDomain: 'beauty-home-e2ea4.firebaseapp.com',
    storageBucket: 'beauty-home-e2ea4.firebasestorage.app',
    measurementId: 'G-QQ8MKX4RCW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgquV9zqGgNQlmKHPtT1HISBEev7yHoj4',
    appId: '1:586148290831:android:f67545ef6ffa1b3eee9e7a',
    messagingSenderId: '586148290831',
    projectId: 'beauty-home-e2ea4',
    storageBucket: 'beauty-home-e2ea4.firebasestorage.app',
  );

}