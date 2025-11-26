import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../utils/snackbar_utils.dart';

Future<void> performLogout(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    final apiService = context.read<ApiService>();
    final localStorage = context.read<LocalStorageService>();
    final authService = AuthService(apiService, localStorage);

    await authService.logout();

    Navigator.of(context).pop();

    context.go('/login');

    showSuccessSnackbar(context, "Logged out successfully");
  } catch (e) {
    Navigator.of(context).pop();
    showErrorSnackbar(context, "Logout failed. Please try again.");
    context.go('/login');
  }
}