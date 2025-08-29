
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
//https://github.com/axiftaj/Flutter-Firebase-Notifications
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
    apiKey: 'AIzaSyA7NlGFw-Rup3r9ejeArhd-qUY_XsDhE2g',
    appId: '1:429344079550:web:e70411c892d9d2582f68ef',
    messagingSenderId: '429344079550',
    projectId: 'shuja-bf96a',
    authDomain: 'shuja-bf96a.firebaseapp.com',
    storageBucket: 'shuja-bf96a.firebasestorage.app',
    measurementId: 'G-H71RF6223Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3dwsEEJiRQZYYVFwNWoLCRsWPHJJqcTk',
    appId: '1:429344079550:android:9a98647e6c1e89372f68ef',
    messagingSenderId: '429344079550',
    projectId: 'shuja-bf96a',
    storageBucket: 'shuja-bf96a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAo_9r1DtzENG-wIjGwT1-DpSBa_i0cfsI',
    appId: '1:429344079550:ios:51e0cbc9fed8cd562f68ef',
    messagingSenderId: '429344079550',
    projectId: 'shuja-bf96a',
    storageBucket: 'shuja-bf96a.firebasestorage.app',
    iosBundleId: 'com.reelme.reelMe',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAo_9r1DtzENG-wIjGwT1-DpSBa_i0cfsI',
    appId: '1:429344079550:ios:51e0cbc9fed8cd562f68ef',
    messagingSenderId: '429344079550',
    projectId: 'shuja-bf96a',
    storageBucket: 'shuja-bf96a.firebasestorage.app',
    iosBundleId: 'com.reelme.reelMe',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA7NlGFw-Rup3r9ejeArhd-qUY_XsDhE2g',
    appId: '1:429344079550:web:e1056fb080ddf8582f68ef',
    messagingSenderId: '429344079550',
    projectId: 'shuja-bf96a',
    authDomain: 'shuja-bf96a.firebaseapp.com',
    storageBucket: 'shuja-bf96a.firebasestorage.app',
    measurementId: 'G-88SYKBN1Z4',
  );
}
