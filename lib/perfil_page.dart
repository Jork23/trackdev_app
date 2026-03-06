import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


class PerfilPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onProfileUpdated;

  const PerfilPage({super.key, this.userData,this.onProfileUpdated});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {

  final storage = FlutterSecureStorage();

  late TextEditingController _userNameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _colorAvatarController;

  String _message = '';
  bool _isSuccess = false;

  Color hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.pinkAccent.shade100;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tria un color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: hexToColor(_colorAvatarController.text),
            onColorChanged: (Color color) {
              String hexString = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';                     
              _colorAvatarController.text = hexString;
            },
            enableAlpha: false,
            displayThumbColor: true,
            pickerAreaHeightPercent: 0.7,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.userData?['username'] ?? '');
    _fullNameController = TextEditingController(text: widget.userData?['fullName'] ?? '');
    _emailController = TextEditingController(text: widget.userData?['email'] ?? '');
    _colorAvatarController = TextEditingController(text: widget.userData?['color'] ?? '#2D5AF0');

    _colorAvatarController.addListener(() {
      if (mounted) setState(() {});
    });

  }

  @override
  void dispose() {
    _userNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _colorAvatarController.dispose();
    super.dispose();
  }

  Future<void> _saveProfilEdit() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/users');
    try {
      final response = await http.patch(
        url,
        headers: {'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',},
        body: jsonEncode({
          'username': _userNameController.text,
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'color': _colorAvatarController.text
        }),
      );

      setState((){
        if (response.statusCode == 200 || response.statusCode == 204) {
          _message = 'Perfil desat correctament';
          _isSuccess = true;
          widget.onProfileUpdated?.call();
        } else {
          _message = 'Error de l\'servidor: ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Error de xarxa: $e';
      });
    }
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
            Text ('Informació del Perfil',
                  style: TextStyle(
                      color: Color(0xFF1A2B49), 
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
            Text(
              'Actualitza la teva informació de perfil i avatar',
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
            widget.userData == null? Center(child: LinearProgressIndicator()): Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: hexToColor(widget.userData!['color']),
                  child: Text(
                    "${widget.userData!['capitalLetters']}",
                    style: TextStyle(color: Colors.white,fontSize: 28)
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.userData!['fullName']}",
                    ),
                    Text(
                      "${widget.userData!['email']}",
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EFFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_outlined, size: 12, color: Color(0xFF2D5AF0)),
                          const SizedBox(width: 4),
                          Text(
                            widget.userData!['roles'][0],
                            style: const TextStyle(
                              color: Color(0xFF2D5AF0),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                )
              ]
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nom d\'usuari',
                style: TextStyle(
                  color: Color(0xFF1A2B49),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _userNameController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                hintStyle: const TextStyle(color: Colors.black26),
                prefixIcon: const Icon(Icons.person_outline, color: Colors.black26), 
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nom Complet',
                style: TextStyle(
                  color: Color(0xFF1A2B49),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintStyle: const TextStyle(color: Colors.black26),
                prefixIcon: const Icon(Icons.person_outline, color: Colors.black26), 
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email',
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Color de l\'Avatar',
                style: TextStyle(
                  color: Color(0xFF1A2B49),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: _showColorPickerDialog,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: hexToColor(_colorAvatarController.text),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Icon(Icons.colorize, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _colorAvatarController,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(color: Colors.black26),
                      prefixIcon: const Icon(Icons.palette_outlined, color: Colors.black26), 
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
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: hexToColor(_colorAvatarController.text),
                  child: Text(
                    "${widget.userData!['capitalLetters']}",
                    style: TextStyle(color: Colors.white)
                  ),
                ),
              ]
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Introdueix un codi de color hexadecimal (ex., #3b82f6)',
                style: TextStyle(
                  color: Color.fromARGB(255, 64, 70, 79),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 12),
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfilEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5AF0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Desar Canvis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),       
          ]
        ),
      )
    );
  }
}