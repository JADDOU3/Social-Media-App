import 'package:flutter/material.dart';
import 'package:frontend/routes/app_router.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =  GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.main,
  routes: [
    //todo add routes here ^^
  ],
);