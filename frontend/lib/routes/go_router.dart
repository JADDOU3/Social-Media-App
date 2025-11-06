import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/routes/app_router.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/local_storage_service.dart';
import 'package:go_router/go_router.dart';

import '../services/post_service.dart';
import '../services/profile_picture_service.dart';
import '../services/user_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =  GlobalKey<NavigatorState>(debugLabel: 'root');
final secureStorage = FlutterSecureStorage();
final localStorage = LocalStorageService(secureStorage);
final apiService = ApiService(localStorage);
final userService = UserService(apiService);
final profilePictureService = ProfilePictureService(apiService);
final postService = PostService(apiService);

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.main,
  routes: [
    GoRoute(
      path: AppRoutes.profile,
      builder: (context , state) => ProfileScreen(
          userService: userService,
          profilePictureService: profilePictureService,
          postService: postService
      ),
    ),
    //todo add routes here ^^
  ],
);