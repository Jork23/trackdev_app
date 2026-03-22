import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

mixin Theme_Page<T extends StatefulWidget> on State<T> {
  final storage = const FlutterSecureStorage();
  
  bool isDarkMode = false;
  String currentLang = 'ca';

  @override
  void initState() {
    super.initState();
    loadThemeSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadThemeSettings();
  }

  Future<void> reloadThemeSettings() async {
    await loadThemeSettings();
  }

  Future<void> loadThemeSettings() async {
    final String? mode = await storage.read(key: 'app_mode');
    final String? lang = await storage.read(key: 'app_lang');
    
    if (mounted) {
      setState(() {
        isDarkMode = (mode == 'dark');
        currentLang = lang ?? 'ca';
      });
    }
  }

  Color get backgroundColor => isDarkMode ? const Color(0xFF1A2B49) : Colors.white;
  Color get textColor => isDarkMode ? Colors.white : const Color(0xFF1A2B49);
  Color get subtitleColor => isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  
  Color get inputFillColor => isDarkMode ? const Color(0xFF2D3E5F) : Colors.grey.shade100;
  Color get borderColor => isDarkMode ? const Color(0xFF3D4E6F) : Colors.black12;
  Color get iconColor => isDarkMode ? Colors.grey[400]! : Colors.black26;
  Color get iconNavigationBarColor => isDarkMode ? Colors.white : Colors.blueAccent;
  Color get hintColor => isDarkMode ? Colors.grey[600]! : Colors.black26;
  Color get indicatorColor => isDarkMode ? Colors.white10 : Colors.white;

  Color get cardColor => isDarkMode ? const Color(0xFF2D3E5F) : Colors.white;
  Color get dividerColor => isDarkMode ? Colors.grey[700]! : Colors.black12;
}