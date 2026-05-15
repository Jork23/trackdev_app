import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../project/task_details_page.dart';
import '../project/sprint_details_page.dart';
import 'tasks_search_page.dart';
import '../../utils/ui_helpers.dart';


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
      appBar: PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        flexibleSpace: _buildOverviewAppBar()
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildOverviewSprints(),
          const SizedBox(height: 10),
          _buildOverviewProjects(),
          const SizedBox(height: 10),
          _buildOverviewRecentTask(tasks)
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewEmptyState({required IconData icon,required String message,}) {
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

  Widget _buildOverviewAppBar(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Divider(color: dividerColor, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            Translations.get('dashboard.studentSubtitle', currentLang),
            textAlign: TextAlign.center,
            maxLines: null,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
        Divider(color: dividerColor, thickness: 1),
      ],
    );
  }

  Widget _buildOverviewSprints(){
    return Container(
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
            _buildOverviewEmptyState(icon: Icons.calendar_today_outlined, message: Translations.get('projects.noSprintsCreated', currentLang)),
          if(_activeSprintsData.isNotEmpty)...{
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeSprintsData.length,
              itemBuilder: (context, index) {
                final sprint = _activeSprintsData[index];
                return _buildOverviewSprint(sprint);
              },
            ),
          }
        ],
      ),
    );
  }

  Widget _buildOverviewSprint(Map<String,dynamic> sprint){
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
                color: UIHelpers.getIconBackgroundColor(sprint['status']),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: UIHelpers.getIconColor(sprint['status']), width: 1),
              ),
              child: Icon(
                Icons.calendar_today_outlined, 
                color: UIHelpers.getIconColor(sprint['status']), 
                size: 20
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(sprint['value']!=null)
                    Text(
                      sprint['value'],
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  if(sprint['startDate'] != null && sprint['endDate'] != null)
                    Text(                                              
                      "${UIHelpers.formatDate(sprint['startDate'])} - ${UIHelpers.formatDate(sprint['endDate'])}",
                      style: TextStyle(
                        color: subtitleColor, 
                        fontSize: 12
                      ),
                    ),
                ],
              ),
            ),  
            if(sprint['status'] != null)                                                        
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: UIHelpers.getIconBackgroundColor(sprint['status']),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: UIHelpers.getIconColor(sprint['status']), width: 1),
                ),
                child: Text(
                  sprint['status'],
                  style: TextStyle(
                    color: UIHelpers.getIconColor(sprint['status']),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewProjects(){
    return Container(
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
          if(_projectsData.isEmpty)...{
            _buildOverviewEmptyState(icon: Icons.folder_open_outlined, message: Translations.get('projects.noProjectsStudent', currentLang)),
          }
          else...{
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _projectsData.length,
              itemBuilder: (context, index){
                final project = _projectsData[index] ?? [];
                return UIHelpers.costumProject(context: context, textColor: textColor, iconColor: iconColor, subtitleColor: subtitleColor, project: project);    
              }
            )
          }
        ]
      )
    );
  }

  Widget _buildOverviewRecentTask(List<dynamic> tasks){
    return Container(
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
                  Translations.get('dashboard.recentTasks', currentLang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if(tasks.isNotEmpty)...{
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async{
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TasksSearchPage(),
                        ),
                      );
                      setState((){
                        _isLoadingTask = true; 
                      });
                      _loadRecentTasks();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
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
            _buildOverviewEmptyState(icon: Icons.assignment_outlined, message: Translations.get('projects.noTasksCreated', currentLang)),                        
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
                  child: UIHelpers.costumTask(
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    task: task,
                    currentLang: currentLang
                  )
                );
              },
            ),
          }
        ]
      ),
    );
  }
}