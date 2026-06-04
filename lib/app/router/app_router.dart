import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/bootstrap/firebase_bootstrap.dart';
import '../../presentation/features/alerts/alerts_screen.dart';
import '../../presentation/features/auth/login_screen.dart';
import '../../presentation/features/dashboard/dashboard_screen.dart';
import '../../presentation/features/movements/movements_screen.dart';
import '../../presentation/features/products/products_screen.dart';
import '../../presentation/features/setup/firebase_setup_screen.dart';
import '../../presentation/features/shell/app_shell.dart';
import '../../presentation/providers/auth_providers.dart';

final appRouterProvider =
    Provider.family<GoRouter, FirebaseInitializationResult>((ref, initResult) {
  final authRefresh = AuthRefreshListenable(ref.watch(firebaseAuthProvider));
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      if (!initResult.isReady) {
        return state.matchedLocation == '/setup' ? null : '/setup';
      }

      final isAuthenticated = ref.read(firebaseAuthProvider).currentUser != null;
      final isOnAuthPage = state.matchedLocation == '/login';

      if (!isAuthenticated && !isOnAuthPage) {
        return '/login';
      }

      if (isAuthenticated && (isOnAuthPage || state.matchedLocation == '/setup')) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/setup',
        builder: (context, state) => FirebaseSetupScreen(
          message: initResult.message,
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/movements',
                builder: (context, state) => const MovementsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (context, state) => const AlertsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(FirebaseAuth auth) {
    _subscription = auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
