import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sign_in_page.dart';
import '../utils/theme.dart';
import '../utils/translations.dart';


class NewPasswordPage extends StatefulWidget {
  final String? token;
  
  const NewPasswordPage({super.key, this.token});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> with Theme_Page{

  late TextEditingController _newPassword1;
  late TextEditingController _newPassword2;

  String _messagePassword = '';
  String _messageToken = '';
  bool _isSuccess = false;
  bool _isTokenValid = false;

  bool _hasMinLength = false;
  bool _hasLowercase = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _newPassword1 = TextEditingController();
    _newPassword2 = TextEditingController();

    _newPassword1.addListener(_validatePassword);
    _newPassword2.addListener(_validatePassword);

    _validateToken(widget.token);
  }

  void _validatePassword() {
    setState(() {
      final password = _newPassword1.text;
      
      _hasMinLength = password.length >= 8;
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _passwordsMatch = _newPassword1.text.isNotEmpty && _newPassword1.text == _newPassword2.text;
    });
  }

  Future<void> _validateToken(String? token) async {

    final url = Uri.parse('https://trackdev.org/api/auth/reset-password/validate');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token'
        }
      );

      setState(() {
        if (response.statusCode == 200 || response.statusCode == 204) {
          _isTokenValid = true;
        } else {
          _messageToken = Translations.get('newpassword_page13', currentLang);
          _isTokenValid = false;
        }
      });
    } catch (e) {
      setState(() {
        _messageToken = Translations.get('newpassword_page15', currentLang);
        _isTokenValid = false;
      });
    }
  }

  bool _isPasswordValid() {
    return _hasMinLength &&  _hasLowercase && _hasUppercase &&  _hasNumber &&  _passwordsMatch;
  }

  @override
  void dispose() {
    _newPassword1.dispose();
    _newPassword2.dispose();
    super.dispose();
  }

  Future<void> _changePasswordEdit() async {

    final url = Uri.parse('https://trackdev.org/api/auth/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': widget.token,
          'newPassword': _newPassword1.text,
        }),
      );

      setState(() {
        if (response.statusCode == 200 || response.statusCode == 204) {
          _messagePassword = Translations.get('newpassword_page12', currentLang);
          _isSuccess = true;
          
          _newPassword1.clear();
          _newPassword2.clear();
        } else {
          _messagePassword = Translations.get('newpassword_page14', currentLang);
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _messagePassword = '${Translations.get('newpassword_page15', currentLang)}: $e';
        _isSuccess = false;
      });
    }
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        toolbarHeight: 100,
        centerTitle: true,
        title: Column(
          children:[
            Divider(color: dividerColor, thickness: 1),
            Text(
              Translations.get('newpassword_page1', currentLang),
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            Text(
              Translations.get('newpassword_page2', currentLang),
              style: TextStyle(fontSize: 13, color: subtitleColor),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
            Divider(color: dividerColor, thickness: 1),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [     
            const SizedBox(height: 16),
            if (!_isTokenValid)
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
                          _messageToken,
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
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  Translations.get('newpassword_page3', currentLang),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _newPassword1,
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFillColor,
                  hintText: '••••••••',
                  hintStyle: TextStyle(color: hintColor),
                  prefixIcon: Icon(Icons.lock_outline, color: iconColor),
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
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  Translations.get('newpassword_page4', currentLang),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _newPassword2,
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFillColor,
                  hintText: '••••••••',
                  hintStyle: TextStyle(color: hintColor),
                  prefixIcon: Icon(Icons.lock_outline, color: iconColor),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Translations.get('newpassword_page5', currentLang),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRequirement(Translations.get('newpassword_page6', currentLang), _hasMinLength),
                    _buildRequirement(Translations.get('newpassword_page7', currentLang), _hasLowercase),
                    _buildRequirement(Translations.get('newpassword_page8', currentLang), _hasUppercase),
                    _buildRequirement(Translations.get('newpassword_page9', currentLang), _hasNumber),
                    _buildRequirement(Translations.get('newpassword_page10', currentLang), _passwordsMatch),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if(_isPasswordValid())
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _changePasswordEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5AF0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(
                      Translations.get('newpassword_page11', currentLang),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 127, 150, 226),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(
                      Translations.get('newpassword_page12', currentLang),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (_messagePassword.isNotEmpty)
                if(!_isSuccess)
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
                              _messagePassword,
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
                  )
                else
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _messagePassword,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignInPage()),
                          );
                        },
                        icon: Text(Translations.get('newpassword_page16', currentLang)),
                        label: const Icon(Icons.arrow_forward, size: 18),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D5AF0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ]
                  )    
          ]
        ),
      )
    );
  }
}