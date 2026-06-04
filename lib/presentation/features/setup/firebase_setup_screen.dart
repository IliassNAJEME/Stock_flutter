import 'package:flutter/material.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.settings_input_component, size: 42),
                  const SizedBox(height: 16),
                  Text(
                    'Configuration Firebase requise',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(message),
                  const SizedBox(height: 16),
                  const Text(
                    'Ajoutez vos fichiers Google Services / GoogleService-Info.plist '
                    'ou un fichier firebase_options.dart si votre environnement l’exige.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
