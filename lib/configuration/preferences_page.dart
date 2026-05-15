import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import '../../utils/ui_helpers.dart';


class PreferencesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onPreferencesUpdated;

  const PreferencesPage({super.key, required this.userData,this.onPreferencesUpdated});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> with ThemePage{

  static const _storage = FlutterSecureStorage();

  final List<Map<String, String>> _langs = [
    {'code': 'ca', 'name': 'Català'},
    {'code': 'es', 'name': 'Castellano'},
    {'code': 'en', 'name': 'English'},
  ];

  late String _selectedLang;
  bool _isDarkMode = false;

  late TextEditingController _githubController;
  String? _selectedTimezone;
  List<String> _allTimezones = [];

  bool _isLoading = true;

  String _message = '';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _selectedLang=_langs.first['code']!;
    _githubController = TextEditingController(text: widget.userData?['githubInfo']?['login'] ?? '');
    _selectedTimezone = widget.userData?['timezone'] ?? 'UTC';


    tz_data.initializeTimeZones();
    _allTimezones = tz.timeZoneDatabase.locations.keys.toList();
    _allTimezones.sort();

  }

  Future<void> _loadSettings() async {
    final lang = await storage.read(key: 'app_lang');
    final mode = await storage.read(key: 'app_mode');
    
    tz_data.initializeTimeZones();
    final locations = tz.timeZoneDatabase.locations.keys.toList()..sort();

    if (!mounted) return;

    setState(() {
      _allTimezones = locations;
      if (lang != null) _selectedLang = lang;
      if (mode != null) _isDarkMode = mode == 'dark';
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> _saveProfilEdit(String key, dynamic value) async{

    String? token = await _storage.read(key: 'auth_token');

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

      if (!mounted) return;

      setState((){
        if (response.statusCode == 200 || response.statusCode == 204) {
          _message = '$key ${Translations.get('common.success', currentLang)}';
          _isSuccess = true;
        } 
        else {
          _message = '${Translations.get('common.error', currentLang)}: ${response.statusCode}';
        }
      });
    } 
    catch (e) {
      if (!mounted) return;
      setState(() {
        _message = '${Translations.get('common.error', currentLang)}: $e';
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
        toolbarHeight: 100,
        centerTitle: true,
        title: UIHelpers.costumAppBar(
          dividerColor: dividerColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          title: Translations.get('settings.preferences', currentLang),
          subtitile: Translations.get('settings.preferencesSettingsDescription', currentLang),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            _buildPreferencesTheme(),
            const SizedBox(height: 20),
            _buildPreferencesLang(),
            const SizedBox(height: 20),
            _buildPreferencesTimeZone(),
            const SizedBox(height: 20),
            _buildPreferencesGitHub(),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              UIHelpers.costumMessage(_isSuccess, _message)
          ]
        )
      )
    );
  }

  Widget _buildPreferencesTheme(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('settings.theme', currentLang), textColor),
        UIHelpers.costumSubtitle(Translations.get('settings.themeDescription', currentLang), textColor), 
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: inputFillColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isDarkMode ? Translations.get('settings.themeDark', currentLang) : Translations.get('settings.themeLight', currentLang),
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
                  setState(() {
                    _isDarkMode = value;
                  });
                  await reloadThemeSettings();      
                  widget.onPreferencesUpdated?.call();         
                },
              ),
            ],
          ),
        ),
      ]
    );
  }

  Widget _buildPreferencesLang(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('settings.language', currentLang), textColor),
        UIHelpers.costumSubtitle(Translations.get('settings.languageDescription', currentLang), textColor), 
        const SizedBox(height: 5),
        DropdownMenu<String>(
          initialSelection: _selectedLang,
          width: MediaQuery.of(context).size.width - 48,
          textStyle: TextStyle(color: textColor),
          requestFocusOnTap: false,
          inputDecorationTheme: UIHelpers.customInputDecorationDropdownMenu(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
          ),
          menuStyle: UIHelpers.customMenuStyle(
            cardColor: cardColor,
            borderColor: borderColor,
          ),
          onSelected: (String? value) async {
            if (value != null) {
              await storage.write(key: 'app_lang', value: value);
              setState(() {
                _selectedLang = value;
              });
              await reloadThemeSettings();  
              widget.onPreferencesUpdated?.call();
            }
          },
          dropdownMenuEntries: _langs.map((Map<String, String> lang) {
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
      ]
    );
  }

  Widget _buildPreferencesTimeZone(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [ 
        UIHelpers.costumTitle(Translations.get('settings.timezone', currentLang), textColor),
        UIHelpers.costumSubtitle(Translations.get('settings.timezoneDescription', currentLang), textColor), 
        const SizedBox(height: 5),
        GestureDetector(
          onTap: _showTimezoneDialog,
          child: Container(
            width: MediaQuery.of(context).size.width - 48,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: inputFillColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.public, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedTimezone ?? 'UTC',
                    style: TextStyle(color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: iconColor),
              ],
            ),
          ),
        ),
      ]
    );
  }

  Widget _buildPreferencesGitHub(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('settings.githubUsername', currentLang), textColor),
        UIHelpers.costumSubtitle(Translations.get('settings.githubUsernameDescription', currentLang), textColor), 
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _githubController,
                style: TextStyle(color: textColor),
                decoration: UIHelpers.customInputDecorationTextField(
                  inputFillColor: inputFillColor,
                  borderColor: borderColor,
                  hintColor: hintColor,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: FaIcon(FontAwesomeIcons.github, color: iconColor, size: 50),
                  ),
                ),
              )
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  setState(() {
                    _isLoading = true;
                    _message = '';
                  });
                  _saveProfilEdit('githubUsername',_githubController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5AF0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  Translations.get('settings.save', currentLang),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ]
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            Translations.get('settings.githubUsernameHint', currentLang),
            style: TextStyle(
              color: subtitleColor,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ]
    );
  }

  void _showTimezoneDialog() {
    final TextEditingController searchCtrl = TextEditingController();
    List<String> filtered = List.from(_allTimezones);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: backgroundColor,
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          title: TextField(
            controller: searchCtrl,
            autofocus: true,
            style: TextStyle(color: textColor),
            decoration: UIHelpers.customInputDecorationTextField(
              inputFillColor: inputFillColor,
              borderColor: borderColor,
              hintColor: hintColor,
              hintText: Translations.get('settings.timezoneDescription', currentLang),
              prefixIcon: Icon(Icons.search, color: iconColor),
            ),
            onChanged: (value) {
              setStateDialog(() {
                filtered = _allTimezones
                    .where((tz) => tz.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            },
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tz = filtered[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          tz,
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedTimezone = tz;
                            _isLoading = true;
                            _message = '';
                          });
                          _saveProfilEdit('timezone', tz);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}