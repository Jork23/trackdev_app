import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:trackdev_app/firebase_options.dart';
import 'package:trackdev_app/utils/notification_service.dart';
import 'sign_in/index_page.dart';
import 'home/home_page.dart';
import 'sign_in/new_password_page.dart';
import 'utils/theme.dart';
import 'utils/translations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'project/task_details_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationService = NotificationService();
  await notificationService.initFCM();

  FirebaseMessaging.onBackgroundMessage(handleBackgoundMessage);

  const storage = FlutterSecureStorage();
  
  String? token = await storage.read(key: 'auth_token');
  String? mode = await storage.read(key: 'app_mode');
  globalIsDarkMode = (mode == 'dark');

  await Translations.init();

  bool isTokenValid = false;

  if (token != null) {
    try {
      final url = Uri.parse('https://trackdev.org/api/auth/check');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if(response.statusCode == 200 || response.statusCode == 204){
        isTokenValid = true;
      } 
      else{
        await storage.delete(key: 'auth_token');
      }
    } 
    catch (e){
      isTokenValid = false;
      debugPrint("Error: $e");
    }
  }
  
  runApp(MyApp(isTokenValid: isTokenValid, isDarkMode: mode == 'dark'));
}

class MyApp extends StatelessWidget {
  final bool isTokenValid;
  final bool isDarkMode;

  const MyApp({super.key, required this.isTokenValid, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1A2B49),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router(isTokenValid),
    );
  }
}

GoRouter _router(bool isTokenValid) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: isTokenValid ? '/home' : '/',
    
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const IndexPage(),
      ),
      
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return NewPasswordPage(token: token);
        },
      ),
      GoRoute(
        path: '/task-from-notification',
        builder: (context, state) {
          final taskMap = state.extra as Map<String, dynamic>;
          return TaskDetailsPage(task: taskMap); //
        }
      ),
    ],
  );
}

Future<void> handleBackgoundMessage(RemoteMessage message) async{
  print('Message: ${message.notification?.title}');
}