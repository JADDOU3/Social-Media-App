import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  late final LocalStorageService _localStorage;
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _localStorage = context.read<LocalStorageService>();
    _apiService = context.read<ApiService>();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _localStorage.getAccessToken();
    final expiry = await _localStorage.getExpiry();

    if (token != null && expiry != null) {
      if (DateTime.now().isBefore(expiry)) {
        context.go('/home');
        return;
      } else {
        final authService = AuthService(_apiService, _localStorage);
        final refreshed = await authService.refreshToken();
        if (refreshed) {
          context.go('/home');
          return;
        }
      }
    }

    await _localStorage.clearAuth();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFAF92D7),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
