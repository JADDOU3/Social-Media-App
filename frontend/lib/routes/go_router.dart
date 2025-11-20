import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../screens/blocked_users_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/home_screan.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/check_auth_screen.dart';
import '../services/api_service.dart';
import '../services/comment_service.dart';
import '../services/friend_service.dart';
import '../services/local_storage_service.dart';
import '../services/post_service.dart';
import '../services/profile_picture_service.dart';
import '../services/user_service.dart';
import '../routes/app_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
GlobalKey<NavigatorState>(debugLabel: 'root');

const secureStorage = FlutterSecureStorage();
final localStorage = LocalStorageService(secureStorage);
final apiService = ApiService(localStorage);
final userService = UserService(apiService);
final profilePictureService = ProfilePictureService(apiService);
final postService = PostService(apiService);
final commentService = CommentService(apiService);
final friendService = FriendService(apiService);

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.checkAuth,
  routes: [
    GoRoute(
      path: AppRoutes.checkAuth,
      builder: (context, state) => const CheckAuthScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => HomeScreen(
        userService: userService,
        profilePictureService: profilePictureService,
        postService: postService,
        commentService: commentService,
      ),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => ProfileScreen(
        userService: userService,
        profilePictureService: profilePictureService,
        postService: postService,
        commentService: commentService,
        friendService: friendService,
      ),
    ),
    GoRoute(
      path: '${AppRoutes.profile}/:userId',
      builder: (context, state) {
        final userIdParam = state.pathParameters['userId'];
        final userId = userIdParam != null ? int.tryParse(userIdParam) : null;

        return ProfileScreen(
          userService: userService,
          profilePictureService: profilePictureService,
          postService: postService,
          commentService: commentService,
          friendService: friendService,
          userId: userId,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.friends,
      builder: (context, state) => FriendsScreen(
        friendService: friendService,
        userService: userService,
        profilePictureService: profilePictureService,
      ),
    ),
    GoRoute(
      path: AppRoutes.blocked,
      builder: (context, state) => BlockedUsersScreen(
        friendService: friendService,
      ),
    ),
  ],
);