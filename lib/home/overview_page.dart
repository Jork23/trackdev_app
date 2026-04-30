import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../project/task_details_page.dart';
import '../project/sprint_details_page.dart';
import '../project/project_details_page.dart';


class OverviewPage extends StatefulWidget {

  const OverviewPage({ super.key });

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> with ThemePage{

  static const _storage = FlutterSecureStorage();

  List<dynamic> _activeSprintsData = [];
  Map<String, dynamic> _recentTaskData = {};
  List<dynamic> _projectsData = [];

  bool _isLoadingSprint = true;
  bool _isLoadingProject = true;
  bool _isLoadingTask = true;


  @override
  void initState() {
    super.initState();
    _loadAll();
    _loadRecentTasks();
  }

  void _loadAll()async{
    await _loadProjects();
    await _loadActiveSprints();
  }

  bool _isLoading(){
    return _isLoadingSprint || _isLoadingProject || _isLoadingTask;
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
        return Translations.get('tasks.typeBug', currentLang);
      case "TASK":
        return Translations.get('tasks.typeTask', currentLang);
      case "USER_STORY":
        return Translations.get('tasks.typeUserStory', currentLang);
      default:
        return type;
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case "BACKLOG":
        return Translations.get('tasks.statusBacklog', currentLang);
      case "TODO":
        return Translations.get('tasks.statusTodo', currentLang);
      case "INPROGRESS":
        return Translations.get('tasks.statusInProgress', currentLang);
      case "VERIFY":
        return Translations.get('tasks.statusVerify', currentLang);
      case "DONE":
        return Translations.get('tasks.statusDone', currentLang);
      default:
        return status;
    }
  }

  String _formatDate(String isoDate) {
    final dt = DateTime.parse(isoDate);
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Color _hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.pinkAccent.shade100;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
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
        Map<String, dynamic> responseData = jsonDecode(response.body);
        var llistaProjects = responseData['projects'] as List<dynamic>;

        if (!mounted) return;

        setState(() {
          _projectsData  = llistaProjects;
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingProject = false;
      });
    }
  }

  Future<void> _loadActiveSprints() async{

    String? token = await _storage.read(key: 'auth_token');

    List<dynamic> allActiveSprints = [];

    try {
      for( var p in _projectsData){

        final url = Uri.parse('https://trackdev.org/api/projects/${p['id']}/sprints');
      
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 204) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          var llistaSprints = responseData['sprints'] as List<dynamic>;

          for (var sprint in llistaSprints) {
            if (sprint['status'] == 'ACTIVE') {
            allActiveSprints.add(sprint);
            }
          }
        }
        if (!mounted) return;

        setState(() {
          _activeSprintsData = allActiveSprints;
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }

    finally{
      setState((){
        _isLoadingSprint = false;
      });
    }
  }

  Future<void> _loadRecentTasks() async{

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/recent');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _recentTaskData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingTask = false;
      });
    }
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

    final tasks = _recentTaskData['tasks'] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Divider(color: dividerColor, thickness: 1),
            Text(
              Translations.get('dashboard.studentSubtitle', currentLang),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            Divider(color: dividerColor, thickness: 1),
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
                      Translations.get('dashboard.activeSprints', currentLang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if(_activeSprintsData.isEmpty)
                    _buildEmptyState(icon: Icons.calendar_today_outlined, message: Translations.get('projects.noSprintsCreated', currentLang)),
                  if(_activeSprintsData.isNotEmpty)...{
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _activeSprintsData.length,
                      itemBuilder: (context, index) {
                        final sprint = _activeSprintsData[index];
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
                                      if(sprint?['value']!=null)
                                        Text(
                                          sprint?['value'],
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      if(sprint['startDate'] != null && sprint['endDate'] != null)
                                        Text(                                              
                                          "${_formatDate(sprint['startDate'])} - ${_formatDate(sprint['endDate'])}",
                                          style: TextStyle(color: subtitleColor, fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ),  
                                if(sprint?['status'] != null)                                                        
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getIconBackgroundColor(sprint?['status']),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _getIconColor(sprint?['status']), width: 1),
                                    ),
                                    child: Text(
                                      sprint?['status'],
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
                    child: Text(
                      Translations.get('dashboard.yourProjects', currentLang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if(_activeSprintsData.isEmpty)...{
                    _buildEmptyState(icon: Icons.folder_open_outlined, message: Translations.get('projects.noProjectsStudent', currentLang)),
                  }
                  else...{
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _projectsData.length,
                      itemBuilder: (context, index){
                        final project = _projectsData[index] ?? [];
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
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
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
                                      border: Border.all(color:Color.fromARGB(255,0,166,62)),
                                    ),
                                    child: const Icon(
                                      Icons.folder_open_outlined,
                                      color: Color.fromARGB(255,0,166,62),
                                      size: 24
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project?['name'] ?? '',
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if(project?['course']?['startYear'] != null)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                color: iconColor,
                                                size: 12
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                              "${project?['course']?['startYear']} - ${project?['course']?['startYear'] + 1}",
                                                style: TextStyle(
                                                  color: subtitleColor,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ]
                                          ),
                                          Row(
                                            children: [                                  
                                              Icon(
                                                Icons.menu_book,
                                                color: iconColor,
                                                size: 12
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                project?['course']?['subject']?['name'] ?? '',
                                                style: TextStyle(
                                                  color: subtitleColor,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          )
                                      ],
                                    )
                                  )
                                ]
                              )
                            )
                          )
                        );
                      }
                    )
                  }
                ]
              )
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
                          "${Translations.get('dashboard.recentTasks', currentLang)}(${tasks.length})",
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
                              /*await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskProjectPage(project: widget.project),
                                ),
                              );
                              setState((){
                                _isLoadingTask = true; 
                              });
                              _loadRecentTasks();*/
                              },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: backgroundColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              Translations.get('common.viewAll', currentLang), 
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        }
                      ]
                    ),
                  ),
                  if(!_isLoading() && tasks.isEmpty)
                    _buildEmptyState(icon: Icons.assignment_outlined, message: Translations.get('projects.noTasksCreated', currentLang)),                        
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
                              _isLoadingTask = true; 
                            });
                            _loadRecentTasks();
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
                                          if(task?['taskKey'] != null)
                                            Text(
                                              task?['taskKey'],
                                              style: TextStyle(
                                                color: subtitleColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              task?['name'] ?? '',
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
                                          if(task?['type'] != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getTaskBackgroundColor(task?['type']),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: _getTaskColor(task?['type']), width: 1),
                                              ),
                                              child: Text(
                                                _translateType(task?['type']),
                                                style: TextStyle(
                                                  color: _getTaskColor(task?['type']),
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          if(task?['status'] != null)...{
                                            Text(
                                                ' • ',
                                                style: TextStyle(
                                                  color: subtitleColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            Text(
                                              _translateStatus(task?['status']),
                                              style: TextStyle(
                                                color: subtitleColor,
                                                fontSize: 10,
                                              ),
                                            ),
                                          },
                                          if(task?['estimationPoints'] != null && task?['estimationPoints'] != 0)...{
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
                                                '${task?['estimationPoints']} ${Translations.get('tasks.points', currentLang)}',
                                                style: TextStyle(
                                                  color: const Color(0xFF34D399),
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          },
                                          if(task?['assignee'] != null && task?['assignee']?['color'] != null)...{
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
                                              backgroundColor: _hexToColor(task?['assignee']?['color']),
                                              child: Text(
                                                "${task?['assignee']?['capitalLetters']}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                                task['assignee']['fullName'] ?? '',
                                                style: TextStyle(color: textColor, fontSize: 10),
                                                overflow: TextOverflow.ellipsis,
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
            message,
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