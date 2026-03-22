import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../utils/theme.dart';
import '../utils/translations.dart';


class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onProfileUpdated;

  const ProfilePage({
    super.key, 
    this.userData,
    this.onProfileUpdated
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with Theme_Page{

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
        backgroundColor: backgroundColor,
        title: Text(
          Translations.get('profile_page7', currentLang),
          style: TextStyle(color: textColor),
        ),
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
          _message = Translations.get('profile_page10', currentLang);
          _isSuccess = true;
          widget.onProfileUpdated?.call();
        } else {
          _message = '${Translations.get('profile_page11', currentLang)}: ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        _message = '${Translations.get('profile_page12', currentLang)}: $e';
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
        toolbarHeight: 100,
        centerTitle: true,
        title: Column(
          children:[
            Divider(color: dividerColor, thickness: 1),
            Text(
              Translations.get('profile_page1', currentLang),
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            Text(
              Translations.get('profile_page2', currentLang),
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
            widget.userData == null? Center(child: LinearProgressIndicator()): Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: hexToColor(widget.userData!['color']),
                  child: Text(
                    "${widget.userData!['capitalLetters']}",
                    style: TextStyle(color: Colors.white, fontSize: 28)
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.userData!['fullName']}",
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      "${widget.userData!['email']}",
                      style: TextStyle(color: textColor),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('profile_page3', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _userNameController,
              readOnly: true,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputFillColor,
                hintStyle: TextStyle(color: hintColor),
                prefixIcon: Icon(Icons.person_outline, color: iconColor), 
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
                Translations.get('profile_page4', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fullNameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputFillColor,
                hintStyle: TextStyle(color: hintColor),
                prefixIcon: Icon(Icons.person_outline, color: iconColor), 
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
                Translations.get('profile_page5', currentLang),
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
                filled: true,
                fillColor: inputFillColor,
                hintStyle: TextStyle(color: hintColor),
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
                Translations.get('profile_page6', currentLang),
                style: TextStyle(
                  color: textColor,
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
                      border: Border.all(color: borderColor),
                    ),
                    child: const Icon(Icons.colorize, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _colorAvatarController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputFillColor,
                      hintStyle: TextStyle(color: hintColor),
                      prefixIcon: Icon(Icons.palette_outlined, color: iconColor), 
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('profile_page8', currentLang),
                style: TextStyle(
                  color: subtitleColor,
                  fontWeight: FontWeight.w300,
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
                  Translations.get('profile_page9', currentLang),
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