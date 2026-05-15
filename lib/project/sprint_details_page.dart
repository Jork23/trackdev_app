import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import 'add_task_page.dart';
import 'add_subtask_page.dart';
import 'task_details_page.dart';
import '../../utils/ui_helpers.dart';

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

  String _selectedColumn = 'BACKLOG';

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

  Color _getSprintStatusColor(String type) {
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

  Color _getSprintStatusBgColor(String type) {
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

  Color _getColumnColor(String col) {
    switch (col) {
      case 'BACKLOG':    return const Color(0xFFEF4444);
      case 'TODO':       return const Color(0xFFF59E0B);
      case 'INPROGRESS': return const Color(0xFF3B82F6);
      case 'VERIFY':     return const Color(0xFF8B5CF6);
      case 'DONE':       return const Color(0xFF22C55E);
      default:           return const Color(0xFF64748B);
    }
  }

  final Map<String, Map<String, String>> _localTranslations = {
    'ca': {
      'transitionFromBacklog': 'Des de Backlog només pots passar a Prioritzada.',
      'transitionFromTodo': 'Des de Prioritzada només pots passar a En Progrés o Backlog.',
      'transitionToVerifyNeedsPR': 'Per passar a En Verificació necessites tenir almenys una Pull Request vinculada.',
      'transitionToDoneNeedsVerify': 'No pots passar directament a Finalitzada. Has de passar per En Verificació primer.',
      'transitionFromInProgress': 'Des de En Progrés només pots passar a Prioritzada o En Verificació si té almenys una Pull Request vinculada.',
      'transitionFromVerify': 'Des de En Verificació només pots passar a Finalitzada.',
      'transitionFromDone': 'Una tasca Finalitzada només pot tornar a En Verificació.',
      'transitionNotAllowed': 'Transició no permesa.',
      'changeSprintUserStoryNeedsBacklog': 'Per canviar el sprint d\'una Història d\'Usuari, totes les subtasques han d\'estar al Backlog.',
      'subtaskCannotGoBacklog': 'Una subtasca no pot tornar al Backlog.',
      'subtaskActiveSprintOnlyFuture': 'Una subtasca en un sprint actiu només pot moure\'s a un sprint futur.',
      'subtaskFutureSprintCannotMove': 'Una subtasca en un sprint futur no es pot moure.',
      'futureSprintOnlyBacklog': 'Una tasca en un sprint futur només pot tornar al Backlog.',
    },
    'es': {
      'transitionFromBacklog': 'Desde Backlog solo puedes pasar a Priorizada.',
      'transitionFromTodo': 'Desde Priorizada solo puedes pasar a En Progreso o Backlog.',
      'transitionToVerifyNeedsPR': 'Para pasar a En Verificación necesitas tener al menos una Pull Request vinculada.',
      'transitionToDoneNeedsVerify': 'No puedes pasar directamente a Finalizada. Debes pasar por En Verificación primero.',
      'transitionFromInProgress': 'Desde En Progreso solo puedes pasar a Priorizada o En Verificación si tiene al menos una Pull Request vinculada.',
      'transitionFromVerify': 'Desde En Verificación solo puedes pasar a Finalizada.',
      'transitionFromDone': 'Una tarea Finalizada solo puede volver a En Verificación.',
      'transitionNotAllowed': 'Transición no permitida.',
      'changeSprintUserStoryNeedsBacklog': 'Para cambiar el sprint de una Historia de Usuario, todas las subtareas deben estar en el Backlog.',
      'subtaskCannotGoBacklog': 'Una subtarea no puede volver al Backlog.',
      'subtaskActiveSprintOnlyFuture': 'Una subtarea en un sprint activo solo puede moverse a un sprint futuro.',
      'subtaskFutureSprintCannotMove': 'Una subtarea en un sprint futuro no se puede mover.',
      'futureSprintOnlyBacklog': 'Una tarea en un sprint futuro solo puede volver al Backlog.',
    },
    'en': {
      'transitionFromBacklog': 'From Backlog you can only move to Prioritized.',
      'transitionFromTodo': 'From Prioritized you can only move to In Progress or Backlog.',
      'transitionToVerifyNeedsPR': 'To move to In Verification you need to have at least one linked Pull Request.',
      'transitionToDoneNeedsVerify': 'You cannot move directly to Done. You must go through In Verification first.',
      'transitionFromInProgress': 'From In Progress you can only move to Prioritized or In Verification if it has at least one linked Pull Request.',
      'transitionFromVerify': 'From In Verification you can only move to Done.',
      'transitionFromDone': 'A Done task can only return to In Verification.',
      'transitionNotAllowed': 'Transition not allowed.',
      'changeSprintUserStoryNeedsBacklog': 'To change a User Story\'s sprint, all subtasks must be in the Backlog.',
      'subtaskCannotGoBacklog': 'A subtask cannot return to the Backlog.',
      'subtaskActiveSprintOnlyFuture': 'A subtask in an active sprint can only be moved to a future sprint.',
      'subtaskFutureSprintCannotMove': 'A subtask in a future sprint cannot be moved.',
      'futureSprintOnlyBacklog': 'A task in a future sprint can only return to the Backlog.',
    }
  };

  String _getMsg(String key) {
    return _localTranslations[currentLang]?[key] ?? key;
  }

 
  String? _canEditStatusReason(String newStatus, Map<String,dynamic> task) {

    if(_userData!['id'] != task['assignee']?['id']){
      return Translations.get('tasks.deleteBlockedNotAssignee', currentLang);
    }

    final current = task['status'];
    final hasPullRequests = task['pullRequests'] != null && task['pullRequests'].isNotEmpty;

    if (current == newStatus) return null;

    switch (current) {
      case 'BACKLOG':
        if (newStatus == 'TODO') return null;
        return _getMsg('transitionFromBacklog');

      case 'TODO':
        if (newStatus == 'INPROGRESS' || newStatus == 'BACKLOG') return null;
        return _getMsg('transitionFromTodo');

      case 'INPROGRESS':
        if (newStatus == 'TODO') return null;
        if (newStatus == 'VERIFY') {
          if (!hasPullRequests) {
            return _getMsg('transitionToVerifyNeedsPR');
          }
          return null;
        }
        if (newStatus == 'DONE') {
          return _getMsg('transitionToDoneNeedsVerify');
        }
        return _getMsg('transitionFromInProgress');

      case 'VERIFY':
        if (newStatus == 'DONE') return null;
        return _getMsg('transitionFromVerify');

      case 'DONE':
        if (newStatus == 'VERIFY') return null;
        return _getMsg('transitionFromDone');

      default:
        return Translations.get('transitionNotAllowed', currentLang);
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
      return Translations.get('tasks.deleteBlockedNotAssignee', currentLang);
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
        return _getMsg('changeSprintUserStoryNeedsBacklog');
      }
      return null;
    }

    if(task['parentTaskId'] != null){
      if(goingToBacklog){
        return _getMsg('subtaskCannotGoBacklog');
      }
      if(currentlyInBacklog){
        return null;
      }
      if(currentIsActive){
        if (targetIsFuture) return null;
        return _getMsg('subtaskActiveSprintOnlyFuture');
      }
      if(currentIsFuture){
        return _getMsg('subtaskFutureSprintCannotMove');
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
      return _getMsg('futureSprintOnlyBacklog');
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
      } 
      else {
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
    } 
    catch (e) {
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

    } 
    catch (e) {
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
        toolbarHeight: 50,
        title: _buildSprintAppBar(), 
      ),
      body: Column(
        children: [
          _buildSprintInfo(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSprintStatusButton('BACKLOG'),
                  _buildSprintStatusButton('TODO'),
                  _buildSprintStatusButton('INPROGRESS'),
                  _buildSprintStatusButton('VERIFY'),
                  _buildSprintStatusButton('DONE'),
                ],
              ),
            ),
          ),
          if(_selectedColumn == 'BACKLOG')
            _buildSprintColumnBacklog(backlogTasks)
          else
            _buildSprintColumnNoBacklog(userStories, usersTasks)
        ]
      )
    );
  }

  Widget _buildSprintInfo(){
    return Padding(
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
                    color: _getSprintStatusBgColor(_sprintData?['status']),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getSprintStatusColor(_sprintData?['status']), width: 1),
                  ),
                  child: Text(
                    _sprintData?['status'],
                    style: TextStyle(
                      color: _getSprintStatusColor(_sprintData?['status']),
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
                  "${UIHelpers.formatDate(_sprintData?['startDate'])} - ${UIHelpers.formatDate(_sprintData?['endDate'])}",
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
    );
  }

  Widget _buildSprintStatusButton(String col) {

    final isSelected = _selectedColumn == col;
    
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) {
        final activeSprints = details.data['activeSprints'] as List? ?? [];
        if (col == 'BACKLOG') return activeSprints.isNotEmpty;
        return true;
      },
      onAcceptWithDetails: (details) async {
        final task = details.data;
        final activeSprints = task['activeSprints'] as List? ?? [];
        final bool comesFromBacklog = activeSprints.isEmpty;
        if (col == 'BACKLOG') {
          final reason = _canEditSprintReason(task, -1);
          if (reason != null) {
            _showCannotEditSnackBar(reason);
          } 
          else {
            await _updateSprint(-1, task);
            setState((){
               _isLoadingTasks = true;
            });
            await _loadTasksData();
            setState((){
              _isLoadingTasks = false;
            });
          }
        }
        else if(comesFromBacklog){
          final sprintId = _sprintData?['id'] as int?;
          final reason = _canEditSprintReason(task, sprintId);
          if (reason != null) {
            _showCannotEditSnackBar(reason);
          }
          else{
            await _updateSprint(sprintId, task);
            setState((){
               _isLoadingTasks = true;
            });
            await _loadTasksData();
            setState((){
              _isLoadingTasks = false;
            });
          }
        }
        else {
          final reason = _canEditStatusReason(col, task);
          if (reason != null) {
            _showCannotEditSnackBar(reason);
          } 
          else {
            await _updateStatus(col, task);
            setState((){
               _isLoadingTasks = true;
            });
            await _loadTasksData();
            setState((){
              _isLoadingTasks = false;
            });
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ElevatedButton(
            onPressed: (){
              setState((){
                _selectedColumn = col;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? _getColumnColor(col) : cardColor,
              foregroundColor: isSelected ? Colors.white : _getColumnColor(col),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: _getColumnColor(col), width: 2),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
            UIHelpers.translateStatus(col, currentLang),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSprintColumnBacklog(List<dynamic> backlogTasks){
    return Expanded(
      child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: backlogTasks.length,
            itemBuilder: (context, index) {
              final task = backlogTasks[index];
              return InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsPage(task: task),
                    ),
                  );
                  setState(() {
                    _isLoadingTasks = true;
                  });
                  _loadTasksData();
                },
                child: LongPressDraggable<Map<String, dynamic>>(
                  delay: const Duration(milliseconds: 300),
                  data: task,
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 300,
                      child: _buildSprintTaskCard(task, true),
                    ),
                  ),
                  child: _buildSprintTaskCard(task, false),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ],
        )
      )
    );
  }

  Widget _buildSprintColumnNoBacklog(List<dynamic> userStories, List<Map<String,dynamic>> usersTasks){
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userStories.length,
              itemBuilder: (context, index) {
                final task = userStories[index];
                return InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsPage(task: task),
                      ),
                    );
                    setState(() {
                      _isLoadingTasks = true;
                    });
                    _loadTasksData();
                  },
                  child: LongPressDraggable<Map<String, dynamic>>(
                    delay: const Duration(milliseconds: 300),
                    data: task,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 300,
                        child: _buildSprintTaskCardUserStory(task, true),
                      ),
                    ),
                    child: _buildSprintTaskCardUserStory(task, false),
                  ),
                );
              },
            ),
            if (usersTasks.isNotEmpty)
              _buildSprintUnassignedTasksRow(usersTasks),
            const SizedBox(height: 150),
          ],
        ),
      )
    );
  }

  Widget _buildSprintUnassignedTasksRow(List<Map<String, dynamic>> usersTasks) {

    final List<Map<String, dynamic>> selectedTasks = [];

    for (var c in usersTasks) {
      if (c['status'] == _selectedColumn) {
        for (var s in c['activeSprints']) {
          if (s['id'] == _sprintData?['id']) {
            selectedTasks.add(c);
            break;
          }
        }
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                Translations.get('sprints.unassignedTasks', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (selectedTasks.isNotEmpty) ...{
            Divider(color: dividerColor, thickness: 1, height: 16),
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedTasks.length,
              itemBuilder: (context, index) {
                final task = selectedTasks[index];
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
                  child: LongPressDraggable<Map<String, dynamic>>(
                    delay: const Duration(milliseconds: 300),
                    data: task,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 300,
                        child: _buildSprintTaskCard(task, true),
                      ),
                    ),
                    child: _buildSprintTaskCard(task, false),
                  ), 
                );
              },
            ),
          }
          else...{
            Divider(color: dividerColor, thickness: 1, height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Text(
                    Translations.get('sprints.noTasksInSprint', currentLang),
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ), 
          },
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSprintTaskCardUserStory(Map<String, dynamic> task, bool feedback) {

    final List children = task['childTasks'] ?? [];

    final List<Map<String, dynamic>> visibleSubtasks = [];
    if(!feedback) {
      for(var c in children) {
        if (_selectedColumn == 'BACKLOG') {
          if((c['activeSprints'] as List).isEmpty){
            visibleSubtasks.add(c);
          }
        } 
        else{
          if(c['status'] == _selectedColumn){
            for(var s in (c['activeSprints'] as List)){
              if(s['id'] == _sprintData?['id']){
                visibleSubtasks.add(c);
                break;
              }
            }
          }
        }
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: UIHelpers.getTaskBackgroundColor(task['type']),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: UIHelpers.getTaskColor(task['type']), width: 1),
                          ),
                          child: Text(
                            UIHelpers.translateType(task['type'], currentLang),
                            style: TextStyle(
                              color: UIHelpers.getTaskColor(task['type']),
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (task['name'] != null) ...{
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              task['name'],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        },
                      ],
                    ),
                    Row(
                      children: [
                        if (task['taskKey'] != null) ...{
                          Text(
                            task['taskKey'],
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        },
                        if (task['assignee'] != null) ...{
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: subtitleColor, 
                              fontSize: 15, 
                              fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Text(
                              task['assignee']['fullName'],
                              style: TextStyle(color: 
                                subtitleColor, 
                                fontSize: 12, 
                                fontWeight: FontWeight.bold
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        },
                      ],
                    ),
                  ],
                ),
              ),
              if (!feedback)
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddSubtaskPage(task: task)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: Text(
                    Translations.get('sprints.addSubtask', currentLang),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          if (!feedback && _selectedColumn != 'BACKLOG') ...{
            Divider(color: dividerColor, thickness: 1, height: 16),
            if (visibleSubtasks.isEmpty)...{
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Text(
                      Translations.get('sprints.unassignedTasks', currentLang),
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            }
            else...{
              Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleSubtasks.length,
                    itemBuilder: (context, index) {
                      final task = visibleSubtasks[index];
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
                              feedback: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: 300,
                                  child: _buildSprintTaskCard(task, true),
                                ),
                              ),
                              child: _buildSprintTaskCard(task, false),
                            ),
                          ]
                        )
                      );
                    }
                  )
                ]
              )
            }
          },
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSprintTaskCard(Map<String, dynamic> task, bool isDragging) {

    final List children = task['childTasks'] ?? [];

    return Container(
      width: double.infinity,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: UIHelpers.getTaskBackgroundColor(task['type']),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: UIHelpers.getTaskColor(task['type']), width: 1),
                          ),
                          child: Text(
                            UIHelpers.translateType(task['type'], currentLang),
                            style: TextStyle(
                              color: UIHelpers.getTaskColor(task['type']),
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        if (task['name'] != null)
                          Expanded(
                            child: Text(
                              task['name'],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    if (task['taskKey'] != null)
                      Text(
                        "  ${task['taskKey']}",
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              if (task['assignee'] != null) ...{
                CircleAvatar(
                  radius: 15,
                  backgroundColor: UIHelpers.hexToColor(task['assignee']['color']),
                  child: Text(
                    task['assignee']['capitalLetters'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    task['assignee']['fullName'],
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
              },
            ],
          ),
          const SizedBox(height: 8),
          if (children.isNotEmpty && !isDragging) ...{
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
                            color: UIHelpers.getTaskBackgroundColor(child['type']),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: UIHelpers.getTaskColor(child['type']), width: 1),
                          ),
                          child: Text(
                            UIHelpers.translateType(child['type'], currentLang),
                            style: TextStyle(
                              color: UIHelpers.getTaskColor(child['type']),
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
    );
  }

  Widget _buildSprintAppBar(){
    return Row(
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
              Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 16
              ),
              Text(
                Translations.get('common.back', currentLang),
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
              Translations.get('tasks.addTask', currentLang),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ]
    );
  }
}