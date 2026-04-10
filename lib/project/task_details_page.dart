import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import 'add_subtask_page.dart';
import 'sprint_details_page.dart';
import 'project_details_page.dart';


class TaskDetailsPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> with Theme_Page{

  final storage = const FlutterSecureStorage();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newCommentController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final Map<int, TextEditingController> _commentControllers = {};
  
  bool isEditingDescription = false;
  bool isEditingName = false;
  bool isEditingSprint = false;
  bool isEditingNewComment = false;
  bool isEditingPoints = false;
  bool isEditingStatus = false;
  bool isEditingType = false;
  bool isDeletingTask = false;
  final Map<int, bool> _editingComments = {};

  late bool isTaskAssignen;

  int? _selectedSprintId;

  Map<String, dynamic>? userData;
  Map<String, dynamic>? commentData;
  Map<String, List<dynamic>> pullRequestData = {};
  Map<String, dynamic>? task;
  Map<String, dynamic>? parentTaskData;

  bool isLoadingUser = true;
  bool isLoadingTask = true;
  bool isLoadingComment = true;
  bool isLoadingSprint = false;
  bool isLoadingPullRequests = true;
  bool isLoadingParentTask = true;

  final Map<String, String> taskType = {
    'TASK': 'Tasca',
    'BUG': 'Error',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCommentData();
    _loadTask();
    _loadAllPullRequestData();
    if(widget.task['parentTaskId'] != null){
      _loadParentTask();
    }
    else{
      isLoadingParentTask = false;
    }
    isTaskAssignen = widget.task['assignee'] != null;
    if (widget.task['activeSprints'] != null && widget.task['activeSprints'].isNotEmpty) {
      _selectedSprintId = widget.task['activeSprints'][0]['id'];
    }
    else {
      _selectedSprintId = -1;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _newCommentController.dispose();
    _nameController.dispose();
    _pointsController.dispose();
    for(var controller in _commentControllers.values){
      controller.dispose();
    }
    super.dispose();
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

  String? _canDeleteTaskReason() {

    if (task!['status'] == 'DONE') {
      return Translations.get('task_details_page55', currentLang);
    }

    if (task!['childTasks'].length != 0) {
      return Translations.get('task_details_page56', currentLang);
    }

    return null;
  }

  String? _canEditPointsReason() {
    if(task!['status'] != 'VERIFY' && task!['status'] != 'DONE') {
      return Translations.get('task_details_page57', currentLang);
    }
    return null;
  }

  String? _canEditTypeReason() {
    if (task!['type'] == 'USER_STORY') {
      return Translations.get('task_details_page58', currentLang);
    }
    if (task!['type'] == 'BUG') {
      return Translations.get('task_details_page59', currentLang);
    }
    return null;
  }

  String? _canEditStatusReason(String newStatus) {
    final current = task!['status'];
    final hasPullRequests = task!['pullRequests'] != null && task!['pullRequests'].isNotEmpty;

    if (current == newStatus) return null;

    switch (current) {
      case 'BACKLOG':
        if (newStatus == 'TODO') return null;
        return Translations.get('task_details_page60', currentLang);

      case 'TODO':
        if (newStatus == 'INPROGRESS' || newStatus == 'BACKLOG') return null;
        return Translations.get('task_details_page61', currentLang);

      case 'INPROGRESS':
        if (newStatus == 'TODO') return null;
        if (newStatus == 'VERIFY') {
          if (!hasPullRequests) {
            return Translations.get('task_details_page62', currentLang);
          }
          return null;
        }
        if (newStatus == 'DONE') {
          return Translations.get('task_details_page63', currentLang);
        }
        return Translations.get('task_details_page64', currentLang);

      case 'VERIFY':
        if (newStatus == 'DONE') return null;
        return Translations.get('task_details_page65', currentLang);

      case 'DONE':
        if (newStatus == 'VERIFY') return null;
        return Translations.get('task_details_page66', currentLang);

      default:
        return Translations.get('task_details_page67', currentLang);
    }
  }

  String? _canEditSprintReason(int? newSprintId) {

    final bool goingToBacklog = newSprintId == -1;
    final currentSprints = task!['activeSprints'] as List;
    final bool currentlyInBacklog = currentSprints.isEmpty;
    final projectSprints = task!['project']['sprints'] as List;

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

    if( task!['type'] == 'USER_STORY'){
      if(!_isAllSubstasksInBackLog()){
        return Translations.get('task_details_page68', currentLang);
      }
      return null;
    }

    if(task!['parentTaskId'] != null){
      if(goingToBacklog){
        return Translations.get('task_details_page69', currentLang);
      }
      if(currentlyInBacklog){
        return null;
      }
      if(currentIsActive){
        if (targetIsFuture) return null;
        return Translations.get('task_details_page70', currentLang);
      }
      if(currentIsFuture){
        return Translations.get('task_details_page71', currentLang);
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
      return Translations.get('task_details_page72', currentLang);
    }

    return null;
  }

  bool _isLoading(){
    return isLoadingUser || isLoadingTask || isLoadingComment || isLoadingSprint || isLoadingPullRequests || isLoadingParentTask;
  }

  bool _isAllSubstasksInBackLog(){

    final subtasks = task?['childTasks'] as List?;

    if (subtasks == null || subtasks.isEmpty) return true;

    for (var sub in subtasks) {
      if (sub['status'] != 'BACKLOG') {
        return false;
      }
    }

    return true;

  }

  bool _isUnassignedSubtasks(){

    final subtasks = task?['childTasks'] as List?;

    if (subtasks == null || subtasks.isEmpty) return false;

    for (var sub in subtasks) {
      if (sub['assignee'] == null) {
        return true;
      }
    }

    return false;
  }

  Future<void> _assignAllUnassignedSubtasks() async {
    final subtasks = task?['childTasks'] as List?;

    if (subtasks == null || subtasks.isEmpty) return;

    for (var sub in subtasks) {
      if (sub['assignee'] == null) {
        await _assignSubtask(sub['id']);
      }
    }

    setState(() {
      isLoadingTask=true;
      _loadTask(); 
    });

  }

  Future<void> _assignSubtask(int subtaskId) async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/$subtaskId/assign');
    try {
      await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

    }
    catch (e){
      debugPrint("Error: $e");
    }
  }


  Future<void> _assignTask() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}/assign');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _loadTask();
          isTaskAssignen = true;
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
  }

  Future<void> _unassignTask() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/${task!['id']}/assign');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _loadTask();
          isTaskAssignen = false;
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
  }

  Future<void> _updateComment(int commentId, String content) async {
    String? token = await storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${task!['id']}/comments/$commentId');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content': content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _loadCommentData();
      }
      else{
        isLoadingComment = false;
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _editingComments[commentId] = false;
      });
    }
  }

  Future<void> _addComment() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/${task!['id']}/comments');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content': _newCommentController.text,
        }),
      );
      if (response.statusCode == 201) {
        _newCommentController.clear();
        _loadCommentData();
      }
      else{
        isLoadingComment = false;
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isEditingNewComment = false;
      });
    }
  }
  
  Future<void> _loadCommentData() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}/comments');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          commentData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isLoadingComment = false;
      });
    }
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
        isLoadingUser = false;
      });
    }
  }

  Future<void> _loadAllPullRequestData() async {
    setState(() => isLoadingPullRequests = true);
    String? token = await storage.read(key: 'auth_token');

    try {
      if (widget.task['pullRequests'] != null) {
        for (var pr in widget.task['pullRequests']) {
          final url = Uri.parse('https://trackdev.org/api/pull-requests/${pr['id']}/history');

          final response = await http.get(
            url,
            headers: {'Authorization': 'Bearer $token'},
          );

          if(response.statusCode == 200){
            setState(() {
              pullRequestData[pr['id']] = jsonDecode(response.body)['history'];
            });
          }
        }
      }
    } 
    catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isLoadingPullRequests = false;
      });
    }
  }

  Future<void> _loadTask() async {

    String? token = await storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode ==  200 || response.statusCode == 204) {
        setState(() {
          task = jsonDecode(response.body);
          isLoadingTask=false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isLoadingTask=false;
      });
    }

  }

  Future<void> _loadParentTask() async {

    String? token = await storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['parentTaskId']}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode ==  200 || response.statusCode == 204) {
        setState(() {
          parentTaskData = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isLoadingParentTask=false;
      });
    }

  }

  Future<void> _updateSprint(int? sprintId) async {
    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}');


    if(sprintId == -1){
      try {
        final response = await http.patch(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'activeSprints': [],
          }),
        );
        if (response.statusCode == 200  || response.statusCode == 204) {
          setState(() {
            _loadTask();
          });
        }
      } catch (e) {
        debugPrint("Error: $e");
      }
    } 
    else{
       try {
        final response = await http.patch(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'activeSprints': [sprintId],
            'status' : 'TODO',
          }),
        );

        if (response.statusCode == 200  || response.statusCode == 204) {
          setState(() {
            isLoadingTask = true;
            _loadTask();
          });
        }
      } catch (e) {
        debugPrint("Error: $e");
      }
      finally{
        setState((){
          isLoadingSprint = false;
        });
      }
    }
  }

  Future<void> _updateDescription() async {
    String? token = await storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'description': _descriptionController.text,
        }),
      );

      if (response.statusCode == 200  || response.statusCode == 204) {
        setState(() {
          _loadTask();
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isEditingDescription = false;
      });
    }
  }

  Future<void> _updateStatus(String? newStatus) async {
    String? token = await storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${task!['id']}');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200  || response.statusCode == 204) {
        setState(() {
          _loadTask();
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isEditingStatus = false;
      });
    }
  }

  Future<void> _updateType(String? newType) async {
    String? token = await storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${task!['id']}');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': newType,
        }),
      );

      if (response.statusCode == 200  || response.statusCode == 204) {
        setState(() {
          _loadTask();
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isEditingType = false;
      });
    }
  }

  Future<void> _updateName() async {
    String? token = await storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
        }),
      );

      if (response.statusCode == 200  || response.statusCode == 204) {
        setState(() {
          _loadTask();
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isEditingName = false;
      });
    }
  }

  Future<void> _updatePoints() async {
    String? token = await storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${task!['id']}');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'estimationPoints': int.parse(_pointsController.text),
        }),
      );

      if (response.statusCode == 200  || response.statusCode == 204) {
        setState(() {
          _loadTask();
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isEditingPoints = false;
      });
    }
  }

  Future<void> _deleteTask() async {
    String? token = await storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}');
    try {
      await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

    } catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isLoadingTask=false;
      });
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
        return Translations.get('task_details_page42', currentLang);
      case "TASK":
        return Translations.get('task_details_page43', currentLang);
      case "USER_STORY":
        return Translations.get('task_details_page44', currentLang);
      default:
        return type;
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case "BACKLOG":
        return "Backlog";
      case "TODO":
        return Translations.get('task_details_page45', currentLang);
      case "INPROGRESS":
        return Translations.get('task_details_page46', currentLang);
      case "VERIFY":
        return Translations.get('task_details_page47', currentLang);
      case "DONE":
        return Translations.get('task_details_page48', currentLang);
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "BACKLOG":
        return Icons.description_outlined; 
      case "TODO":
        return Icons.access_time_outlined;
      case "INPROGRESS":
        return Icons.access_time_outlined;
      case "VERIFY":
        return Icons.error_outline;
      case "DONE":
        return Icons.check_circle_outline;
      default:
        return Icons.error_outline;
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

    final projectSprints = task?['project']['sprints'] ?? [];
    final commentsTask = commentData?['comments'] ?? [];

    List<dynamic> listSprints = [];

    listSprints.add({'id': -1, 'name': 'Backlog'});

    for (var sprint in projectSprints) {
      if (sprint['status'] == 'ACTIVE' || sprint['status'] == 'DRAFT') {
        listSprints.add(sprint);
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
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: iconColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              Translations.get('task_details_page32', currentLang),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            if (isTaskAssignen && userData!['id'] == task?['assignee']?['id']) ...{
              const Spacer(),
              Column(
                children: [
                  if (!isDeletingTask)
                    TextButton(
                      onPressed: () {
                        final String? reason  = _canDeleteTaskReason();
                        if (reason  != null) {
                          setState(() { 
                            isDeletingTask = false; 
                          });
                          _showCannotEditSnackBar(reason);
                          return;
                        }
                        setState(() {
                          isDeletingTask = true;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF2C1619),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFFF5252),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Eliminar Tasca',
                            style: TextStyle(
                              color: const Color(0xFFFF5252), 
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                ]
              )
            }
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDeletingTask)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              isDeletingTask = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: borderColor),
                          ),
                          child: Text(
                            Translations.get('task_details_page28', currentLang),
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ),                      
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isLoadingTask = true;
                            });
                            await _deleteTask();
                            if (!mounted) return;
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 240, 45, 45),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            Translations.get('task_details_page27', currentLang),
                            style: const TextStyle(
                              color: Colors.white, 
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task!['status']),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(
                    _getStatusIcon(task!['status']),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getTaskBackgroundColor(task!['type']),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getTaskColor(task!['type'])),
                            ),
                            child: Text(
                              _translateType(task!['type']),
                              style: TextStyle(
                                color: _getTaskColor(task!['type']),
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(task!['status']),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text(
                              _translateStatus(task!['status']),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF064E3B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF34D399)),
                            ),
                            child: Text(
                              '${task!['estimationPoints']} ${Translations.get('task_details_page8', currentLang)}',
                              style: TextStyle(
                                color: const Color(0xFF34D399),
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if(!isEditingName)
                        Row(
                          children: [
                            Text(
                              task!['taskKey'],
                              style: TextStyle(
                                color: subtitleColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              task!['name'],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                              ),
                            ),
                            if (!isEditingName && isTaskAssignen)...{
                              if(userData!['id'] == task?['assignee']?['id'])...{
                                IconButton(
                                  icon: Icon(Icons.edit, color: iconColor, size: 15),
                                  onPressed: () {
                                    setState(() {
                                      isEditingName = true;
                                      _nameController.text = task!['name'];
                                    });
                                  },
                                )
                              }
                            }
                          ]
                        )
                      else
                        Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: Translations.get('task_details_page31', currentLang),
                                hintStyle: TextStyle(color: hintColor),
                                filled: true,
                                fillColor: inputFillColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF2D5AF0), width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        isEditingName = false;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: BorderSide(color: borderColor),
                                    ),
                                    child: Text(
                                      Translations.get('task_details_page28', currentLang), 
                                      style: TextStyle(color: textColor)
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: (){
                                      _updateName();
                                      setState(() {
                                        isLoadingTask = true;
                                      });    
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2D5AF0),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Text(
                                      Translations.get('task_details_page27', currentLang), 
                                      style: const TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: iconColor,
                            size: 13,
                          ),
                          Text(
                            '${Translations.get('task_details_page34', currentLang)} ${task!['createdAt']}',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 10,
                            ),
                          ),
                        ]
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            color: iconColor,
                            size: 13,
                          ),
                          Text(
                            '${Translations.get('task_details_page35', currentLang)} ${task!['reporter']?['fullName']}',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),



            // 1. Descripció
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Icon(Icons.description, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          Translations.get('task_details_page14', currentLang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (!isEditingDescription && isTaskAssignen)...{
                          if(userData!['id'] == task?['assignee']?['id'])...{
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                              onPressed: () {
                                setState(() {
                                  isEditingDescription = true;
                                  _descriptionController.text = task!['description'] ?? '';
                                });
                              },
                            )
                          }
                        }
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isEditingDescription)
                          Column(
                            children: [
                              TextField(
                                controller: _descriptionController,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText: Translations.get('task_details_page30', currentLang),
                                  hintStyle: TextStyle(color: hintColor),
                                  filled: true,
                                  fillColor: inputFillColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF2D5AF0), width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          isEditingDescription = false;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: BorderSide(color: borderColor),
                                      ),
                                      child: Text(
                                        Translations.get('task_details_page28', currentLang), 
                                        style: TextStyle(color: textColor)
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: (){
                                        _updateDescription();
                                        setState(() {
                                          isLoadingTask = true;
                                        });    
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2D5AF0),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: Text(
                                        Translations.get('task_details_page27', currentLang), 
                                        style: const TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        else
                          Text(
                            (task!['description'] == null || task!['description'].isEmpty) ? Translations.get('task_details_page15', currentLang) : task!['description'],
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),



            // 2. Detalls
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      Translations.get('task_details_page1', currentLang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),                     
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translations.get('task_details_page2', currentLang),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                          ),
                        ),
                        if(isTaskAssignen)...{
                          if(userData!['id'] != task?['assignee']['id'])...{
                            const SizedBox(height: 5),
                          }
                        },
                        Row(
                          children: [
                            if(isTaskAssignen)...{
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: hexToColor(task!['assignee']['color']),
                                child: Text(
                                  task!['assignee']['capitalLetters'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                task!['assignee']['fullName'],
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 16,
                                ),
                              ),
                            }
                            else...{
                              Text(
                                Translations.get('task_details_page3', currentLang),
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 16,
                                ),
                              ),
                            },
                            if(isTaskAssignen)...{
                              if(userData!['id'] == task?['assignee']['id'])...{
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    _unassignTask();
                                    setState(() {
                                      isLoadingTask = true;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C1619),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.group_outlined,
                                        color: Color(0xFFFF5252),
                                        size: 12,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        Translations.get('task_details_page4', currentLang),
                                        style: TextStyle(
                                          color: const Color(0xFFFF5252), 
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              }
                            }
                            else...{
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  _assignTask();
                                  setState(() {
                                    isLoadingTask = true;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.group_outlined,
                                      color: Color(0xFF93C5FD),
                                      size: 12,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      Translations.get('task_details_page5', currentLang),
                                      style: TextStyle(
                                        color: const Color(0xFF93C5FD), 
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            },
                          ]
                        ),
                        SizedBox(height: 5),
                        Divider(color: dividerColor, thickness: 1),
                        SizedBox(height: 5),
                        Text(
                          Translations.get('task_details_page6', currentLang),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: hexToColor(task!['reporter']['color']),
                              child: Text(
                                task!['reporter']['capitalLetters'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              task!['reporter']['fullName'],
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 16,
                              ),                             
                            ),
                          ]
                        ),
                        SizedBox(height: 5),
                        Divider(color: dividerColor, thickness: 1),
                        SizedBox(height: 5),
                        Text(
                          Translations.get('task_details_page7', currentLang),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 5),
                        if (isEditingPoints)
                          Column(
                            children: [
                              TextField(
                                controller: _pointsController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText: task?['estimationPoints'].toString(),
                                  hintStyle: TextStyle(color: hintColor),
                                  filled: true,
                                  fillColor: inputFillColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF2D5AF0), width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          isEditingPoints = false;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: BorderSide(color: borderColor),
                                      ),
                                      child: Text(
                                        Translations.get('task_details_page28', currentLang),
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _updatePoints();      
                                        setState(() {
                                          isLoadingTask = true;
                                        });                                
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2D5AF0),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: Text(
                                        Translations.get('task_details_page27', currentLang),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF064E3B),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF34D399)),
                                ),
                                child: Text(
                                  '${task!['estimationPoints']} ${Translations.get('task_details_page8', currentLang)}',
                                  style: TextStyle(
                                    color: const Color(0xFF34D399),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (isTaskAssignen && userData!['id'] == task?['assignee']['id'])
                                IconButton(
                                  icon: Icon(Icons.edit, color: iconColor, size: 15),
                                  onPressed: () {
                                    final reason = _canEditPointsReason();
                                    if (reason != null) {
                                      _showCannotEditSnackBar(reason);
                                      return;
                                    }
                                    setState(() {
                                      isEditingPoints = true;
                                      _pointsController.text = task!['estimationPoints'].toString();
                                    });
                                  },
                                ),
                            ]
                          ),
                        SizedBox(height: 5),
                        Divider(color: dividerColor, thickness: 1),
                        SizedBox(height: 5),
                        Text(
                          Translations.get('task_details_page9', currentLang),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 5),
                        if (!isEditingType)...{
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getTaskBackgroundColor(task!['type']),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _getTaskColor(task!['type'])),
                                ),
                                child: Text(
                                  _translateType(task!['type']),
                                  style: TextStyle(
                                    color: _getTaskColor(task!['type']),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (isTaskAssignen && userData!['id'] == task?['assignee']['id'])
                                IconButton(
                                  icon: Icon(Icons.edit, color: iconColor, size: 16),
                                  onPressed: () {
                                    final reason = _canEditTypeReason();
                                    if (reason != null) {
                                      _showCannotEditSnackBar(reason);
                                      return;
                                    }
                                    setState(() {
                                      isEditingType = true;
                                    });
                                  },
                                ),
                            ]
                          ),
                        }
                        else...{
                          DropdownMenu<String>(
                            initialSelection: task!['type'],
                            width: MediaQuery.of(context).size.width,
                            textStyle: TextStyle(color: textColor, fontSize: 14),
                            inputDecorationTheme: InputDecorationTheme(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            menuStyle: MenuStyle(
                              backgroundColor: WidgetStateProperty.all(cardColor),
                              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                              side: WidgetStateProperty.all(
                                BorderSide(color: borderColor, width: 1),
                              ),
                            ),
                            onSelected: (String? value) async {
                                setState(() {
                                  isLoadingTask = true;
                                  isEditingType = false;
                                });
                                await _updateType(value);
                            },
                            dropdownMenuEntries: taskType.entries.map((entry) {
                            return DropdownMenuEntry<String>(
                              value: entry.key,
                              label: entry.value,
                              style: MenuItemButton.styleFrom(
                                foregroundColor: textColor,
                                backgroundColor: cardColor,
                              ),
                            );
                          }).toList(),
                          ),
                        },
                        SizedBox(height: 5),
                        Divider(color: dividerColor, thickness: 1),
                        SizedBox(height: 5),
                        Text(
                          Translations.get('task_details_page10', currentLang),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 5),
                        if (!isEditingStatus)...{
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task!['status']),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Text(
                                  _translateStatus(task!['status']),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                             if (isTaskAssignen && userData!['id'] == task?['assignee']['id'] && task!['type'] != 'USER_STORY')
                              IconButton(
                                icon: Icon(Icons.edit, color: iconColor, size: 16),
                                onPressed: (){
                                  setState(() {
                                    isEditingStatus = true;
                                  });
                                }
                              ),
                            ]
                          ),
                        }
                        else...{
                          DropdownMenu<String>(
                            initialSelection: task!['status'],
                            width: MediaQuery.of(context).size.width,
                            textStyle: TextStyle(color: textColor, fontSize: 14),
                            inputDecorationTheme: InputDecorationTheme(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            menuStyle: MenuStyle(
                              backgroundColor: WidgetStateProperty.all(cardColor),
                              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                              side: WidgetStateProperty.all(
                                BorderSide(color: borderColor, width: 1),
                              ),
                            ),
                            onSelected: (String? value) async {
                              if (value == null || value == task!['status']) {
                                setState(() { isEditingStatus = false; });
                                return;
                              }

                              final reason = _canEditStatusReason(value);
                              if (reason != null) {
                                setState(() { isEditingStatus = false; });
                                _showCannotEditSnackBar(reason);
                                return;
                              }

                              setState(() {
                                isLoadingTask = true;
                                isEditingStatus = false;
                              });
                              await _updateStatus(value);
                            },
                            dropdownMenuEntries: const [
                              DropdownMenuEntry(value: 'BACKLOG',    label: 'Backlog'),
                              DropdownMenuEntry(value: 'TODO',       label: 'Prioritzada'),
                              DropdownMenuEntry(value: 'INPROGRESS', label: 'En Progrés'),
                              DropdownMenuEntry(value: 'VERIFY',     label: 'En Verificació'),
                              DropdownMenuEntry(value: 'DONE',       label: 'Finalitzada'),
                            ],
                          ),
                        },
                        SizedBox(height: 5),
                        Divider(color: dividerColor, thickness: 1),
                        SizedBox(height: 5),
                        Text(
                          Translations.get('task_details_page11', currentLang),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 5),           
                        TextButton(
                            onPressed: () async{
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailsPage(project: task!['project']!)
                                ),
                              );
                              setState((){
                                isLoadingTask = true;
                                isLoadingComment = true;
                                isLoadingPullRequests = true;
                              });
                              _loadTask();
                              _loadCommentData();
                              _loadAllPullRequestData();
                            },                           
                            child: Text(
                              task!['project']['name'],
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        SizedBox(height: 5),
                        if(task?['parentTaskId'] != null)...{
                          Divider(color: dividerColor, thickness: 1),
                          SizedBox(height: 5),
                          Text(
                            Translations.get('task_details_page12', currentLang),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 5),
                          TextButton(
                            onPressed: () async{
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskDetailsPage(task: parentTaskData!)
                                ),
                              );
                              setState((){
                                isLoadingTask = true;
                                isLoadingComment = true;
                                isLoadingPullRequests = true;
                              });
                              _loadTask();
                              _loadCommentData();
                              _loadAllPullRequestData();
                            },                           
                            child: Text(
                              parentTaskData?['name'],
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 16,
                              ),
                            )
                          ),
                          SizedBox(height: 5),
                        },
                        Divider(color: dividerColor, thickness: 1),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              Translations.get('task_details_page13', currentLang),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                              ),
                            ),
                            const Spacer(),
                            if (isTaskAssignen && userData!['id'] == task?['assignee']['id'])...{
                              IconButton(
                                icon: Icon(Icons.edit, color: iconColor, size: 16),
                                onPressed: () {
                                  setState(() {
                                    isEditingSprint = true;
                                  });
                                },
                              )
                            }
                          ],
                        ),
                        if(isEditingSprint)
                          DropdownMenu<int>(
                            initialSelection: _selectedSprintId,
                            width: MediaQuery.of(context).size.width,
                            textStyle: TextStyle(color: textColor, fontSize: 14),
                            inputDecorationTheme: InputDecorationTheme(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            menuStyle: MenuStyle(
                              backgroundColor: WidgetStateProperty.all(cardColor),
                              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                              side: WidgetStateProperty.all(
                                BorderSide(color: borderColor, width: 1),
                              ),
                            ),
                            onSelected: (int? value) async {
                              if (value == null || value == _selectedSprintId) {
                                setState(() { isEditingSprint = false; });
                                return;
                              }

                              final reason = _canEditSprintReason(value);
                              if (reason != null) {
                                setState(() { isEditingSprint = false; });
                                _showCannotEditSnackBar(reason);
                                return;
                              }

                              setState(() {
                                isLoadingSprint = true;
                                isLoadingTask = true;
                                _selectedSprintId = value;
                                isEditingSprint = false;
                              });
                              await _updateSprint(value);
                            },
                            dropdownMenuEntries: listSprints.map((sprint) {
                              return DropdownMenuEntry<int>(
                                value: sprint['id'], 
                                label: sprint['name'],
                                style: MenuItemButton.styleFrom(
                                  foregroundColor: textColor,
                                  backgroundColor: cardColor,
                                )
                              );
                            }).toList(),
                          ),
                        if(task?['activeSprints'].isEmpty)...{
                          Text(
                            'Backlog',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                        }
                        else...{
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: task?['activeSprints'].length,
                            itemBuilder: (context, index) {
                              final sprint = task?['activeSprints'][index];
                              return InkWell(
                                onTap: () async{
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SprintDetailsPage(sprint: sprint)
                                    ),
                                  );
                                  setState((){
                                    isLoadingTask = true;
                                    isLoadingComment = true;
                                    isLoadingPullRequests = true;
                                  });
                                  _loadTask();
                                  _loadCommentData();
                                  _loadAllPullRequestData();
                                },
                                child: Text(
                                  sprint['name'],
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 12,
                                  ),
                                )
                              );
                            }
                          )
                        }
                      ],
                    )
                  ),
                ]  
              ),
            ),
            


            // 3. Subtasques
            SizedBox(height: 10),
            if (task!['type'] == 'USER_STORY')...{
              Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Icon(Icons.description, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "${Translations.get('task_details_page16', currentLang)}(${task?['childTasks'].length})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: ()async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddSubtaskPage(task: task),
                                  ),
                                );
                                setState((){
                                  isLoadingTask = true; 
                                });
                                _loadTask();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: backgroundColor,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                Translations.get('task_details_page18', currentLang), 
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            if(_isUnassignedSubtasks())
                              ElevatedButton(
                                onPressed: () {
                                  _assignAllUnassignedSubtasks();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: backgroundColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  Translations.get('task_details_page19', currentLang), 
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                          ]
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task?['childTasks'].length > 0)...{
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: task?['childTasks'].length,
                            itemBuilder: (context, index) {
                              final tas = task?['childTasks'][index];
                              return InkWell(
                                onTap: () async{
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskDetailsPage(task: tas),
                                    ),
                                  );
                                  setState((){
                                    isLoadingTask = true; 
                                  });
                                  _loadTask();
                                  },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(tas!['status']),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: borderColor),
                                        ),
                                        child: Icon(
                                          _getStatusIcon(tas!['status']),
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  tas!['taskKey'],
                                                  style: TextStyle(
                                                    color: subtitleColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  tas!['name'],
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 14,
                                                  ),
                                                ),                                              
                                              ]
                                            ),                                        
                                            Row(
                                              children: [
                                                if(tas?['assignee'] == null)...{
                                                  Text(
                                                    Translations.get('task_details_page3', currentLang),
                                                    style: TextStyle(
                                                      color: subtitleColor,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                }
                                                else...{
                                                  Text(
                                                    tas!['assignee']['fullName'],
                                                    style: TextStyle(
                                                      color: subtitleColor,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                },
                                                if(tas!['estimationPoints'] != 0)...{
                                                  Text(
                                                    ' • ',
                                                    style: TextStyle(
                                                      color: subtitleColor,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${tas!['estimationPoints']} ${Translations.get('task_details_page8', currentLang)}',
                                                    style: TextStyle(
                                                      color: subtitleColor,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                }                                        
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(tas!['status']),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: borderColor),
                                            ),
                                            child: Text(
                                              _translateStatus(tas!['status']),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 7,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _getTaskBackgroundColor(tas!['type']),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: _getTaskColor(tas!['type'])),
                                            ),
                                            child: Text(
                                              _translateType(tas!['type']),
                                              style: TextStyle(
                                                color: _getTaskColor(tas!['type']),
                                                fontSize: 7,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ]
                                      )                                                                                                                        
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        }
                        else...{
                          Text(
                            Translations.get('task_details_page17', currentLang),
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        }
                      ]
                    )
                  ),
                ],
              ),
            ),
            },
            

            // 4. Pull Requests
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      Translations.get('task_details_page20', currentLang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task!['pullRequests'].length > 0)...{
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: task!['pullRequests'].length,
                            itemBuilder: (context, index) {
                              final pr = task!['pullRequests'][index];
                              final List<dynamic> history = pullRequestData[pr['id']] ?? [];

                              final sortedHistory = List<dynamic>.from(history)
                                ..sort((a, b) => DateTime.parse(a['changedAt']).compareTo(DateTime.parse(b['changedAt'])));

                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                pr['merged'] ? Icons.merge_type: Icons.call_split,
                                                color: pr['merged'] ? Colors.purpleAccent : Colors.green,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  pr['title'],
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: pr['merged'] ? const Color(0xFF3B1F6E) : const Color(0xFF1A4D2E),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: pr['merged'] ? Colors.purpleAccent : Colors.green,
                                                  ),
                                                ),
                                                child: Text(
                                                  pr['merged'] ? 'task_details_page49' : 'task_details_page50',
                                                  style: TextStyle(
                                                    color: pr['merged'] ? Colors.purpleAccent : Colors.green,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${pr['repoFullName']} #${pr['prNumber']} ${Translations.get('task_details_page53', currentLang)} ${pr['author']['fullName']}',
                                            style: TextStyle(
                                              color: subtitleColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),                                           
                                        ] 
                                      ),
                                    ),

                                    Divider(color: borderColor, height: 1, thickness: 1),

                                    if (sortedHistory.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.history, color: subtitleColor, size: 14),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${Translations.get('task_details_page54', currentLang)} (${sortedHistory.length})',
                                                  style: TextStyle(color: subtitleColor, fontSize: 12, fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: sortedHistory.length,
                                              itemBuilder: (context, hIndex) {
                                                final item = sortedHistory[hIndex];
                                                final bool isMerged = item['type'] == 'pr_merged';

                                                return IntrinsicHeight(
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      SizedBox(
                                                        width: 24,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              width: 24,
                                                              height: 24,
                                                              decoration: BoxDecoration(
                                                                color: isMerged ? const Color(0xFF3B1F6E) : const Color(0xFF1A4D2E),
                                                                shape: BoxShape.circle,
                                                                border: Border.all(
                                                                  color: isMerged ? Colors.purpleAccent : Colors.green,
                                                                  width: 1.5,
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                isMerged ? Icons.merge_type : Icons.call_split,
                                                                size: 13,
                                                                color: isMerged ? Colors.purpleAccent : Colors.green,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(bottom: 14),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    '${item['authorFullName']} ',
                                                                    style: TextStyle(
                                                                      color: textColor,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 10,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    isMerged ? Translations.get('task_details_page51', currentLang) : Translations.get('va obrir ', currentLang),
                                                                    style: TextStyle(
                                                                      color: subtitleColor,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 10,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '#${pr['prNumber']} ${pr['title']}',
                                                                    style: TextStyle(
                                                                      color: subtitleColor,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 10,
                                                                    ),
                                                                  ),                                                                  
                                                                ],
                                                              ),
                                                              Text(
                                                                item['changedAt'],
                                                                style: TextStyle(
                                                                  color: subtitleColor,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 10,
                                                                ),
                                                              ),     
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        }
                        else...{
                          Text(
                            Translations.get('task_details_page21', currentLang),
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          Text(
                            Translations.get('task_details_page22', currentLang),
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        }
                      ],
                    ),
                  ),
                ],
              ),
            ),
            


            // 5. Discussió
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Icon(Icons.description, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${Translations.get('task_details_page23', currentLang)}(${commentsTask.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isEditingNewComment = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: backgroundColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            Translations.get('task_details_page24', currentLang), 
                            style: TextStyle(color: textColor),
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
                        if (isEditingNewComment)...{
                          Column(
                            children: [
                              TextField(
                                controller: _newCommentController,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText: Translations.get('task_details_page29', currentLang),
                                  hintStyle: TextStyle(color: hintColor),
                                  filled: true,
                                  fillColor: inputFillColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF2D5AF0), width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          isEditingNewComment= false;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: BorderSide(color: borderColor),
                                      ),
                                      child: Text(
                                        Translations.get('task_details_page28', currentLang), 
                                        style: TextStyle(color: textColor)
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _addComment();
                                        setState(() {
                                          isLoadingComment = true;
                                        }); 
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2D5AF0),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: Text(
                                        Translations.get('task_details_page26', currentLang), 
                                        style: const TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        },
                        if(commentsTask.length > 0)
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: commentsTask.length,
                            itemBuilder: (context, index) {
                              final comment = commentsTask[index];
                              final isEditing = _editingComments[comment['id']] ?? false;
                              
                              if (!_commentControllers.containsKey(comment['id'])) {
                                _commentControllers[comment['id']] = TextEditingController(text: comment['content']);
                              }
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: hexToColor(comment['author']['color']),
                                            child: Text(
                                              comment['author']['capitalLetters'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comment['author']['fullName'],
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                comment['createdAt'],
                                                style: TextStyle(
                                                  color: subtitleColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          if (comment['author']['id'] == userData!['id'] && !isEditing)
                                            IconButton(
                                              icon: Icon(Icons.edit, color: iconColor, size: 16),
                                              onPressed: () {
                                                setState(() {
                                                  _editingComments[comment['id']] = true;
                                                  _commentControllers[comment['id']]!.text = comment['content'];
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                      if (!isEditing)...{
                                        Row(
                                          children: [
                                            const SizedBox(width: 32),
                                            Text(
                                              comment['content'],
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 14,
                                                height: 1.5,
                                              ),
                                            )
                                          ],
                                        )
                                      }
                                      else
                                        Column(
                                          children: [
                                            TextField(
                                              controller: _commentControllers[comment['id']],
                                              maxLines: 3,
                                              style: TextStyle(color: textColor),
                                              decoration: InputDecoration(
                                                hintText: Translations.get('task_details_page29', currentLang),
                                                hintStyle: TextStyle(color: hintColor),
                                                filled: true,
                                                fillColor: inputFillColor,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: borderColor),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: const BorderSide(color: Color(0xFF2D5AF0), width: 2),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: borderColor),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _editingComments[comment['id']] = false;
                                                        _commentControllers[comment['id']]!.text = comment['content'];
                                                      });
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                      side: BorderSide(color: borderColor),
                                                    ),
                                                    child: Text(
                                                      Translations.get('task_details_page28', currentLang),
                                                      style: TextStyle(color: textColor),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      _updateComment(comment['id'], _commentControllers[comment['id']]!.text);
                                                      setState(() {
                                                        isLoadingComment = true;
                                                      }); 
                                                      
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF2D5AF0),
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                    ),
                                                    child: Text(
                                                      Translations.get('task_details_page27', currentLang),
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          Text(
                            Translations.get('task_details_page25', currentLang),
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            
            SizedBox(height: 70),

          ],
        ),
      ),
    );
  }
}