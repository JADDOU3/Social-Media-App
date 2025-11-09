import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/comment_service.dart';
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
  await localStorageService.saveAccessToken("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJqYWQxQGdtYWlsLmNvbSIsImlhdCI6MTc2MjYyMjk2MSwiZXhwIjoxNzYzMjI3NzYxfQ.JpmdDAdeeNqxfq89IJZyNYDFKDUKDAEjhayS8DO3Plc");

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
    final commentService = CommentService(apiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<LocalStorageService>.value(value: localStorageService),
        Provider<ApiService>.value(value: apiService),
        Provider<UserService>.value(value: userService),
        Provider<ProfilePictureService>.value(value: profilePictureService),
        Provider<PostService>.value(value: postService),
        Provider<CommentService>.value(value: commentService),
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
    final commentService = Provider.of<CommentService>(context);

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
        commentService: commentService,
      ),
    );
  }
}
