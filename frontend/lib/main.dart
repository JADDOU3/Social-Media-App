import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'routes/go_router.dart';
import 'routes/app_router.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';
import 'services/auth_service.dart';
import 'services/post_service.dart';
import 'services/profile_picture_service.dart';
import 'services/comment_service.dart';
import 'services/user_service.dart';
import 'services/friend_service.dart';
import 'utils/theme_provider.dart';
import 'utils/app_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const secureStorage = FlutterSecureStorage();
    final localStorage = LocalStorageService(secureStorage);
    final apiService = ApiService(localStorage);

    return MultiProvider(
      providers: [
        Provider.value(value: localStorage),
        Provider.value(value: apiService),
        Provider(
          create: (context) => AuthService(
            Provider.of<ApiService>(context, listen: false),
            Provider.of<LocalStorageService>(context, listen: false),
          ),
        ),
        Provider(
          create: (context) => PostService(
            Provider.of<ApiService>(context, listen: false),
          ),
        ),
        Provider(
          create: (context) => ProfilePictureService(
            Provider.of<ApiService>(context, listen: false),
          ),
        ),
        Provider(
          create: (context) => CommentService(
            Provider.of<ApiService>(context, listen: false),
          ),
        ),
        Provider(
          create: (context) => UserService(
            Provider.of<ApiService>(context, listen: false),
          ),
        ),
        Provider(
          create: (context) => FriendService(
            Provider.of<ApiService>(context, listen: false),
          ),
        ),

        ChangeNotifierProvider(create: (_) => ThemeProvider(localStorage)),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Social Media App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: AppColors.lightBackground,
              cardColor: AppColors.lightCardBackground,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.darkBackground,
              cardColor: AppColors.darkCardBackground,
            ),
            themeMode: Provider.of<ThemeProvider>(context).isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}