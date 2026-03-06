import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'index_page.dart';
import 'perfil_page.dart';
import 'seguretat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  int _selectedIndex = 0;
  final storage = FlutterSecureStorage();
  Map<String, dynamic>? userData;

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
      Text('Index 1: Cursos'),
      Text('Index 2: Projectes'),
      Text('Index 3: Analitiques'),
      Text('Index 4: Activitat'),

      PerfilPage(userData: userData, onProfileUpdated: _loadUserData,),
      Text('Index 6: Preferències'),
      SeguretatPage(),
      Text('Index 7: Integracions')
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
            builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
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
      ),
      body: Center(child: pages[_selectedIndex]),
      drawer: Drawer(
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
                  userData == null? Center(child: LinearProgressIndicator()): Column(
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
                                ),
                                Text(
                                  "${userData!['email']}",
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
                  const Icon(Icons.person_outline),
                  const SizedBox(width: 15),
                  const Text('Perfil'),
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
                  const Icon(Icons.language),
                  const SizedBox(width: 15),
                  const Text('Preferències'),
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
                  const Icon(Icons.key_outlined),
                  const SizedBox(width: 15),
                  const Text('Seguretat'),
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
                  const Icon(Icons.link),
                  const SizedBox(width: 15),
                  const Text('Integracions'),
                ],
              ),
              onTap: () {
                _onItemTapped(8);
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              title: Row(
                children: [
                  const Icon(Icons.logout),
                  const SizedBox(width: 15),
                  const Text('Tancar sessió'),
                ],
              ),
              onTap: _logout,
            )
          ]
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          _onItemTapped(index);
        },
        indicatorColor: const Color(0xFFE8EFFF),
        selectedIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Resum',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.school),
            icon: Icon(Icons.school_outlined),
            label: 'Cursos',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.folder),
            icon: Icon(Icons.folder_outlined),
            label: 'Projectes',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.analytics),
            icon: Icon(Icons.analytics_outlined),
            label: 'Analítiques',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_outlined),
            label: 'Activitat',
          ),
        ],
      ),
    );
  }
}