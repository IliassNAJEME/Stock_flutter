import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

class FirebaseInitializationResult {
  const FirebaseInitializationResult({
    required this.isReady,
    required this.message,
  });

  final bool isReady;
  final String message;
}

class FirebaseBootstrap {
  static Future<FirebaseInitializationResult> initialize() async {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        await Firebase.initializeApp();
      }

      return const FirebaseInitializationResult(
        isReady: true,
        message: 'Firebase initialise avec succes.',
      );
    } catch (error) {
      return FirebaseInitializationResult(
        isReady: false,
        message:
            'Firebase n\'est pas configure pour ce projet. Ajoutez vos fichiers '
            'Firebase puis relancez l\'application.\nErreur: $error',
      );
    }
  }
}
