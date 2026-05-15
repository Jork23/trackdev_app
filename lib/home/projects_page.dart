import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/ui_helpers.dart';



class ProjectsPage extends StatefulWidget {

  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> with ThemePage{

  static const _storage = FlutterSecureStorage();

  Map<String, dynamic> _projectsData = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async{

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/projects');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _projectsData = jsonDecode(response.body);
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

    final projects = _projectsData['projects'] ?? [];

    if(projects.isEmpty){  
      return _buildProjectsEmpty();
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
          title: _buildProjectsTitle()
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _buildProjects(projects)
        )
      );
    }
  }

  Widget _buildProjectsEmpty(){
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
                Icons.folder_open_outlined,
                size: 60,
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              Translations.get('projects.noProjectsStudent', currentLang),
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

  Widget _buildProjectsTitle(){
    return Column(
      children:[
        Divider(color: dividerColor, thickness: 1),
        Text(
          Translations.get('projects.title', currentLang),
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        Text(
          Translations.get('projects.studentSubtitle', currentLang),
          style: TextStyle(
            fontSize: 13, 
            color: subtitleColor
          ),
        ),
        Divider(color: dividerColor, thickness: 1),
      ],
    );
  }

  Widget _buildProjects(List<dynamic> projects){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor)
      ),
      child:Column(
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
              "${Translations.get('projects.allProjects', currentLang)} (${projects.length})",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projects.length,
            itemBuilder: (context, index){
              final project = projects[index] ?? [];
              return UIHelpers.costumProject(context: context, textColor: textColor, iconColor: iconColor, subtitleColor: subtitleColor, project: project);
            }
          )
        ]
      )
    );       
  }
}