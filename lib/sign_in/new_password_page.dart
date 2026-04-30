import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sign_in_page.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';


class NewPasswordPage extends StatefulWidget {
  final String? token;
  
  const NewPasswordPage({super.key, this.token});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> with ThemePage{

  late TextEditingController _newPassword1;
  late TextEditingController _newPassword2;

  String _messagePassword = '';
  String _messageToken = '';
  bool _isSuccess = false;
  bool _isTokenValid = false;
  bool _isLoading = true;

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

    final url = Uri.parse('https://trackdev.org/api/auth/reset-password/validate?token=$token');

    try {
      final response = await http.get(
        url,
      );

      if (!mounted) return;

      setState(() {
        if (response.statusCode == 200 || response.statusCode == 204) {
          _isTokenValid = true;
        } 
        else {
          _messageToken = Translations.get('auth.invalidOrExpiredLink', currentLang);
          _isTokenValid = false;
        }
      });
    } 
    catch (e) {
      if (!mounted) return;
      setState(() {
        _messageToken = Translations.get('common.error', currentLang);
        _isTokenValid = false;
      });
    }
    finally{
      setState((){
        _isLoading = false;
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

      if (!mounted) return;

      setState(() {
        if (response.statusCode == 200 || response.statusCode == 204) {
          _messagePassword = Translations.get('auth.passwordResetSuccess', currentLang);
          _isSuccess = true;
          
          _newPassword1.clear();
          _newPassword2.clear();
        }
        else {
          _messagePassword = Translations.get('common.error', currentLang);
          _isSuccess = false;
        }
      });
    }
    catch (e) {
      if (!mounted) return;
      setState(() {
        _messagePassword = '${Translations.get('common.error', currentLang)}: $e';
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        toolbarHeight: 100,
        centerTitle: true,
        title: Column(
          children:[
            Divider(color: dividerColor, thickness: 1),
            Text(
              Translations.get('auth.resetPasswordTitle', currentLang),
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            Text(
              Translations.get('auth.resetPasswordDescription', currentLang),
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor
              ),
              textAlign: TextAlign.center,
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
            else...{
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  Translations.get('auth.newPassword', currentLang),
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
                  Translations.get('auth.confirmPassword', currentLang),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8),
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
                      Translations.get('auth.passwordMustContain', currentLang),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRequirement(Translations.get('auth.atLeast8Characters', currentLang), _hasMinLength),
                    _buildRequirement(Translations.get('auth.oneLowercaseLetter', currentLang), _hasLowercase),
                    _buildRequirement(Translations.get('auth.oneUppercaseLetter', currentLang), _hasUppercase),
                    _buildRequirement(Translations.get('auth.oneNumber', currentLang), _hasNumber),
                    _buildRequirement(Translations.get('auth.passwordsMatch', currentLang), _passwordsMatch),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isPasswordValid() ? _changePasswordEdit : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPasswordValid() ? const Color(0xFF2D5AF0) : const Color.fromARGB(255, 127, 150, 226),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    _isPasswordValid() ? Translations.get('auth.resetPassword', currentLang) : Translations.get('auth.passwordResetSuccess', currentLang),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 24),
              if (_messagePassword.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color:  _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:  _isSuccess ? Colors.green.shade200 : Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                          color: _isSuccess ? Colors.green : Colors.red,
                          size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _messagePassword,
                            style: TextStyle(
                              color: _isSuccess ?Colors.green :Colors.red,
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
                icon: Text(Translations.get('auth.goToLogin', currentLang)),
                label: const Icon(Icons.arrow_forward, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5AF0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            }  
          ]
        ),
      )
    );
  }
}