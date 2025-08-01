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
//await Firebase.initializeApp(
  //options: DefaultFirebaseOptions.currentPlatform,
 //);
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
    apiKey: 'AIzaSyD7VMGRZIv3ogaL64KpnGy226b5VA9v26Y',
    appId: '1:230034379131:web:b5dba43a67dd984d6a6dde',
    messagingSenderId: '230034379131',
    projectId: 'dhtms-fyp',
    authDomain: 'dhtms-fyp.firebaseapp.com',
    storageBucket: 'dhtms-fyp.firebasestorage.app',
    measurementId: 'G-0M0CG2Z5D8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAthLI1PjyNYgngITikn9U0BW36CQb5sQE',
    appId: '1:230034379131:android:ddb0139468e1cda16a6dde',
    messagingSenderId: '230034379131',
    projectId: 'dhtms-fyp',
    storageBucket: 'dhtms-fyp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1VXmFYbzkL9_R0ASaPE8bK8ZA2mVAe5s',
    appId: '1:230034379131:ios:2eaf4837c943bbc46a6dde',
    messagingSenderId: '230034379131',
    projectId: 'dhtms-fyp',
    storageBucket: 'dhtms-fyp.firebasestorage.app',
    iosBundleId: 'com.example.fypProjectDhtms',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB1VXmFYbzkL9_R0ASaPE8bK8ZA2mVAe5s',
    appId: '1:230034379131:ios:2eaf4837c943bbc46a6dde',
    messagingSenderId: '230034379131',
    projectId: 'dhtms-fyp',
    storageBucket: 'dhtms-fyp.firebasestorage.app',
    iosBundleId: 'com.example.fypProjectDhtms',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD7VMGRZIv3ogaL64KpnGy226b5VA9v26Y',
    appId: '1:230034379131:web:74bc18c61a69b76b6a6dde',
    messagingSenderId: '230034379131',
    projectId: 'dhtms-fyp',
    authDomain: 'dhtms-fyp.firebaseapp.com',
    storageBucket: 'dhtms-fyp.firebasestorage.app',
    measurementId: 'G-PFJBSK9RSN',
  );
}
