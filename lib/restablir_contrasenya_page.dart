import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sign_in_page.dart';


class RestablirContrasenyaPage extends StatefulWidget {
  const RestablirContrasenyaPage({super.key});

  @override
  State<RestablirContrasenyaPage> createState() => _RestablirContrasenyaPageState();
}

class _RestablirContrasenyaPageState extends State<RestablirContrasenyaPage> {
  final TextEditingController _emailController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;
  bool _isSuccess = false;

  Future<void> _enviarEmail() async {

    setState(() {
      _errorMessage = '';
      _isSuccess = false;
    });

    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Siusplau, introdueix el teu correu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('https://trackdev.org/api/auth/forgot-password');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() => _isSuccess = true);
      } else {
        print('Error Status: ${response.statusCode}');
        print('Error Body: ${response.body}');
        setState(() => _errorMessage = 'Error en processar la petició');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error de connexió: Revisa la teva xarxa');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                const Text(
                  'TrackDev',
                  style: TextStyle(
                    color: Color(0xFF1A2B49), 
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Restablir contrasenya',
              style: TextStyle(
                color: Color(0xFF1A2B49), 
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Introdueix la teva adreça de correu electrònic i tenviarem un enllaç per restablir la teva contrasenya.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1A2B49), 
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Adreça de correu electrònic',
                style: TextStyle(
                  color: Color(0xFF1A2B49),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'you@example.com',
                hintStyle: const TextStyle(color: Colors.black26),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.black26), 
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
                onPressed: _isLoading ? null : _enviarEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5AF0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text(
                      'Enviar enllaç',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  child: const Text(
                    'Si existeix un compte amb aquest correu, hem enviat un enllaç per restablir la contrasenya.',
                    style: TextStyle(color: Color(0xFF2D5AF0), fontWeight: FontWeight.w500),
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
                child: const Text(
                  'Tornar a linici de sessió', 
                  style: TextStyle(color: Color(0xFF2D5AF0))
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}