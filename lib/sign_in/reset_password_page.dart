import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/theme.dart';
import '../../utils/translations.dart';


class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> with ThemePage {
  final TextEditingController _emailController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {

    setState(() {
      _errorMessage = '';
      _isSuccess = false;
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = Translations.get('resetpassword_page6', currentLang);
      });
      return;
    }

    try {
      final url = Uri.parse('https://trackdev.org/api/auth/forgot-password');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );

      if (!mounted) return;

      setState(() {
        if (response.statusCode == 200 || response.statusCode == 204) {
          _isSuccess = true;
        } 
        else {
          _errorMessage = Translations.get('resetpassword_page7', currentLang);
        }
        });
    } 
    catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = Translations.get('resetpassword_page8', currentLang);
      });
      debugPrint("Error: $e");
    } 
    finally {
      setState((){
         _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading){
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
              Translations.get('resetpassword_page1', currentLang),
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: Text(
                Translations.get('resetpassword_page2', currentLang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor, 
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('resetpassword_page3', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: Translations.get('resetpassword_page4', currentLang),
                hintStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: inputFillColor,
                prefixIcon: Icon(Icons.email_outlined, color: iconColor), 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D5AF0), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  setState(() {
                    _isLoading = true;
                  });
                  _sendEmail();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5AF0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  Translations.get('resetpassword_page5', currentLang),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),
            if(_isSuccess)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    Translations.get('resetpassword_page9', currentLang),
                    style: const TextStyle(
                      color: Color(0xFF2D5AF0), 
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isSuccess = false;
                    _errorMessage = '';
                    _emailController.clear();
                  });
                  Navigator.pop(context);
                }, 
                child: Text(
                  Translations.get('resetpassword_page10', currentLang), 
                  style: const TextStyle(color: Color(0xFF2D5AF0))
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}