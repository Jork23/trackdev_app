import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:trackdev_app/configuration/preferences_page.dart';
import 'dart:convert';
import '../sign_in/index_page.dart';
import '../configuration/profile_page.dart';
import '../configuration/security_page.dart';
import 'courses_page.dart';
import 'projects_page.dart';
import 'activity_page.dart';
import 'overview_page.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ThemePage {
  int _selectedIndex = 0;
  static const  _storage = FlutterSecureStorage();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color _hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFF2D5AF0);
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> _loadUserData() async{

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/auth/self');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _userData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {

    String? token = await _storage.read(key: 'auth_token');

    try {
      final url = Uri.parse('https://trackdev.org/api/auth/logout');
      
      await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token' , 
          'Content-Type': 'application/json',
        },
      );
    }
    catch (e) {
      debugPrint("Error: $e");
    } 
    finally {
      await _storage.delete(key: 'auth_token');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const IndexPage()),
          (route) => false,
        );
      }
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

    List<Widget> pages = <Widget>[
      OverviewPage(),
      CoursesPage(),
      ProjectsPage(),
      Text('Index 3: Analitiques'),
      ActivityPage(),

      ProfilePage(userData: _userData, onProfileUpdated: _loadUserData,),
      PreferencesPage(userData: _userData, onPreferencesUpdated: loadThemeSettings,),
      SecurityPage(),
      Text('Index 8: Integracions')
    ];


    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: Builder(
            builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: textColor),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.layers_outlined, 
              color: Color(0xFF2D5AF0),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'TrackDev',
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Center(child: pages[_selectedIndex]),
      drawer: Drawer(
        backgroundColor: backgroundColor,
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.layers_outlined, 
                        color: Color(0xFF2D5AF0),
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TrackDev',
                        style: TextStyle(
                          color: textColor, 
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: _hexToColor(_userData!['color']),
                            child: Text(
                              _userData?['capitalLetters'] ?? '',
                              style: TextStyle(color: Colors.white)
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userData?['fullName'] ?? '',
                                style: TextStyle(color: textColor),
                                overflow: TextOverflow.ellipsis
                              ),
                              Text(
                                _userData?['email'] ?? '',
                                style: TextStyle(color: textColor),
                                overflow: TextOverflow.ellipsis
                              ),
                            ]
                          )
                        ]
                      ),
                      const SizedBox(height: 10),
                      if(_userData?['roles'].isNotEmpty)
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
                                _userData?['roles'][0],
                                style: const TextStyle(
                                  color: Color(0xFF2D5AF0),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                    ]
                  )
                ],
              )
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.person_outline, color: textColor),
                  const SizedBox(width: 15),
                  Text(
                    Translations.get('home_page1', currentLang),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              onTap: () {
                _onItemTapped(5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.language, color: textColor),
                  const SizedBox(width: 15),
                  Text(
                    Translations.get('home_page2', currentLang),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              onTap: () {
                _onItemTapped(6);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.key_outlined, color: textColor),
                  const SizedBox(width: 15),
                  Text(
                    Translations.get('home_page3', currentLang),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              onTap: () {
                _onItemTapped(7);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.link, color: textColor),
                  const SizedBox(width: 15),
                  Text(
                    Translations.get('home_page4', currentLang),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              onTap: () {
                _onItemTapped(8);
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            Divider(color: dividerColor, thickness: 1),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.logout, color: textColor),
                  const SizedBox(width: 15),
                  Text(
                    Translations.get('home_page5', currentLang),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              onTap: _logout,
            ),
            Divider(color: dividerColor, thickness: 1),
            const SizedBox(height: 40,)
          ]
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            color: textColor,
            fontSize: 12, fontWeight:
            FontWeight.w500)
          ,
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(color: states.contains(WidgetState.selected) ? iconNavigationBarColor : textColor);
        }),
      ),
      child: NavigationBar(
        backgroundColor: backgroundColor,
        indicatorColor: indicatorColor,
        onDestinationSelected: (int index) {
          _onItemTapped(index);
        },
        selectedIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: iconNavigationBarColor),
            icon: Icon(Icons.home_outlined, color: textColor),
            label: Translations.get('home_page6', currentLang),
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.school, color: iconNavigationBarColor),
            icon: Icon(Icons.school_outlined, color: textColor),
            label: Translations.get('home_page7', currentLang),
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.folder, color: iconNavigationBarColor),
            icon: Icon(Icons.folder_outlined, color: textColor),
            label: Translations.get('home_page8', currentLang),
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.analytics, color: iconNavigationBarColor),
            icon: Icon(Icons.analytics_outlined, color: textColor),
            label: Translations.get('home_page9', currentLang),
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history, color: iconNavigationBarColor),
            icon: Icon(Icons.history_outlined, color: textColor),
            label: Translations.get('home_page10', currentLang),
          ),
        ],
      ),
    ),
    );
  }
}