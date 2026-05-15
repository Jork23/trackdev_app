import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../home/home_page.dart';
import 'reset_password_page.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import '../../utils/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../utils/ui_helpers.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with ThemePage {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _storage = const FlutterSecureStorage();
  bool isLoading = false;
  String _errorMessage = '';

@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}

  Future<void> _login() async {

    setState((){
       _errorMessage = '';
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        isLoading = false;
        _errorMessage = Translations.get('common.error', currentLang);
      });
      return;
    }

    try {
      final url = Uri.parse('https://trackdev.org/api/auth/login');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        final String token = data['token']; 

        await _storage.write(key: 'auth_token', value: token);

        try {
          final notificationService = NotificationService();
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await notificationService.uploadTokenToServer(fcmToken);
          }
        } 
        catch (fcmError) {
          debugPrint("Error: $fcmError");
        }

        if (!mounted) return;

        if(mounted){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } 
      else{
        if (!mounted) return;
        setState(() {
          _errorMessage = Translations.get('auth.invalidCredentials', currentLang);
        });
      }
    } 
    catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '${Translations.get('common.error', currentLang)}: $e';
      });
      debugPrint("Error: $e");
    }
    finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if(isLoading){
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF2D5AF0),
          )
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSignInTitle(),
            const SizedBox(height: 20),
            UIHelpers.costumTitle(Translations.get('auth.emailAddress', currentLang), textColor),
            const SizedBox(height: 5),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: textColor),
              decoration: UIHelpers.customInputDecorationTextField(
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                hintColor: hintColor,
                hintText: Translations.get('auth.email', currentLang),
                prefixIcon: Icon(Icons.email_outlined, color: iconColor),
              ),
            ),
            const SizedBox(height: 20),
            UIHelpers.costumTitle(Translations.get('auth.password', currentLang), textColor),
            const SizedBox(height: 5),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: textColor),
              decoration: UIHelpers.customInputDecorationTextField(
                inputFillColor: inputFillColor,
                borderColor: borderColor,
                hintColor: hintColor,
                hintText: Translations.get('auth.password', currentLang),
                prefixIcon: Icon(Icons.lock_outline, color: iconColor),
              ),
            ),
            const SizedBox(height: 12),
            _buildSignInForgotPasswordButtom(),
            const SizedBox(height: 12),
            if (_errorMessage.isNotEmpty)...{
              UIHelpers.costumErrorMessage(_errorMessage),
              const SizedBox(height: 20),
            },
            _buildSignInLoginButtom()
          ],
        ),
      ),
    );
  }

  Widget _buildSignInTitle(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.layers_outlined, 
              color: Color(0xFF2D5AF0),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'TrackDev',
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          Translations.get('auth.signInTitle', currentLang),
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        )
      ]
    );
  }

  Widget _buildSignInForgotPasswordButtom(){
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
          );
        }, 
        child: Text(
          Translations.get('auth.forgotPassword', currentLang), 
          style: const TextStyle(color: Color(0xFF2D5AF0))
        ),
      ),
    );
  }

  Widget _buildSignInLoginButtom(){
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          _login();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D5AF0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          Translations.get('auth.login', currentLang),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

}