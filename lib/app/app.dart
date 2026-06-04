import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/bootstrap/firebase_bootstrap.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

class StockSaasApp extends ConsumerWidget {
  const StockSaasApp({
    required this.initializationResult,
    super.key,
  });

  final FirebaseInitializationResult initializationResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider(initializationResult));

    return MaterialApp.router(
      title: 'Stock SAAS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
