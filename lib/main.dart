import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'index_page.dart';
import 'home_page.dart';
import 'new_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();
  
  String? token = await storage.read(key: 'auth_token');
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

      if (response.statusCode == 200 || response.statusCode == 204) {
        isTokenValid = true;
      } else {
        await storage.delete(key: 'auth_token');
      }
    } catch (e) {
      isTokenValid = false;
      debugPrint("Error: $e");
    }
  }
  
  runApp(MyApp(isTokenValid: isTokenValid));
}

class MyApp extends StatelessWidget {
  final bool isTokenValid;

  const MyApp({super.key, required this.isTokenValid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router(isTokenValid),
    );
  }
}

GoRouter _router(bool isTokenValid) {
  return GoRouter(
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
    ],
  );
}