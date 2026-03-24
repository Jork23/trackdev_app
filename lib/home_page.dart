import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:trackdev_app/preferences_page.dart';
import 'dart:convert';
import 'index_page.dart';
import 'profile_page.dart';
import 'security_page.dart';
import 'courses_page.dart';
import 'projects_page.dart';
import '../utils/theme.dart';
import '../utils/translations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with Theme_Page {
  int _selectedIndex = 0;
  final storage = FlutterSecureStorage();
  Map<String, dynamic>? userData;
  bool isLoading = true;

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

  Color hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.pinkAccent.shade100;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> _loadUserData() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/auth/self');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          userData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {

    String? token = await storage.read(key: 'auth_token');

    try {
      final url = Uri.parse('https://trackdev.org/api/auth/logout');
      
      await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token' , 
          'Content-Type': 'application/json',
        },
      );
    }catch (e) {
      debugPrint("Error: $e");
    } 
    finally {
      await storage.delete(key: 'auth_token');
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

    List<Widget> pages = <Widget>[
      Text('Index 0: Resum'),
      CoursesPage(),
      ProjectsPage(),
      Text('Index 3: Analitiques'),
      Text('Index 4: Activitat'),

      ProfilePage(userData: userData, onProfileUpdated: _loadUserData,),
      PreferencesPage(userData: userData, onPreferencesUpdated: loadThemeSettings,),
      SecurityPage(),
      Text('Index 8: Integracions')
    ];
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
                            backgroundColor: hexToColor(userData!['color']),
                            child: Text(
                              "${userData!['capitalLetters']}",
                              style: TextStyle(color: Colors.white)
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${userData!['fullName']}",
                                  style: TextStyle(color: textColor),
                                ),
                                Text(
                                  "${userData!['email']}",
                                  style: TextStyle(color: textColor),
                                ),
                              ]
                            )
                        ]
                      ),
                      const SizedBox(height: 10),
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
                              userData!['roles'][0],
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
            Divider(color: dividerColor),
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
            )
          ]
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: iconNavigationBarColor);
          }
          return IconThemeData(color: textColor);
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