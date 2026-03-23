import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/translations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ProjectsPage extends StatefulWidget {

  const ProjectsPage({
    super.key, 
  });

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> with Theme_Page{

  final storage = FlutterSecureStorage();
  Map<String, dynamic> projectsData = {};

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/projects');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          projectsData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = projectsData['projects'] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 100,
        centerTitle: true,
        title: Column(
          children:[
            Divider(color: dividerColor, thickness: 1),
            Text(
              Translations.get('projects_page1', currentLang),
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              Translations.get('projects_page2', currentLang),
              style: TextStyle(
                fontSize: 13, 
                color: subtitleColor
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
            Divider(color: dividerColor, thickness: 1),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5AF0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)
                  )
                ),         
                child: Text(
                  "${Translations.get('projects_page3', currentLang)}(${projects.length})",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: projects.length,
                  itemBuilder: (context, index){
                    final project = projects[index];
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor)
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(3),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255,219,252,231),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.folder_open_outlined, color: Color.fromARGB(255,0,166,62), size: 24),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project['name'],
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, color: iconColor, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                  "${project['course']['startYear']} - ${project['course']['startYear'] + 1}",
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ]
                              ),
                              Row(
                                children: [                                  
                                  Icon(Icons.menu_book, color: iconColor, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                  "${project['course']['subject']['name']}",
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        ]
                      )
                    );
                  }
                )
              )
            ]
          )                       
        )
      )
    );
  }
}