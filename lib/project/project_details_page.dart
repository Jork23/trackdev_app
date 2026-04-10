import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_repository_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'report_details_page.dart';
import 'tasks_project_page.dart';
import 'task_details_page.dart';
import 'sprint_details_page.dart';


class ProjectDetailsPage extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectDetailsPage({
    super.key, required this.project
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> with Theme_Page{

  final storage = FlutterSecureStorage();

  Map<String, dynamic> repositorisData = {};
  Map<String, dynamic> tasksData = {};
  List<dynamic> reportsData = [];

  bool isLoadingRepository = true;
  bool isLoadingReports = true;
  bool isLoadingTask = true;

  bool _isLoading(){
    return isLoadingRepository || isLoadingReports || isLoadingTask;
  }

  Color _getIconColor(String type) {
    switch (type) {
      case "CLOSED":
        return const Color(0xFF5F6368);
      case "DRAFT":
        return const Color(0xFF1E8E3E);
      case "ACTIVE":
        return const Color(0xFFF29900);
      default:
        return const Color(0xFF5F6368);
    }
  }

  Color _getIconBackgroundColor(String type) {
    switch (type) {
      case "CLOSED":
        return const Color(0xFFF1F3F4);
      case "DRAFT":
        return const Color(0xFFE6F4EA);
      case "ACTIVE":
        return const Color(0xFFFEF7E0);
      default:
        return const Color(0xFFF1F3F4);
    }
  }

    Color _getTaskColor(String type) {
    switch (type) {
      case "BUG":
        return const Color(0xFFFCA5A5);
      case "TASK":
        return const Color(0xFF93C5FD);
      case "USER_STORY":
        return const Color(0xFFD8B4FE);
      default:
        return const Color(0xFF5F6368);
    }
  }

  Color _getTaskBackgroundColor(String type) {
    switch (type) {
      case "BUG":
        return const Color(0xFF7F1D1D);
      case "TASK":
        return const Color(0xFF1E3A8A);
      case "USER_STORY":
        return const Color(0xFF581C87);
      default:
        return const Color(0xFFF1F3F4);
    }
  }

  String _translateType(String type) {
    switch (type) {
      case "BUG":
        return Translations.get('proj_details_page20', currentLang);
      case "TASK":
        return Translations.get('proj_details_page21', currentLang);
      case "USER_STORY":
        return Translations.get('proj_details_page22', currentLang);
      default:
        return type;
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case "BACKLOG":
        return Translations.get('Backlog', currentLang);
      case "TODO":
        return Translations.get('proj_details_page23', currentLang);
      case "INPROGRESS":
        return Translations.get('proj_details_page24', currentLang);
      case "VERIFY":
        return Translations.get('proj_details_page25', currentLang);
      case "DONE":
        return Translations.get('proj_details_page26', currentLang);
      default:
        return status;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRepositories();
    _loadReports();
    _loadTasks();
  }

  Future<void> _loadRepositories() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/projects/${widget.project['id']}/github-repos');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          repositorisData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isLoadingRepository = false;
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url, 
        mode: LaunchMode.externalApplication
      );
    }
  }

  Future<void> _deleteRepository(int repositoryId) async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/projects/${widget.project['id']}/github-repos/$repositoryId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
  }

  Future<void> _loadReports() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/projects/${widget.project['id']}/reports');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          reportsData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isLoadingReports = false;
      });
    }
  }

  Future<void> _loadTasks() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/projects/${widget.project['id']}/tasks');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          tasksData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isLoadingTask = false;
      });
    }
  }

  Color hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.pinkAccent.shade100;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  
  @override
  Widget build(BuildContext context) {
    if(_isLoading()){
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF2D5AF0),
          )
        ),
      );
    }

    final repositoris = repositorisData['repos'] ?? [];
    final tasks = tasksData['tasks'] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 50,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: iconColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              Translations.get('proj_details_page1', currentLang),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(3),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255,219,252,231),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color.fromARGB(255,0,166,62), width: 1),
                  ),
                  child: const Icon(Icons.folder_open_outlined, color: Color.fromARGB(255,0,166,62), size: 24),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project['name'],
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
                          "${widget.project['course']['startYear']} - ${widget.project['course']['startYear'] + 1}",
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
                          "${widget.project['course']['subject']['name']}",
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                )
              ]
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D5AF0),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(11),
                            topRight: Radius.circular(11),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${Translations.get('proj_details_page27', currentLang)}(${repositoris.length})",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () async{
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddRepositoryPage(project: widget.project),
                                  ),
                                );
                                setState((){
                                  isLoadingRepository = true; 
                                });
                                _loadRepositories();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: backgroundColor,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                Translations.get('proj_details_page29', currentLang), 
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ]
                        ),
                      ),
                      if(!_isLoading() && reportsData.isEmpty)
                        Container(
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
                                child: FaIcon(
                                  FontAwesomeIcons.github,
                                  size: 60,
                                  color: subtitleColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                Translations.get('proj_details_page12', currentLang),
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
                      if(!_isLoading() && reportsData.isNotEmpty)...{
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: repositoris.length,
                          itemBuilder: (context, index) {
                            final repository = repositoris[index];
                            return InkWell(
                              onTap: () {
                                _launchURL("https://github.com/${repository['url']}");
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF1F3F4),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Color(0xFF5F6368), width: 1),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.github,
                                        color: const Color(0xFF5F6368), 
                                        size: 20
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            repository['name'],
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            repository['fullName'],
                                            style: TextStyle(color: subtitleColor, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),                                                              
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: repository['webhookActive'] ? const Color(0xFFE6F4EA) : const Color(0xFFFCE8E6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: repository['webhookActive'] ? const Color(0xFF1E8E3E) : const Color(0xFFD93025), 
                                          width: 1
                                        ),
                                      ),
                                      child: Text(
                                        repository['webhookActive'] ? Translations.get('proj_details_page13', currentLang) : Translations.get('proj_details_page14', currentLang),
                                        style: TextStyle(
                                          color: repository['webhookActive'] ? const Color(0xFF1E8E3E) : const Color(0xFFD93025),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: iconColor, size: 20),
                                      onPressed: () {
                                        _deleteRepository(repository['id']);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      }
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D5AF0),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(11),
                            topRight: Radius.circular(11),
                          ),
                        ),
                        child: Text(
                          "${Translations.get('proj_details_page28', currentLang)}(${reportsData.length})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if(!_isLoading() && widget.project['members'].isEmpty)
                       _buildEmptyState(icon: Icons.assessment, message: 'proj_details_page16'),
                      if(!_isLoading() && reportsData.isNotEmpty)...{
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reportsData.length,
                          itemBuilder: (context, index) {
                            final report = reportsData[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReportDetailsPage(report: report, project: widget.project),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2B344B),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Color(0xFF4D97FF), width: 1),
                                      ),
                                      child: Icon(
                                        Icons.assessment,
                                        color: const Color(0xFF4D97FF), 
                                        size: 20
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            report['name'],
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            "${Translations.get('proj_details_page17', currentLang)} ${report['rowType']} | ${Translations.get('proj_details_page18', currentLang)} ${report['columnType']}" ,
                                            style: TextStyle(color: subtitleColor, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      }
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D5AF0),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(11),
                            topRight: Radius.circular(11),
                          ),
                        ),
                        child: Text(
                          "${Translations.get('proj_details_page10', currentLang)}(${widget.project['sprints'].length})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if(!_isLoading() && widget.project['members'].isEmpty)
                       _buildEmptyState(icon: Icons.calendar_today_outlined, message: 'proj_details_page12'),
                      if(!_isLoading() && widget.project['sprints'].isNotEmpty)...{
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.project['sprints'].length,
                          itemBuilder: (context, index) {
                            final sprint = widget.project['sprints'][index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SprintDetailsPage(sprint: sprint),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _getIconBackgroundColor(sprint['status']),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _getIconColor(sprint['status']), width: 1),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today_outlined, 
                                        color: _getIconColor(sprint['status']), 
                                        size: 20
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sprint['name'],
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            "${sprint['startDate']} - ${sprint['endDate']}",
                                            style: TextStyle(color: subtitleColor, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),                                                              
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getIconBackgroundColor(sprint['status']),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: _getIconColor(sprint['status']), width: 1),
                                      ),
                                      child: Text(
                                        sprint['status'],
                                        style: TextStyle(
                                          color: _getIconColor(sprint['status']),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      }
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D5AF0),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(11),
                            topRight: Radius.circular(11),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${Translations.get('proj_details_page15', currentLang)}(${tasks.length})",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if(tasks.length > 0)...{
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () async{
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskProjectPage(project: widget.project),
                                    ),
                                  );
                                  setState((){
                                    isLoadingTask = true; 
                                  });
                                  _loadTasks();
                                  },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: backgroundColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  Translations.get('proj_details_page11', currentLang), 
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            }
                          ]
                        ),
                      ),
                      if(!_isLoading() && widget.project['members'].isEmpty)
                       _buildEmptyState(icon: Icons.assignment_outlined, message: Translations.get('proj_details_page16', currentLang)),                        
                      if(!_isLoading() && tasks.isNotEmpty)...{
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length > 5 ? 5: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return InkWell(
                              onTap: () async{
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetailsPage(task: task),
                                  ),
                                );
                                setState((){
                                  isLoadingTask = true; 
                                });
                                _loadTasks();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFF3B82F6)),
                                      ),
                                      child: Icon(
                                        Icons.assignment_outlined,
                                        color: const Color(0xFF3B82F6), 
                                        size: 25
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                task['taskKey'],
                                                style: TextStyle(
                                                  color: subtitleColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  task['name'],
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _getTaskBackgroundColor(task['type']),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: _getTaskColor(task['type']), width: 1),
                                                ),
                                                child: Text(
                                                  _translateType(task['type']),
                                                  style: TextStyle(
                                                    color: _getTaskColor(task['type']),
                                                    fontSize: 7,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                  ' • ',
                                                  style: TextStyle(
                                                    color: subtitleColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              Text(
                                                _translateStatus(task['status']),
                                                style: TextStyle(
                                                  color: subtitleColor,
                                                  fontSize: 10,
                                                ),
                                              ),
                                              if(task['estimationPoints']!=null && task['estimationPoints']!=0)...{
                                                  Text(
                                                  ' • ',
                                                  style: TextStyle(
                                                    color: subtitleColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF064E3B),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: const Color(0xFF34D399)),
                                                  ),
                                                  child: Text(
                                                    '${task['estimationPoints']} ${Translations.get('proj_details_page17', currentLang)}',
                                                    style: TextStyle(
                                                      color: const Color(0xFF34D399),
                                                      fontSize: 7,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              },
                                              if(task['assignee']!=null)...{
                                                Text(
                                                  ' • ',
                                                  style: TextStyle(
                                                    color: subtitleColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: hexToColor(task['assignee']['color']),
                                                  child: Text(
                                                    "${task['assignee']['capitalLetters']}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      )
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                Flexible(
                                                  child: Text(
                                                    "${task['assignee']['fullName']}",
                                                    style: TextStyle(color: textColor, fontSize: 10),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              }
                                            ],
                                          )
                                        ],
                                      ),
                                    ),                                                                                                
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      }
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D5AF0),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(11),
                            topRight: Radius.circular(11),
                          ),
                        ),
                        child: Text(
                          "${Translations.get('proj_details_page18', currentLang)}(${widget.project['members'].length})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if(!_isLoading() && widget.project['members'].isEmpty)
                       _buildEmptyState(icon: Icons.group, message: Translations.get('proj_details_page19', currentLang)),                     
                      if(!_isLoading() && widget.project['members'].isNotEmpty)...{
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.project['members'].length,
                          itemBuilder: (context, index) {
                            final member = widget.project['members'][index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                              child:Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: hexToColor(member['color']),
                                    child: Text(
                                      "${member['capitalLetters']}",
                                      style: TextStyle(color: Colors.white)
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${member['fullName']}",
                                          style: TextStyle(color: textColor),
                                        ),
                                        Text(
                                          "${member['email']}",
                                          style: TextStyle(color: textColor),
                                        ),
                                      ]
                                    )
                                ]
                              )
                            );
                          },
                        ),
                      }
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            )
          ]
        )
      )
    );
  }



  Widget _buildEmptyState({required IconData icon,required String message,}) {
    return Container(
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
              icon,
              size: 60,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            Translations.get(message, currentLang),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}