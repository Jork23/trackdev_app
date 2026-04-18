import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import 'add_task_page.dart';
import 'add_subtask_page.dart';
import 'task_details_page.dart';

class SprintDetailsPage extends StatefulWidget {
  final Map<String, dynamic> sprint;

  const SprintDetailsPage({super.key, required this.sprint});

  @override
  State<SprintDetailsPage> createState() => _SprintDetailsPageState();
}

class _SprintDetailsPageState extends State<SprintDetailsPage> with ThemePage{

  static  const _storage = FlutterSecureStorage();

  bool _isLoadingSprint = true;
  bool _isLoadingProject = true;
  bool _isLoadingTasks = true;
  bool _isLoadingSprintsProject = true;
  bool _isLoadingUser = true;

  Map<String, dynamic>? _sprintData;
  Map<String, dynamic>? _projectData;
  Map<String, dynamic>? _allTaskData;
  Map<String, dynamic>? _sprintsProjectData;
  Map<String, dynamic>? _userData;

  @override
  void initState(){
    super.initState();
    _loadUserData();
    _initAllData();
  }

  Future<void> _initAllData() async {
    await _loadSprintData();
    await _loadProjectData();
    await _loadTasksData();
    await _loadSprintsProjectData();
  }

  bool _isLoading(){
    return _isLoadingSprint || _isLoadingProject || _isLoadingTasks || _isLoadingSprintsProject || _isLoadingUser;
  }

  Future<void> _loadProjectData() async{
    String? token = await _storage.read(key: 'auth_token');
    final projectId = _sprintData?['project']['id'].toString();

    final url = Uri.parse('https://trackdev.org/api/projects/$projectId');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _projectData = jsonDecode(response.body); 
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

  Future<void> _loadSprintsProjectData() async{
    String? token = await _storage.read(key: 'auth_token');
    final projectId = _sprintData?['project']['id'].toString();

    final url = Uri.parse('https://trackdev.org/api/projects/$projectId/sprints');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _sprintsProjectData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingSprintsProject = false;
      });
    }
  }

  Future<void> _loadTasksData() async{
    String? token = await _storage.read(key: 'auth_token');
    final projectId = _sprintData?['project']['id'].toString();

    final url = Uri.parse('https://trackdev.org/api/projects/$projectId/tasks');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _allTaskData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingTasks = false;
      });
    }
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
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _loadSprintData() async{
    
    String? token = await _storage.read(key: 'auth_token');
    final url = Uri.parse('https://trackdev.org/api/sprints/${widget.sprint['id']}/board');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _sprintData = jsonDecode(response.body); 
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
        return Translations.get('sprint_details_page1', currentLang);
      case "TASK":
        return Translations.get('sprint_details_page2', currentLang);
      case "USER_STORY":
        return Translations.get('sprint_details_page3', currentLang);
      default:
        return type;
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case "BACKLOG":
        return "Backlog";
      case "TODO":
        return Translations.get('sprint_details_page4', currentLang);
      case "INPROGRESS":
        return Translations.get('sprint_details_page5', currentLang);
      case "VERIFY":
        return Translations.get('sprint_details_page6', currentLang);
      case "DONE":
        return Translations.get('sprint_details_page7', currentLang);
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "BACKLOG":
        return const Color(0xFFEF4444);
      case "TODO":
        return const Color(0xFFFBBF24);
      case "INPROGRESS":
        return const Color(0xFF3B82F6);
      case "VERIFY":
        return const Color(0xFFA855F7);
      case "DONE":
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF64748B);
    }
  }


  String? _canEditStatusReason(String newStatus, Map<String,dynamic> task) {

    if(_userData!['id'] != task['assignee']?['id']){
      return Translations.get('sprint_details_page8', currentLang);
    }

    final current = task['status'];
    final hasPullRequests = task['pullRequests'] != null && task['pullRequests'].isNotEmpty;

    if (current == newStatus) return null;

    switch (current) {
      case 'BACKLOG':
        if (newStatus == 'TODO') return null;
        return Translations.get('sprint_details_page9', currentLang);

      case 'TODO':
        if (newStatus == 'INPROGRESS' || newStatus == 'BACKLOG') return null;
        return Translations.get('sprint_details_page10', currentLang);

      case 'INPROGRESS':
        if (newStatus == 'TODO') return null;
        if (newStatus == 'VERIFY') {
          if (!hasPullRequests) {
            return Translations.get('sprint_details_page11', currentLang);
          }
          return null;
        }
        if (newStatus == 'DONE') {
          return Translations.get('sprint_details_page12', currentLang);
        }
        return Translations.get('sprint_details_page13', currentLang);

      case 'VERIFY':
        if (newStatus == 'DONE') return null;
        return Translations.get('sprint_details_page14', currentLang);

      case 'DONE':
        if (newStatus == 'VERIFY') return null;
        return Translations.get('sprint_details_page15', currentLang);

      default:
        return Translations.get('sprint_details_page16', currentLang);
    }
  }


  bool _isAllSubstasksInBackLog(Map<String,dynamic> task){

    final subtasks = task['childTasks'] as List?;

    if (subtasks == null || subtasks.isEmpty) return true;

    for (var sub in subtasks) {
      if (sub['status'] != 'BACKLOG') {
        return false;
      }
    }

    return true;

  }

  String? _canEditSprintReason(Map<String,dynamic> task, int? newSprintId) {

    if(_userData!['id'] != task['assignee']?['id']){
      return Translations.get('sprint_details_page8', currentLang);
    }

    final bool goingToBacklog = newSprintId == -1;
    final currentSprints = task['activeSprints'] as List;
    final bool currentlyInBacklog = currentSprints.isEmpty;
    final projectSprints = _sprintsProjectData?['sprints'] as List;

    bool targetIsFuture = false;
    bool currentIsActive = false;
    bool currentIsFuture = false;


    if(!goingToBacklog){
      for (var s in projectSprints) {
        if (s['id'] == newSprintId) {
          targetIsFuture = s['status'] == 'DRAFT';
          break;
        }
      }
    }

    if(!currentlyInBacklog){
      final currentId = currentSprints[0]['id'];
      for (var s in projectSprints) {
        if (s['id'] == currentId) {
          currentIsActive = s['status'] == 'ACTIVE';
          currentIsFuture = s['status'] == 'DRAFT';
          break;
        }
      }
    }

    if( task['type'] == 'USER_STORY'){
      if(!_isAllSubstasksInBackLog(task)){
        return Translations.get('sprint_details_page17', currentLang);
      }
      return null;
    }

    if(task['parentTaskId'] != null){
      if(goingToBacklog){
        return Translations.get('sprint_details_page18', currentLang);
      }
      if(currentlyInBacklog){
        return null;
      }
      if(currentIsActive){
        if (targetIsFuture) return null;
        return Translations.get('sprint_details_page19', currentLang);
      }
      if(currentIsFuture){
        return Translations.get('sprint_details_page20', currentLang);
      }
      return null;
    }

    if(currentlyInBacklog){
      return null;
    }
    if(currentIsActive){
      return null;
    }
    if(currentIsFuture){
      if (goingToBacklog) return null;
      return Translations.get('sprint_details_page21', currentLang);
    }

    return null;
  }

  Future<void> _updateSprint(int? sprintId, Map<String, dynamic> task) async {
    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/${task['id']}');

    try {
      if (sprintId == -1) {
        await http.patch(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'activeSprints': []}),
        );
      } else {
        await http.patch(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'activeSprints': [sprintId],
            'status': 'TODO',
          }),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _updateStatus(String? newStatus, Map<String, dynamic> task) async {
    String? token = await _storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${task['id']}');
    try {
      await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': newStatus,
        }),
      );

    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _showCannotEditSnackBar(String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reason,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final dt = DateTime.parse(isoDate);
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
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

    List<Map<String, dynamic>> userStories = [];
    List<Map<String, dynamic>> usersTasks = [];
    List<Map<String, dynamic>> backlogTasks = [];

    for (var t in _allTaskData?['tasks']) {
      if (t['parentTaskId'] == null && t['activeSprints'].isEmpty) {
        backlogTasks.add(t);
      }
      for ( var s in t['activeSprints']){
        if(s['id'] == _sprintData?['id'] && t['type'] == 'USER_STORY'){
          userStories.add(t);
          break;
        }
        if(s['id'] == _sprintData?['id'] && t['type'] != 'USER_STORY' && t['parentTaskId'] == null ){
          usersTasks.add(t);
          break;
        } 
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 60,
        title: Row(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5AF0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                  Text(
                    Translations.get('sprint_details_page22', currentLang),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ]
              ),
            ),
            const SizedBox(width: 15),
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
            const Spacer(),
            SizedBox(
              height: 40,
              child: Expanded(
                child: ElevatedButton(
                  onPressed: ()async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTaskPage(project: _projectData),
                      ),
                    );
                    setState((){
                      _isLoadingTasks = true; 
                    });
                    _loadTasksData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5AF0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: EdgeInsets.only(right: 10,left: 10),
                  ),
                  child: Text(
                    Translations.get('sprint_details_page23', currentLang),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            )
          ]
        )
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Divider(color: dividerColor, thickness: 1),
                Row(
                  children: [
                    if(_sprintData?['name']!=null)...{
                      Text(
                        _sprintData?['name'],
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(width: 5),
                    },
                    if(_sprintData?['status']!=null)                 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getIconBackgroundColor(_sprintData?['status']),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getIconColor(_sprintData?['status']), width: 1),
                        ),
                        child: Text(
                          _sprintData?['status'],
                          style: TextStyle(
                            color: _getIconColor(_sprintData?['status']),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    if(_sprintData?['project']?['name'] != null)...{
                      Icon(
                        Icons.folder_shared,
                        color: iconColor,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _sprintData?['project']?['name'],
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                    },
                    if(_sprintData?['startDate'] != null && _sprintData?['endDate'] != null)...{
                      Icon(
                        Icons.calendar_today_outlined,
                        color: iconColor,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${_formatDate(_sprintData?['startDate'])} - ${_formatDate(_sprintData?['endDate'])}",
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    }
                  ],
                ),
                Divider(color: dividerColor, thickness: 1),
              ]
            )
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: DragTarget<Map<String, dynamic>>(
                      onWillAcceptWithDetails: (details){
                        final activeSprints = details.data['activeSprints'] as List? ?? [];
                        return activeSprints.isNotEmpty;
                      },
                      onAcceptWithDetails: (details) async{
                        final task = details.data;
                        final reason = _canEditSprintReason(task, -1);
                        if (reason != null) {
                          _showCannotEditSnackBar(reason);
                        } 
                        else {
                          await _updateSprint(-1, task);
                          setState(() {
                            _isLoadingTasks = true;
                          });
                          await _loadTasksData();
                          setState(() {
                            _isLoadingTasks = false;
                          });                  
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          decoration: BoxDecoration(
                            color: candidateData.isNotEmpty ? Colors.blue : cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
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
                                        Translations.get('sprint_details_page24', currentLang),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ]
                                  )
                                )
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: backlogTasks.length,
                                itemBuilder: (context, index) {
                                  final task = backlogTasks[index];
                                  return InkWell(
                                    onTap: () async{
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TaskDetailsPage(task: task)
                                        ),
                                      );
                                      setState((){
                                        _isLoadingTasks = true;
                                      });
                                      _loadTasksData();
                                    },
                                    child: Column(
                                      children: [
                                        LongPressDraggable<Map<String, dynamic>>(
                                          delay: const Duration(milliseconds: 300),
                                          data: task,
                                          feedback: _taskCardBacklog(task, true),
                                          child: _taskCardBacklog(task, false),
                                        ),
                                      ]
                                    )
                                  );                              
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(width: 20,),


                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 200,
                                height: 35,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor("TODO"), 
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Center(
                                  child: Text(
                                    _translateStatus("TODO"), 
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Container(
                                width: 200,
                                height: 35,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor("INPROGRESS"), 
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Center(
                                  child: Text(
                                    _translateStatus("INPROGRESS"), 
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Container(
                                width: 200,
                                height: 35,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor("VERIFY"), 
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Center(
                                  child: Text(
                                    _translateStatus("VERIFY"), 
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Container(
                                width: 200,
                                height: 35,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor("DONE"), 
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Center(
                                  child: Text(
                                    _translateStatus("DONE"), 
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                ),
                              ),
                            ]
                          )
                        ),
                        SizedBox(
                          width: 840,
                          child: DragTarget<Map<String, dynamic>>(
                            onWillAcceptWithDetails: (details){
                              final activeSprints = details.data['activeSprints'] as List? ?? [];
                              return activeSprints.isEmpty;
                            },
                            onAcceptWithDetails: (details) async{
                              final task = details.data;
                              final reason = _canEditSprintReason(task, _sprintData!['id']);
                              if (reason != null) {
                                _showCannotEditSnackBar(reason);
                              } 
                              else {
                                await _updateSprint(_sprintData!['id'], task);
                                setState(() {
                                  _isLoadingTasks = true;
                                });
                                await _loadTasksData();
                                setState(() {
                                  _isLoadingTasks = false;
                                });
                              }
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: candidateData.isNotEmpty ? Colors.blue : cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: userStories.length,
                                      itemBuilder: (context, index) {
                                        final task = userStories[index];
                                        return InkWell(
                                          onTap: () async{
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => TaskDetailsPage(task: task)
                                              ),
                                            );
                                            setState((){
                                              _isLoadingTasks = true;
                                            });
                                            _loadTasksData();
                                          },
                                          child: Column(
                                            children: [
                                              LongPressDraggable<Map<String, dynamic>>(
                                                delay: const Duration(milliseconds: 300),
                                                data: task,
                                                feedback: _taskCardSprint(task, true,true),
                                                child: _taskCardSprint(task, false,false),
                                              ),
                                            ]
                                          )
                                        );                               
                                      },
                                    ),
                                    if (usersTasks.isNotEmpty)
                                      _unassignedTasksRow(usersTasks),                                  
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 150),
                      ]
                    )
                  )
                ],
              ),
            ),
          ),
        ],
      ),  
    );
  }


































  Widget _unassignedTasksRow(List<Map<String, dynamic>> usersTasks) {
    List<Map<String, dynamic>> toDoTasks = [];
    List<Map<String, dynamic>> inProgressTasks = [];
    List<Map<String, dynamic>> verifyTasks = [];
    List<Map<String, dynamic>> doneTasks = [];

    for(var c in usersTasks){
      if(c['status'] == 'TODO' ){
        for(var s in c['activeSprints']){
          if(s['id']==_sprintData?['id']){
            toDoTasks.add(c);
          }
        }
      }
      if(c['status'] == 'INPROGRESS'){
        for(var s in c['activeSprints']){
          if(s['id']==_sprintData?['id']){
            inProgressTasks.add(c);
          }
        }
      }
      if(c['status'] == 'VERIFY'){
        for(var s in c['activeSprints']){
          if(s['id']==_sprintData?['id']){
            verifyTasks.add(c);
          }
        }
      }
      if(c['status'] == 'DONE'){
        for(var s in c['activeSprints']){
          if(s['id']==_sprintData?['id']){
            doneTasks.add(c);
          }
        }
      }
    }

    int maxTasks = 0;

    if(toDoTasks.length > maxTasks){
      maxTasks = toDoTasks.length;
    }
    if(inProgressTasks.length > maxTasks){
      maxTasks = inProgressTasks.length;
    }
    if(verifyTasks.length > maxTasks){
      maxTasks = verifyTasks.length;
    }
    if(doneTasks.length > maxTasks){
      maxTasks = doneTasks.length;
    }

    double columnHeight = maxTasks > 0 ? (maxTasks * 75) : 100;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 850,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(      
                  Translations.get('sprint_details_page26', currentLang), 
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            ),

            Divider(color: dividerColor, thickness: 1),
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 190,
                  child: DragTarget<Map<String, dynamic>>(
                    onWillAcceptWithDetails: (details){
                      return details.data['parentTaskId'] == null && details.data['type'] != 'USER_STORY';
                    },
                    onAcceptWithDetails: (details) async{
                      final task = details.data;
                      final reason = _canEditStatusReason("TODO", task);
                      if (reason != null) {
                        _showCannotEditSnackBar(reason);
                      } 
                      else {
                        setState(() {
                          _isLoadingTasks = true;
                        });
                        await _updateStatus("TODO", task);
                        await _loadTasksData();
                        setState(() {
                          _isLoadingTasks = false;
                        });
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        constraints: BoxConstraints(minHeight: columnHeight),
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty ? Colors.blue : cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: candidateData.isNotEmpty ? Colors.blue.withAlpha(150): borderColor,
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: toDoTasks.length,
                          itemBuilder: (context, index) {
                            final task = toDoTasks[index];
                            return InkWell(
                              onTap: () async{
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetailsPage(task: task)
                                  ),
                                );
                                setState((){
                                  _isLoadingTasks = true;
                                });
                                _loadTasksData();
                              },
                              child: Column(
                                children: [
                                  LongPressDraggable<Map<String, dynamic>>(
                                    delay: const Duration(milliseconds: 300),
                                    data: task,
                                    feedback: _taskCardBacklog(task, true),
                                    child: _taskCardBacklog(task, false),
                                  ),
                                ]
                              )
                            );                              
                          },
                        ),
                      );
                    }
                  )
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 190,
                  child: DragTarget<Map<String, dynamic>>(
                    onWillAcceptWithDetails: (details){
                      return details.data['parentTaskId'] == null && details.data['type'] != 'USER_STORY';
                    },
                    onAcceptWithDetails: (details) async{
                      final task = details.data;
                      final reason = _canEditStatusReason("INPROGRESS", task);
                      if (reason != null) {
                        _showCannotEditSnackBar(reason);
                      } 
                      else {
                        setState(() {
                          _isLoadingTasks = true;
                        });
                        await _updateStatus("INPROGRESS", task);
                        await _loadTasksData();
                        setState(() {
                          _isLoadingTasks = false;
                        });
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        constraints: BoxConstraints(minHeight: columnHeight),
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty ? Colors.blue : cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: candidateData.isNotEmpty ? Colors.blue.withAlpha(150): borderColor,
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: inProgressTasks.length,
                          itemBuilder: (context, index) {
                            final task = inProgressTasks[index];
                            return InkWell(
                              onTap: () async{
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetailsPage(task: task)
                                  ),
                                );
                                setState((){
                                  _isLoadingTasks = true;
                                });
                                _loadTasksData();
                              },
                              child: Column(
                                children: [
                                  LongPressDraggable<Map<String, dynamic>>(
                                    delay: const Duration(milliseconds: 300),
                                    data: task,
                                    feedback: _taskCardBacklog(task, true),
                                    child: _taskCardBacklog(task, false),
                                  ),
                                ]
                              )
                            );                         
                          },
                        ),
                      );
                    }
                  )
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 190,
                  child: DragTarget<Map<String, dynamic>>(
                    onWillAcceptWithDetails: (details){
                      return details.data['parentTaskId'] == null && details.data['type'] != 'USER_STORY';
                    },
                    onAcceptWithDetails: (details) async{
                      final task = details.data;
                      final reason = _canEditStatusReason("VERIFY", task);
                      if (reason != null) {
                        _showCannotEditSnackBar(reason);
                      } 
                      else {
                        setState(() {
                          _isLoadingTasks = true;
                        });
                        await _updateStatus("VERIFY", task);
                        await _loadTasksData();
                        setState(() {
                          _isLoadingTasks = false;
                        });
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        constraints: BoxConstraints(minHeight: columnHeight),
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty ? Colors.blue : cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: candidateData.isNotEmpty ? Colors.blue.withAlpha(150): borderColor,
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: verifyTasks.length,
                          itemBuilder: (context, index) {
                            final task = verifyTasks[index];
                            return InkWell(
                              onTap: () async{
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetailsPage(task: task)
                                  ),
                                );
                                setState((){
                                  _isLoadingTasks = true;
                                });
                                _loadTasksData();
                              },
                              child: Column(
                                children: [
                                  LongPressDraggable<Map<String, dynamic>>(
                                    delay: const Duration(milliseconds: 300),
                                    data: task,
                                    feedback: _taskCardBacklog(task, true),
                                    child: _taskCardBacklog(task, false),
                                  ),
                                ]
                              )
                            );                               
                          },
                        ),
                      );
                    }
                  )
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 190,
                  child: DragTarget<Map<String, dynamic>>(
                    onWillAcceptWithDetails: (details){
                      return details.data['parentTaskId'] == null && details.data['type'] != 'USER_STORY';
                    },
                    onAcceptWithDetails: (details) async{
                      final task = details.data;
                      final reason = _canEditStatusReason("DONE", task);
                      if (reason != null) {
                        _showCannotEditSnackBar(reason);
                      } 
                      else {
                        setState(() {
                          _isLoadingTasks = true;
                        });
                        await _updateStatus("DONE", task);
                        await _loadTasksData();
                        setState(() {
                          _isLoadingTasks = false;
                        });
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        constraints: BoxConstraints(minHeight: columnHeight),
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty ? Colors.blue : cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: candidateData.isNotEmpty ? Colors.blue.withAlpha(150): borderColor,
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: doneTasks.length,
                          itemBuilder: (context, index) {
                            final task = doneTasks[index];
                            return InkWell(
                              onTap: () async{
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetailsPage(task: task)
                                  ),
                                );
                                setState((){
                                  _isLoadingTasks = true;
                                });
                                _loadTasksData();
                              },
                              child: Column(
                                children: [
                                  LongPressDraggable<Map<String, dynamic>>(
                                    delay: const Duration(milliseconds: 300),
                                    data: task,
                                    feedback: _taskCardBacklog(task, true),
                                    child: _taskCardBacklog(task, false),
                                  ),
                                ]
                              )
                              );                                
                          },
                        ),
                      );
                    }
                  )
                ), 
              ]
            )       
          ],
        ),
      )
    );
  }











































  Widget _taskCardSprint(Map<String, dynamic> task, bool isDragging, bool feedback) {

    final List children = task['childTasks'] ?? [];

    List<Map<String, dynamic>> toDoTasks = [];
    List<Map<String, dynamic>> inProgressTasks = [];
    List<Map<String, dynamic>> verifyTasks = [];
    List<Map<String, dynamic>> doneTasks = [];

    for(var c in children){
      if(c['status'] == 'TODO' ){
        for(var s in c['activeSprints']){
          if(s['id']==_sprintData?['id']){
            toDoTasks.add(c);
          }
        }
      }
      if(c['status'] == 'INPROGRESS'){
        for(var s in c['activeSprints']){
          if(s['id']==_sprintData?['id']){
            inProgressTasks.add(c);
          }
        }
      }
      if(c['status'] == 'VERIFY'){
        for(var s in c['activeSprints']){
          if(s['id']==_sprintData?['id']){
            verifyTasks.add(c);
          }
        }
      }
      if(c['status'] == 'DONE'){
        for(var s in c['activeSprints']){
          if(s['id']==_sprintData?['id']){
            doneTasks.add(c);
          }
        }
      }
    }

    int maxTasks = 0;

    if(toDoTasks.length > maxTasks){
      maxTasks = toDoTasks.length;
    }
    if(inProgressTasks.length > maxTasks){
      maxTasks = inProgressTasks.length;
    }
    if(verifyTasks.length > maxTasks){
      maxTasks = verifyTasks.length;
    }
    if(doneTasks.length > maxTasks){
      maxTasks = doneTasks.length;
    }

    double columnHeight = maxTasks > 0 ? (maxTasks * 75) : 100;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 850,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
          boxShadow: isDragging ? [BoxShadow(color: Colors.black54, blurRadius: 10)] : [],
        ),
        child: Column(
          children: [
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
                  if(task['name']!= null)...{
                    const SizedBox(width: 5),
                    Text(
                      task['name'],
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  },
                  if(task['taskKey'] != null)...{
                    const SizedBox(width: 5),
                    Text(
                      "  ${task['taskKey']}",
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  },
                  if(task['assignee'] != null)...{
                    Text(
                      ' • ',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      task['assignee']['fullName'],
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  },
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async{
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddSubtaskPage(task: task),
                        ),
                      );
                      setState((){
                        _isLoadingTasks = true; 
                      });
                      _loadTasksData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5AF0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      padding: EdgeInsets.only(right: 10,left: 10),
                    ),
                    child: Text(
                      Translations.get('sprint_details_page25', currentLang),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                ]
              ),

            if(!feedback)...{
              Divider(color: dividerColor, thickness: 1),
              const SizedBox(height: 5,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 190,
                    child: DragTarget<Map<String, dynamic>>(
                      onWillAcceptWithDetails: (details){
                        final parentTaskId = details.data['parentTaskId'] ?? [];
                        return parentTaskId==task['id'];
                      },
                      onAcceptWithDetails: (details) async{
                        final task = details.data;
                        final reason = _canEditStatusReason("TODO", task);
                        if (reason != null) {
                          _showCannotEditSnackBar(reason);
                        } 
                        else {
                          setState(() {
                            _isLoadingTasks = true;
                          });
                          await _updateStatus("TODO", task);
                          await _loadTasksData();
                          setState(() {
                            _isLoadingTasks = false;
                          });
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          constraints: BoxConstraints(minHeight: columnHeight),
                          decoration: BoxDecoration(
                            color: candidateData.isNotEmpty ? Colors.blue : cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: candidateData.isNotEmpty ? Colors.blue.withAlpha(150): borderColor,
                            ),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: toDoTasks.length,
                            itemBuilder: (context, index) {
                              final task = toDoTasks[index];
                              return InkWell(
                                onTap: () async{
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskDetailsPage(task: task)
                                    ),
                                  );
                                  setState((){
                                    _isLoadingTasks = true;
                                  });
                                  _loadTasksData();
                                },
                                child: Column(
                                  children: [
                                    LongPressDraggable<Map<String, dynamic>>(
                                      delay: const Duration(milliseconds: 300),
                                      data: task,
                                      feedback: _taskCardBacklog(task, true),
                                      child: _taskCardBacklog(task, false),
                                    ),
                                  ]
                                )
                              );                              
                            },
                          ),
                        );
                      }
                    )
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 190,
                    child: DragTarget<Map<String, dynamic>>(
                      onWillAcceptWithDetails: (details){
                        final parentTaskId = details.data['parentTaskId'] ?? [];
                        return parentTaskId==task['id'];
                      },
                      onAcceptWithDetails: (details) async{
                        final task = details.data;
                        final reason = _canEditStatusReason("INPROGRESS", task);
                        if (reason != null) {
                          _showCannotEditSnackBar(reason);
                        } 
                        else {
                          setState(() {
                            _isLoadingTasks = true;
                          });
                          await _updateStatus("INPROGRESS", task);
                          await _loadTasksData();
                          setState(() {
                            _isLoadingTasks = false;
                          });
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          constraints: BoxConstraints(minHeight: columnHeight),
                          decoration: BoxDecoration(
                            color: candidateData.isNotEmpty ? Colors.blue : cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: candidateData.isNotEmpty ? Colors.blue.withAlpha(150): borderColor,
                            ),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: inProgressTasks.length,
                            itemBuilder: (context, index) {
                              final task = inProgressTasks[index];
                              return InkWell(
                                onTap: () async{
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskDetailsPage(task: task)
                                    ),
                                  );
                                  setState((){
                                    _isLoadingTasks = true;
                                  });
                                  _loadTasksData();
                                },
                                child: Column(
                                  children: [
                                    LongPressDraggable<Map<String, dynamic>>(
                                      delay: const Duration(milliseconds: 300),
                                      data: task,
                                      feedback: _taskCardBacklog(task, true),
                                      child: _taskCardBacklog(task, false),
                                    ),
                                  ]
                                )
                              );                         
                            },
                          ),
                        );
                      }
                    )
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 190,
                    child: DragTarget<Map<String, dynamic>>(
                      onWillAcceptWithDetails: (details){
                        final parentTaskId = details.data['parentTaskId'] ?? [];
                        return parentTaskId==task['id'];
                      },
                      onAcceptWithDetails: (details) async{
                        final task = details.data;
                        final reason = _canEditStatusReason("VERIFY", task);
                        if (reason != null) {
                          _showCannotEditSnackBar(reason);
                        } 
                        else {
                          setState(() {
                            _isLoadingTasks = true;
                          });
                          await _updateStatus("VERIFY", task);
                          await _loadTasksData();
                          setState(() {
                            _isLoadingTasks = false;
                          });
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          constraints: BoxConstraints(minHeight: columnHeight),
                          decoration: BoxDecoration(
                            color: candidateData.isNotEmpty ? Colors.blue : cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: candidateData.isNotEmpty ? Colors.blue.withAlpha(150): borderColor,
                            ),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: verifyTasks.length,
                            itemBuilder: (context, index) {
                              final task = verifyTasks[index];
                              return InkWell(
                                onTap: () async{
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskDetailsPage(task: task)
                                    ),
                                  );
                                  setState((){
                                    _isLoadingTasks = true;
                                  });
                                  _loadTasksData();
                                },
                                child: Column(
                                  children: [
                                    LongPressDraggable<Map<String, dynamic>>(
                                      delay: const Duration(milliseconds: 300),
                                      data: task,
                                      feedback: _taskCardBacklog(task, true),
                                      child: _taskCardBacklog(task, false),
                                    ),
                                  ]
                                )
                              );                               
                            },
                          ),
                        );
                      }
                    )
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 190,
                    child: DragTarget<Map<String, dynamic>>(
                      onWillAcceptWithDetails: (details){
                        final parentTaskId = details.data['parentTaskId'] ?? [];
                        return parentTaskId==task['id'];
                      },
                      onAcceptWithDetails: (details) async{
                        final task = details.data;
                        final reason = _canEditStatusReason("DONE", task);
                        if (reason != null) {
                          _showCannotEditSnackBar(reason);
                        } 
                        else {
                          setState(() {
                            _isLoadingTasks = true;
                          });
                          await _updateStatus("DONE", task);
                          await _loadTasksData();
                          setState(() {
                            _isLoadingTasks = false;
                          });
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          constraints: BoxConstraints(minHeight: columnHeight),
                          decoration: BoxDecoration(
                            color: candidateData.isNotEmpty ? Colors.blue : cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: candidateData.isNotEmpty ? Colors.blue.withAlpha(150): borderColor,
                            ),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: doneTasks.length,
                            itemBuilder: (context, index) {
                              final task = doneTasks[index];
                              return InkWell(
                                onTap: () async{
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskDetailsPage(task: task)
                                    ),
                                  );
                                  setState((){
                                    _isLoadingTasks = true;
                                  });
                                  _loadTasksData();
                                },
                                child: Column(
                                  children: [
                                    LongPressDraggable<Map<String, dynamic>>(
                                      delay: const Duration(milliseconds: 300),
                                      data: task,
                                      feedback: _taskCardBacklog(task, true),
                                      child: _taskCardBacklog(task, false),
                                    ),
                                  ]
                                )
                               );                                
                            },
                          ),
                        );
                      }
                    )
                  ), 
                ]
              )
            }       
          ],
        ),
      )
    );
  }




























  Widget _taskCardBacklog(Map<String, dynamic> task, bool isDragging) {

    final List children = task['childTasks'] ?? [];

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 150,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
          boxShadow: isDragging ? [BoxShadow(color: Colors.black54, blurRadius: 10)] : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                const SizedBox(width: 5),
                if(task['name'] != null)
                  Text(
                    task['name'],
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                if(task['taskKey'] != null)
                  Text(
                    "  ${task['taskKey']} ",
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if(task['assignee'] != null)...{
                  Text(
                      ' • ',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                  ),
                  Text(
                    task['assignee']['fullName'],
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                }
              ],
            ),
            const SizedBox(height: 8),
            if (children.isNotEmpty) ...{
              Divider(color: dividerColor, thickness: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: task['childTasks'].length,
                itemBuilder: (context, index) {
                  final child = task['childTasks'][index];
                  return InkWell(
                    onTap: () async{
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailsPage(task: child)
                        ),
                      );
                      setState((){
                        _isLoadingTasks = true;
                      });
                      _loadTasksData();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.subdirectory_arrow_right, size: 12, color: subtitleColor),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTaskBackgroundColor(child['type']),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getTaskColor(child['type']), width: 1),
                            ),
                            child: Text(
                              _translateType(child['type']),
                              style: TextStyle(
                                color: _getTaskColor(child['type']),
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            child['name'],
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  );
                }
              )
            }
          ]   
        )
      )
    );
  }
}