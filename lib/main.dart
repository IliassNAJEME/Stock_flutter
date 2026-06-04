import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/bootstrap/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initializationResult = await FirebaseBootstrap.initialize();

  runApp(
    ProviderScope(
      child: StockSaasApp(initializationResult: initializationResult),
    ),
  );
}
