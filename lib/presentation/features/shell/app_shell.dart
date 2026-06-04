import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/app_user.dart';
import '../../providers/auth_providers.dart';

class AppShell extends ConsumerWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  static const _labels = ['Dashboard', 'Produits', 'Mouvements', 'Alertes'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final user = ref.watch(authStateProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(_labels[navigationShell.currentIndex]),
        actions: [
          if (user != null) _UserBadge(user: user),
          IconButton(
            onPressed: authRepository.signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Deconnexion',
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Produits'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Mouvements'),
          NavigationDestination(icon: Icon(Icons.notification_important_outlined), label: 'Alertes'),
        ],
      ),
    );
  }
}

class _UserBadge extends StatelessWidget {
  const _UserBadge({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Chip(
        avatar: const Icon(Icons.business_center_outlined, size: 18),
        label: Text(user.email),
      ),
    );
  }
}
