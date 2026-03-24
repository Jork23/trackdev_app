import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/theme.dart';
import '../utils/translations.dart';


class PreferencesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onPreferencesUpdated;

  const PreferencesPage({super.key, required this.userData,this.onPreferencesUpdated});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> with Theme_Page{

  final storage = const FlutterSecureStorage();

  final List<Map<String, String>> langs = [
    {'code': 'ca', 'name': 'Català'},
    {'code': 'es', 'name': 'Castellano'},
    {'code': 'en', 'name': 'English'},
  ];

  late String _selectedLang;
  bool _isDarkMode = false;
  late TextEditingController _githubController;
  String? _selectedTimezone;
  List<String> _allTimezones = [];
  bool isLoading = true;

  String _message = '';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _selectedLang=langs.first['code']!;
    _githubController = TextEditingController(text: widget.userData!['githubInfo']?['login'] ?? '');
    _selectedTimezone = widget.userData!['timezone'] ?? 'UTC';


    tzData.initializeTimeZones();
    _allTimezones = tz.timeZoneDatabase.locations.keys.toList();
    _allTimezones.sort();

  }

  Future<void> _loadSettings() async {
    String? lang = await storage.read(key: 'app_lang');
    String? mode = await storage.read(key: 'app_mode');
    String? allTimezones = await storage.read(key: 'app_timezone');
    setState(() {
      if (lang != null) _selectedLang = lang;
      if (mode != null) _isDarkMode = mode == 'dark';
      if (allTimezones != null){
         _allTimezones = allTimezones.split(',');
      }
      else{
        _saveTimezone();
      }
      isLoading = false;
    });
  }

  Future<void> _saveTimezone() async{
    tzData.initializeTimeZones();
    _allTimezones = tz.timeZoneDatabase.locations.keys.toList();
    _allTimezones.sort();
    await storage.write(key: 'app_timezone', value: _allTimezones.join(','));

    if (mounted) setState(() {});
  }

  Future<void> _saveSetting(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<void> _saveProfilEdit(String key, dynamic value) async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/users');
    try {
      final response = await http.patch(
        url,
        headers: {'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',},
        body: jsonEncode({
          key: value
        }),
      );

      setState((){
        if (response.statusCode == 200 || response.statusCode == 204) {
          _message = '$key ${Translations.get('preferences_page15', currentLang)}';
          _isSuccess = true;
        } else {
          _message = '${Translations.get('preferences_page16', currentLang)}: ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        _message = '${Translations.get('preferences_page17', currentLang)}: $e';
      });
    }
  }

   @override
  Widget build(BuildContext context) {

    if(isLoading){
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
            Text (Translations.get('preferences_page1', currentLang),
                  style: TextStyle(
                      color: textColor, 
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
            Text(
              Translations.get('preferences_page2', currentLang),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('preferences_page3', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('preferences_page4', currentLang),
                style: TextStyle(
                  color: subtitleColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_isDarkMode ? Translations.get('preferences_page5', currentLang) : Translations.get('preferences_page6', currentLang),
                    style: TextStyle(
                      color: textColor
                    )
                  ),
                  Switch(
                    value: _isDarkMode,
                    activeThumbColor: const Color(0xFF2D5AF0),
                    activeTrackColor: const Color(0xFF2D5AF0),
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Icon(Icons.dark_mode, color: Colors.white);
                      }
                      return const Icon(Icons.light_mode, color: Colors.orange);
                    }),
                    onChanged: (bool value) async{
                      await _saveSetting('app_mode', value ? 'dark' : 'light');
                      setState(() => _isDarkMode = value);
                      await reloadThemeSettings();      
                      widget.onPreferencesUpdated?.call();         
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('preferences_page7', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('preferences_page8', currentLang),
                style: TextStyle(
                  color: subtitleColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownMenu<String>(
              initialSelection: _selectedLang,
              width: MediaQuery.of(context).size.width - 48,
              textStyle: TextStyle(color: textColor),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(cardColor),
                surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                side: WidgetStateProperty.all(
                  BorderSide(color: borderColor, width: 1),
                ),
              ),
              onSelected: (String? value) async {
                if (value != null) {
                  await storage.write(key: 'app_lang', value: value);
                  setState(() => _selectedLang = value);
                  await reloadThemeSettings();  
                  widget.onPreferencesUpdated?.call();
                }
              },
              dropdownMenuEntries: langs.map((Map<String, String> lang) {
                return DropdownMenuEntry<String>(
                  value: lang['code']!, 
                  label: lang['name']!,
                  style: MenuItemButton.styleFrom(
                    foregroundColor: textColor,
                    backgroundColor: backgroundColor
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('preferences_page9', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('preferences_page10', currentLang),
                style: TextStyle(
                  color: subtitleColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownMenu<String>(
              width: MediaQuery.of(context).size.width - 48,
              initialSelection: _selectedTimezone,
              enableFilter: true, 
              leadingIcon: Icon(Icons.public,color: iconColor),
              textStyle: TextStyle(color: textColor),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(cardColor),
                surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                side: WidgetStateProperty.all(
                  BorderSide(color: borderColor, width: 1),
                ),
              ),
              onSelected: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedTimezone = newValue);
                  _saveProfilEdit('timezone', newValue);
                }
              },
              dropdownMenuEntries: _allTimezones.map((tz) =>
                DropdownMenuEntry(
                  value: tz,
                  label: tz,
                  style: MenuItemButton.styleFrom(
                    foregroundColor: textColor,
                    backgroundColor: backgroundColor
                  ),
                )).toList(),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('preferences_page11', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('preferences_page12', currentLang),
                style: TextStyle(
                  color: subtitleColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _githubController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: backgroundColor,
                      hintStyle: TextStyle(color: textColor),
                      prefixIcon: FaIcon(FontAwesomeIcons.github, color: iconColor,size: 50),
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
                  )
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (){
                      _saveProfilEdit('githubUsername',_githubController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5AF0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(
                      Translations.get('preferences_page13', currentLang),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('preferences_page14', currentLang),
                style: TextStyle(
                  color: subtitleColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
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
          ]
        )
      )
    );
  }
}