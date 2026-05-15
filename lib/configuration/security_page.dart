import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import '../../utils/ui_helpers.dart';


class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> with ThemePage{

  static const _storage = FlutterSecureStorage();

  late TextEditingController _oldPassword;
  late TextEditingController _newPassword1;
  late TextEditingController _newPassword2;

  String _message = '';
  bool _isSuccess = false;

  bool _isLoading = false;

  bool _hasMinLength = false;
  bool _hasLowercase = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _oldPassword = TextEditingController();
    _newPassword1 = TextEditingController();
    _newPassword2 = TextEditingController();

    _newPassword1.addListener(_validatePassword);
    _newPassword2.addListener(_validatePassword);
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

  bool _isPasswordValid() {
    return _hasMinLength &&  _hasLowercase && _hasUppercase &&  _hasNumber &&  _passwordsMatch;
  }

  @override
  void dispose() {
    _newPassword1.removeListener(_validatePassword);
    _newPassword2.removeListener(_validatePassword);
    _oldPassword.dispose();
    _newPassword1.dispose();
    _newPassword2.dispose();
    super.dispose();
  }

  Future<void> _changePasswordEdit() async {

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/auth/password');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'oldPassword': _oldPassword.text,
          'newPassword': _newPassword1.text,
        }),
      );

      if (!mounted) return;

      setState(() {
        if(response.statusCode == 200 || response.statusCode == 204){
          _message = Translations.get('settings.passwordChangedSuccess', currentLang);
          _isSuccess = true;
          
          _oldPassword.clear();
          _newPassword1.clear();
          _newPassword2.clear();
        } 
        else{
          _message = Translations.get('settings.currentPasswordRequired', currentLang);
          _isSuccess = false;
        }
      });
    } 
    catch (e){
      if (!mounted) return;
      setState((){
        _message = '${Translations.get('common.error', currentLang)}: $e';
        _isSuccess = false;
      });
    }
    finally{
      setState(() {
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 100,
        centerTitle: true,
        title: UIHelpers.costumAppBar(
          dividerColor: dividerColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          title: Translations.get('settings.securitySettings', currentLang),
          subtitile: Translations.get('settings.securitySettingsDescription', currentLang),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [     
            if (_message.isNotEmpty)...{
              UIHelpers.costumMessage(_isSuccess, _message),           
              const SizedBox(height: 20),
            },
            UIHelpers.costumPassword(
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              hintColor: hintColor,
              textColor: textColor,
              iconColor: iconColor,
              text: Translations.get('settings.currentPassword', currentLang),
              controller: _oldPassword,
            ),
            const SizedBox(height: 20),
            UIHelpers.costumPassword(
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              hintColor: hintColor,
              textColor: textColor,
              iconColor: iconColor,
              text: Translations.get('settings.newPassword', currentLang),
              controller: _newPassword1,
            ),
            const SizedBox(height: 20),
            UIHelpers.costumPassword(
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              hintColor: hintColor,
              textColor: textColor,
              iconColor: iconColor,
              text: Translations.get('settings.newPassword', currentLang),
              controller: _newPassword2,
            ),
            const SizedBox(height: 20),
            _buildPasswordContainerRequirement(),
            const SizedBox(height: 20),
            _buildPasswordBottom(),
            const SizedBox(height: 20),
          ]
        ),
      )
    );
  }

  Widget _buildPasswordBottom(){
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isPasswordValid() ?
          (){   
            setState(() {
              _isLoading = true;
            }); 
            _changePasswordEdit(); 
          }
          : 
          (){},
        style: ElevatedButton.styleFrom(
          backgroundColor: _isPasswordValid() ? Color(0xFF2D5AF0) : Color.fromARGB(255, 127, 150, 226),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          Translations.get('settings.updatePassword', currentLang),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPasswordContainerRequirement(){
    return Container(
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
            Translations.get('settings.passwordMustContain', currentLang),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          UIHelpers.costumRequirement(Translations.get('settings.atLeast8Characters', currentLang), _hasMinLength),
          UIHelpers.costumRequirement(Translations.get('settings.oneLowercaseLetter', currentLang), _hasLowercase),
          UIHelpers.costumRequirement(Translations.get('settings.oneUppercaseLetter', currentLang), _hasUppercase),
          UIHelpers.costumRequirement(Translations.get('settings.oneNumber', currentLang), _hasNumber),
          UIHelpers.costumRequirement(Translations.get('settings.passwordsMatch', currentLang), _passwordsMatch),
        ],
      ),
    );
  }

}