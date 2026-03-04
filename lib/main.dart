import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'index_page.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();
  
  String? token = await storage.read(key: 'auth_token');
  bool isTokenValid = false;

  if(token != null){
    try {
      final url = Uri.parse('https://trackdev.org/api/auth/check');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token' , 
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
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.blue),
    home: isTokenValid ? const HomePage() : const IndexPage(),
  ));
}