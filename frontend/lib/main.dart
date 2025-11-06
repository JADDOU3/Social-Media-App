import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/local_storage_service.dart';
import 'package:frontend/services/post_service.dart';
import 'package:frontend/services/profile_picture_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/utils/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  const secureStorage = FlutterSecureStorage();
  final localStorageService = LocalStorageService(secureStorage);

  //for testing ...
  await localStorageService.saveAccessToken("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0ZXN0aW5nMUBnbWFpbC5jb20iLCJpYXQiOjE3NjI0MDk3NTYsImV4cCI6MTc2MzAxNDU1Nn0.IICDPS6zW7IDBrT4cNMdJn48PkZET4XCRsNRg8d5gcw");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const secureStorage = FlutterSecureStorage();
    final localStorageService = LocalStorageService(secureStorage);
    final apiService = ApiService(localStorageService);
    final userService = UserService(apiService);
    final profilePictureService = ProfilePictureService(apiService);
    final postService = PostService(apiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<LocalStorageService>.value(value: localStorageService),
        Provider<ApiService>.value(value: apiService),
        Provider<UserService>.value(value: userService),
        Provider<ProfilePictureService>.value(value: profilePictureService),
        Provider<PostService>.value(value: postService),
      ],
      child: const SocialMediaApp(),
    );
  }
}

class SocialMediaApp extends StatelessWidget {
  const SocialMediaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userService = Provider.of<UserService>(context);
    final profilePictureService = Provider.of<ProfilePictureService>(context);
    final postService = Provider.of<PostService>(context);

    return MaterialApp(
      title: 'Social Media Profile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ProfileScreen(
        userService: userService,
        profilePictureService: profilePictureService,
        postService: postService,
      ),
    );
  }
}
