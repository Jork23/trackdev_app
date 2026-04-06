import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';


class AddRepositoryPage extends StatefulWidget {
  final Map<String, dynamic>? project;

  const AddRepositoryPage({super.key, this.project});

  @override
  State<AddRepositoryPage> createState() => _AddRepositoryPageState();
}

class _AddRepositoryPageState extends State<AddRepositoryPage> with Theme_Page {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  final storage = const FlutterSecureStorage();
  String _message = '';
  bool _isSuccess = false;

  Future<void> _addRepository() async {

    String? token = await storage.read(key: 'auth_token');

    if (_nameController.text.isEmpty || _urlController.text.isEmpty || _tokenController.text.isEmpty) {
      setState(() => _message = Translations.get('Siusplau, omple tots els camps', currentLang));
      return;
    }

    try {
      final url = Uri.parse('https://trackdev.org/api/projects/${widget.project?['id']}/github-repos');
      
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'url': _urlController.text,
          'accessToken': _tokenController.text
        }),
      );

      setState((){
        if (response.statusCode == 200 || response.statusCode == 204) {
          _message = Translations.get('Repositori desat correctament', currentLang);
          _isSuccess = true;
        } else {
          _message = '${Translations.get('Error del servidor', currentLang)}: ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        _message = '${Translations.get('Error de xarxa', currentLang)}: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 50,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: iconColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              Translations.get('Torna', currentLang),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Divider(color: dividerColor, thickness: 1),
            Text(
              Translations.get('Afegir Repositori de GitHub', currentLang),
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Divider(color: dividerColor, thickness: 1),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('Nom a Mostrar', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: Translations.get('El meu repositori', currentLang),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('URL del Repositori', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: Translations.get('https://github.com/owner/repo', currentLang),
                hintStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: inputFillColor,
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('URL completa del teu repositori de GitHub', currentLang),
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('Token d\'Accés', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tokenController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: Translations.get('ghp_xxxxxxxxx', currentLang),
                hintStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: inputFillColor,
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('Token d\'accés personal amb permisos repo i admin:repo_hook', currentLang),
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSuccess ? Colors.green.shade200 : Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle_outline : Icons.error_outline, 
                        color: _isSuccess ? Colors.green : Colors.red, 
                        size: 20
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _message,
                          style: TextStyle(
                            color: _isSuccess ? Colors.green : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: borderColor),
                    ),
                    child: Text(Translations.get('Cancel.lar', currentLang), style: TextStyle(color: textColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addRepository,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5AF0),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(Translations.get('Afegir Repositori', currentLang), style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
            
          ],
        ),
      ),
    );
  }
}