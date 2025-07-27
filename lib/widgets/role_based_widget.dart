import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Widget qui affiche différent contenu selon le rôle de l'utilisateur
class RoleBasedWidget extends StatelessWidget {
  final Widget? adminWidget;
  final Widget? userWidget;
  final Widget? fallback;

  const RoleBasedWidget({
    super.key,
    this.adminWidget,
    this.userWidget,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAdmin && adminWidget != null) {
          return adminWidget!;
        } else if (authProvider.isUser && userWidget != null) {
          return userWidget!;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}

/// Widget pour afficher uniquement aux admins
class AdminOnly extends StatelessWidget {
  final Widget child;

  const AdminOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return authProvider.isAdmin ? child : const SizedBox.shrink();
      },
    );
  }
}

/// Widget pour afficher uniquement aux utilisateurs normaux
class UserOnly extends StatelessWidget {
  final Widget child;

  const UserOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return authProvider.isUser ? child : const SizedBox.shrink();
      },
    );
  }
}