
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for fuchsia - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );           
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
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
    }
  }



  static const FirebaseOptions android = FirebaseOptions(
      apiKey: "AIzaSyA57kHlYjhgwf0oKMEGahKwuDClM9s7rng",
      projectId: "client-94ec5",
      storageBucket: "client-94ec5.appspot.com",
      messagingSenderId: "536974337824",
      appId: "1:536974337824:android:b5f895775e2e64ae1b5945",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARr2xbLUGJbjEZbSoLgLwHAjfiSglOViU',
    appId: '1:343659267573:ios:ed5c277cb2556a3e698cbc',
    messagingSenderId: '343659267573',
    projectId: 'app-6c19b',
    storageBucket: 'app-6c19b.appspot.com',
    androidClientId: '343659267573-mcc953ohnaoahrdtt76pr5fqrfuf06nm.apps.googleusercontent.com',
    iosClientId: '343659267573-nvd2pnliseno31mispk86c0ucd9t17j3.apps.googleusercontent.com',
    iosBundleId: 'com.timelessfusionapps.smartTalk',
  );
}
