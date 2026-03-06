import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SeguretatPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onProfileUpdated;

  const SeguretatPage({super.key, this.userData,this.onProfileUpdated});

  @override
  State<SeguretatPage> createState() => _SeguretatPageState();
}

class _SeguretatPageState extends State<SeguretatPage> {

  final storage = FlutterSecureStorage();

  late TextEditingController _oldPassword;
  late TextEditingController _newPassword1;
  late TextEditingController _newPassword2;

  String _message = '';
  bool _isSuccess = false;

  bool _hasMinLength = false;
  bool _hasLowercase = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _passwordsMatch = false;

  Color hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.pinkAccent.shade100;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

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
    _oldPassword.dispose();
    _newPassword1.dispose();
    _newPassword2.dispose();
    super.dispose();
  }

  Future<void> _changePasswordEdit() async {

    String? token = await storage.read(key: 'auth_token');

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

      setState(() {
        if (response.statusCode == 200 || response.statusCode == 204) {
          _message = 'Canvi de contrasenya correcta';
          _isSuccess = true;
          
          _oldPassword.clear();
          _newPassword1.clear();
          _newPassword2.clear();
        } else {
          _message = 'Contrasenya actual incorrecte';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Error de xarxa: $e';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        elevation: 0,
        toolbarHeight: 100,
        centerTitle: true,
        title: Column(
          children:[
            const Divider(color: Colors.black12, thickness: 1),
            Text ('Configuració de Seguretat',
                  style: TextStyle(
                      color: Color(0xFF1A2B49), 
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
            Text(
              'Gestiona la teva contrasenya i preferències de seguretat',
              style: TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
            const Divider(color: Colors.black12, thickness: 1),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [     
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
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
                            _message,
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
                            _message,
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contrasenya Actual',
                style: TextStyle(
                  color: Color(0xFF1A2B49),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _oldPassword,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: const TextStyle(color: Colors.black26),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.black26),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D5AF0), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nova Contrasenya',
                style: TextStyle(
                  color: Color(0xFF1A2B49),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPassword1,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: const TextStyle(color: Colors.black26),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.black26),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D5AF0), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Confirmar Nova Contrasenya',
                style: TextStyle(
                  color: Color(0xFF1A2B49),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPassword2,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: const TextStyle(color: Colors.black26),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.black26),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D5AF0), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'La contrasenya ha de contenir:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2B49),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRequirement('Almenys 8 caràcters', _hasMinLength),
                  _buildRequirement('Una lletra minúscula', _hasLowercase),
                  _buildRequirement('Una lletra majúscula', _hasUppercase),
                  _buildRequirement('Un número', _hasNumber),
                  _buildRequirement('Les contrasenyes coincideixen', _passwordsMatch),
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
                    'Actualitzar Contrasenya',
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
                    'Actualitzar Contrasenya',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ]
        ),
      )
    );
  }
}