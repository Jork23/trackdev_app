import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../project/project_details_page.dart';


class CoursesPage extends StatefulWidget {

  const CoursesPage({
    super.key, 
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> with Theme_Page{

  final storage = FlutterSecureStorage();
  Map<String, dynamic> coursesData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/courses');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          coursesData = jsonDecode(response.body); 
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

    final courses = coursesData['courses'] ?? [];

    if(!isLoading && courses.isEmpty){
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(48.0),
          margin: const EdgeInsets.symmetric(vertical: 24.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Icon(
                  Icons.menu_book,
                  size: 60,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                Translations.get('courses_page4', currentLang),
                style: TextStyle(
                  color: textColor, 
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),                           
            ],
          ),
        ),
      );
    }
    else{
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
                Translations.get('courses_page1', currentLang),
                style: TextStyle(
                  color: textColor, 
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                Translations.get('courses_page2', currentLang),
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
        body: ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index){
            final course = courses[index];
            final enrolledProjects = course['enrolledProjects'] ?? [];
            return Container(
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5AF0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)
                      )
                    ),         
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 81, 130, 239),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['subject']['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "${course['startYear']} - ${course['startYear'] + 1}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translations.get('courses_page3', currentLang),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),               
                          itemCount: enrolledProjects.length,
                          itemBuilder: (context, index){
                            final project = enrolledProjects[index];                      
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectDetailsPage(project: project),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.folder_outlined, color: Color(0xFF2D5AF0), size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      project['name'],
                                      style: const TextStyle(
                                        color: Color(0xFF2D5AF0),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              )
                            );
                          }
                        )
                      ]
                    )
                  )
                ]
              )   
            );   
          },
        ),
      );
    }
  }
}