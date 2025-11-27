import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

Future<void> performLogout(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    final authService = context.read<AuthService>();
    await authService.logout();
    await Future.delayed(const Duration(milliseconds: 200));
    Navigator.of(context, rootNavigator: true).pop();
    context.go('/login');
  } catch (e) {
    Navigator.of(context, rootNavigator: true).pop();
    print('Logout error: $e');
    context.go('/login');
  }
}