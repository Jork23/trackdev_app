import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import 'add_subtask_page.dart';
import 'sprint_details_page.dart';
import 'project_details_page.dart';
import '../../utils/ui_helpers.dart';


class TaskDetailsPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> with ThemePage{

  static const _storage = FlutterSecureStorage();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newCommentController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final Map<int, TextEditingController> _commentControllers = {};
  
  bool _isEditingDescription = false;
  bool _isEditingName = false;
  bool _isEditingSprint = false;
  bool _isEditingNewComment = false;
  bool _isEditingPoints = false;
  bool _isEditingStatus = false;
  bool _isEditingType = false;
  bool _isDeletingTask = false;
  final Map<int, bool> _editingComments = {};

  late bool _isTaskAssignen;

  int? _selectedSprintId;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _commentData;
  final Map<String, List<dynamic>> _pullRequestData = {};
  Map<String, dynamic>? _taskData;
  Map<String, dynamic>? _parentTaskData;

  bool _isLoadingUser = true;
  bool _isLoadingTask = true;
  bool _isLoadingComment = true;
  bool _isLoadingSprint = false;
  bool _isLoadingPullRequests = true;
  bool _isLoadingParentTask = true;

  final Map<String, String> _taskType = {
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
      _isLoadingParentTask = false;
    }
    _isTaskAssignen = widget.task['assignee'] != null;
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
      'deleteErrorFinishedTask': 'No es pot eliminar una tasca que ja està finalitzada.',
      'deleteErrorHasSubtasks': 'No es pot eliminar una tasca que conté sub-tasques vinculades.',
      'modifyPointsStatusError': 'Només pots modificar els punts quan la tasca és a VERIFY o DONE.',
      'changeTypeUserStoryError': 'No es pot canviar el tipus d\'una Història d\'Usuari.',
      'changeTypeBugError': 'No es pot canviar el tipus d\'un Error.',
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
      'deleteErrorFinishedTask': 'No se puede eliminar una tarea que ya está finalizada.',
      'deleteErrorHasSubtasks': 'No se puede eliminar una tarea que contiene sub-tareas vinculadas.',
      'modifyPointsStatusError': 'Solo puedes modificar los puntos cuando la tarea está en VERIFY o DONE.',
      'changeTypeUserStoryError': 'No se puede cambiar el tipo de una Historia de Usuario.',
      'changeTypeBugError': 'No se puede cambiar el tipo de un Error.',
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
      'deleteErrorFinishedTask': 'Cannot delete a task that is already finished.',
      'deleteErrorHasSubtasks': 'Cannot delete a task that contains linked sub-tasks.',
      'modifyPointsStatusError': 'You can only modify points when the task is in VERIFY or DONE.',
      'changeTypeUserStoryError': 'Cannot change the type of a User Story.',
      'changeTypeBugError': 'Cannot change the type of a Bug.',
    }
  };


  String? _canDeleteTaskReason() {

    if (_taskData!['status'] == 'DONE') {
      return _getMsg('deleteErrorFinishedTask');
    }

    if (_taskData!['childTasks'].length != 0) {
      return _getMsg('deleteErrorHasSubtasks');
    }

    return null;
  }

  String? _canEditPointsReason() {
    if(_taskData!['status'] != 'VERIFY' && _taskData!['status'] != 'DONE') {
      return _getMsg('modifyPointsStatusError');
    }
    return null;
  }

  String? _canEditTypeReason() {
    if (_taskData!['type'] == 'USER_STORY') {
      return _getMsg('changeTypeUserStoryError');
    }
    if (_taskData!['type'] == 'BUG') {
      return _getMsg('changeTypeBugError');
    }
    return null;
  }

  String _getMsg(String key) {
    return _localTranslations[currentLang]?[key] ?? key;
  }

  String? _canEditStatusReason(String newStatus) {
    final current = _taskData!['status'];
    final hasPullRequests = _taskData!['pullRequests'] != null && _taskData!['pullRequests'].isNotEmpty;

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

  String? _canEditSprintReason(int? newSprintId) {

    final bool goingToBacklog = newSprintId == -1;
    final currentSprints = _taskData!['activeSprints'] as List;
    final bool currentlyInBacklog = currentSprints.isEmpty;
    final projectSprints = _taskData!['project']['sprints'] as List;

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

    if( _taskData!['type'] == 'USER_STORY'){
      if(!_isAllSubstasksInBackLog()){
        return _getMsg('changeSprintUserStoryNeedsBacklog');
      }
      return null;
    }

    if(_taskData!['parentTaskId'] != null){
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

  bool _isLoading(){
    return _isLoadingUser || _isLoadingTask || _isLoadingComment || _isLoadingSprint || _isLoadingPullRequests || _isLoadingParentTask;
  }

  bool _isAllSubstasksInBackLog(){

    final subtasks = _taskData?['childTasks'] as List?;

    if (subtasks == null || subtasks.isEmpty) return true;

    for (var sub in subtasks) {
      if (sub['status'] != 'BACKLOG') {
        return false;
      }
    }

    return true;

  }

  bool _isUnassignedSubtasks(){

    final subtasks = _taskData?['childTasks'] as List?;

    if (subtasks == null || subtasks.isEmpty) return false;

    for (var sub in subtasks) {
      if (sub['assignee'] == null) {
        return true;
      }
    }

    return false;
  }

  Future<void> _assignAllUnassignedSubtasks() async {
    final subtasks = _taskData?['childTasks'] as List?;

    if (subtasks == null || subtasks.isEmpty) return;

    for (var sub in subtasks) {
      if (sub['assignee'] == null) {
        await _assignSubtask(sub['id']);
      }
    }

    if (!mounted) return;

    setState(() {
      _isLoadingTask=true;
      _loadTask(); 
    });

  }

  Future<void> _assignSubtask(int subtaskId) async{

    String? token = await _storage.read(key: 'auth_token');

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

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}/assign');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _loadTask();
          _isTaskAssignen = true;
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
  }

  Future<void> _unassignTask() async{

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}/assign');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _loadTask();
          _isTaskAssignen = false;
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
  }

  Future<void> _updateComment(int commentId, String content) async {
    String? token = await _storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}/comments/$commentId');
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
        _isLoadingComment = false;
      }
    } 
    catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _editingComments[commentId] = false;
      });
    }
  }

  Future<void> _addComment() async{

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}/comments');
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
        _isLoadingComment = false;
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isEditingNewComment = false;
      });
    }
  }
  
  Future<void> _loadCommentData() async{

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}/comments');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _commentData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingComment = false;
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

  Future<void> _loadAllPullRequestData() async {

    String? token = await _storage.read(key: 'auth_token');

    try {
      if (widget.task['pullRequests'] != null) {
        for (var pr in widget.task['pullRequests']) {
          final url = Uri.parse('https://trackdev.org/api/pull-requests/${pr['id']}/history');

          final response = await http.get(
            url,
            headers: {'Authorization': 'Bearer $token'},
          );

          if (!mounted) return;

          if(response.statusCode == 200){
            setState(() {
              _pullRequestData[pr['id']] = jsonDecode(response.body)['history'];
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
        _isLoadingPullRequests = false;
      });
    }
  }

  Future<void> _loadTask() async {

    String? token = await _storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode ==  200 || response.statusCode == 204) {
        setState(() {
          _taskData = jsonDecode(response.body);
          _isLoadingTask=false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingTask=false;
      });
    }

  }

  Future<void> _loadParentTask() async {

    String? token = await _storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['parentTaskId']}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode ==  200 || response.statusCode == 204) {
        setState(() {
          _parentTaskData = jsonDecode(response.body);
        });
      }
    } 
    catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingParentTask=false;
      });
    }

  }

  Future<void> _updateSprint(int? sprintId) async {
    String? token = await _storage.read(key: 'auth_token');

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

        if (!mounted) return;

        if (response.statusCode == 200  || response.statusCode == 204) {
          setState(() {
            _loadTask();
          });
        }
      } 
      catch (e) {
        debugPrint("Error: $e");
      }
      finally{
        setState((){
          _isLoadingSprint = false;
        });
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

        if (!mounted) return;

        if (response.statusCode == 200  || response.statusCode == 204) {
          setState(() {
            _isLoadingTask = true;
            _loadTask();
          });
        }
      } 
      catch (e) {
        debugPrint("Error: $e");
      }
      finally{
        setState((){
          _isLoadingSprint = false;
        });
      }
    }
  }

  Future<void> _updateDescription() async {
    String? token = await _storage.read(key: 'auth_token');
    
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

      if (!mounted) return;

      if (response.statusCode == 200  || response.statusCode == 204) {
        setState(() {
          _loadTask();
        });
      }
    } 
    catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isEditingDescription = false;
      });
    }
  }

  Future<void> _updateStatus(String? newStatus) async {
    String? token = await _storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${_taskData!['id']}');
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

      if (!mounted) return;

      if (response.statusCode == 200  || response.statusCode == 204) {
        setState(() {
          _loadTask();
        });
      }
    } 
    catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isEditingStatus = false;
      });
    }
  }

  Future<void> _updateType(String? newType) async {
    String? token = await _storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${_taskData!['id']}');
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

      if (!mounted) return;

      if (response.statusCode == 200  || response.statusCode == 204) {
        setState(() {
          _loadTask();
        });
      }
    } 
    catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isEditingType = false;
      });
    }
  }

  Future<void> _updateName() async {
    String? token = await _storage.read(key: 'auth_token');
    
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

      if (!mounted) return;

      if (response.statusCode == 200  || response.statusCode == 204) {
        setState(() {
          _loadTask();
        });
      }
    } 
    catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isEditingName = false;
      });
    }
  }

  Future<void> _updatePoints() async {
    String? token = await _storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${_taskData!['id']}');
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

      if (!mounted) return;

      if (response.statusCode == 200  || response.statusCode == 204) {
        setState(() {
          _loadTask();
        });
      }
    } 
    catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isEditingPoints = false;
      });
    }
  }

  Future<void> _deleteTask() async {
    String? token = await _storage.read(key: 'auth_token');
    
    final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task['id']}');
    try {
      await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

    } 
    catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingTask=false;
      });
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

  Color _getStatusTextColor(String status) {
  switch (status) {
    case "BACKLOG":
      return const Color(0xFF450A0A);
    case "TODO":
      return const Color(0xFF78350F);
    case "INPROGRESS":
      return const Color(0xFF172554);
    case "VERIFY":
      return const Color(0xFF2E1065);
    case "DONE":
      return const Color(0xFF064E3B);
    default:
      return const Color.fromARGB(255, 219, 236, 254);
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

    final projectSprints = _taskData?['project']['sprints'] ?? [];
    final commentsTask = _commentData?['comments'] ?? [];

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
        title: _buildTaskAppBar()
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isDeletingTask)
              _buildTaskDelete(),
            _buildTaskInfo(),
            _buildTaskInfoCreatAt(),
            SizedBox(height: 10),
            _buildTaskDescription(),
            SizedBox(height: 10),
            _buildTaskDetails(listSprints),
            SizedBox(height: 10),
            if (_taskData?['type'] == 'USER_STORY')...{
              _buildTaskSubtask()
            },
            SizedBox(height: 10),
            _buildTaskPullRequests(),
            SizedBox(height: 10),
            _buildTaskDiscussion(commentsTask),          
            SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskAppBar(){
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
        if (_userData!['id'] != _taskData?['assignee']?['id']) ...{
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
        },
        if (_isTaskAssignen && _userData!['id'] == _taskData?['assignee']?['id']) ...{
          const Spacer(),
          Column(
            children: [
              if (!_isDeletingTask)
                TextButton(
                  onPressed: () {
                    final String? reason  = _canDeleteTaskReason();
                    if (reason  != null) {
                      setState(() { 
                        _isDeletingTask = false; 
                      });
                      _showCannotEditSnackBar(reason);
                      return;
                    }
                    setState(() {
                      _isDeletingTask = true;
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
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                          Translations.get('tasks.deleteTask', currentLang),
                        style: TextStyle(
                          color: const Color(0xFFFF5252), 
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ]
          )
        }
      ],
    );
  }

  Widget _buildTaskDelete(){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isDeletingTask = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: borderColor),
                ),
                child: Text(
                  Translations.get('common.cancel', currentLang),
                  style: TextStyle(color: textColor),
                ),
              ),
            ),                      
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoadingTask = true;
                  });
                  await _deleteTask();
                  if (!mounted) return;
                  Navigator.pop;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 240, 45, 45),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  Translations.get('common.edit', currentLang),
                  style: const TextStyle(
                    color: Colors.white, 
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfo(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: dividerColor, thickness: 1),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(_taskData?['status'] != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(_taskData?['status']),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Icon(
                  _getStatusIcon(_taskData?['status']),
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
                      if(_taskData?['type'] != null)...{
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: UIHelpers.getTaskBackgroundColor(_taskData?['type']),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: UIHelpers.getTaskColor(_taskData?['type'])),
                          ),
                          child: Text(
                            UIHelpers.translateType(_taskData?['type'], currentLang),
                            style: TextStyle(
                              color: UIHelpers.getTaskColor(_taskData?['type']),
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      },
                      if(_taskData?['status'] != null)...{
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_taskData?['status']),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getStatusTextColor(_taskData?['status'])),
                          ),
                          child: Text(
                            UIHelpers.translateStatus(_taskData?['status'], currentLang),
                            style: TextStyle(
                              color: _getStatusTextColor(_taskData?['status']),
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      },
                      if(_taskData?['estimationPoints'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF34D399)),
                          ),
                          child: Text(
                            '${_taskData?['estimationPoints']} ${Translations.get('tasks.points', currentLang)}',
                            style: TextStyle(
                              color: const Color(0xFF34D399),
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if(!_isEditingName)
                    _buildTaskInfoEditingName()
                  else
                    _buildTaskInfoNoEditingName()
                ],
              ),
            ),
          ],
        ),
        Divider(color: dividerColor, thickness: 1),
      ]
    );
  }

  Widget _buildTaskInfoEditingName(){
    return Row(
      children: [
        if(_taskData?['taskKey'] != null)...{
          Text(
            _taskData?['taskKey'],
            style: TextStyle(
              color: subtitleColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 8),
        },
        Expanded (
          child: Text(
            _taskData?['name'],
            style: TextStyle(
              color: textColor,
              fontSize: 20,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!_isEditingName && _isTaskAssignen)...{
          if(_userData?['id'] == _taskData?['assignee']?['id'] && _taskData?['name'] != null)...{
            SizedBox(
              width: 15, 
              height: 15,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.edit, color: iconColor, size: 15),
                onPressed: () {
                  setState(() {
                    _isEditingName = true;
                    _nameController.text = _taskData?['name'];
                  });
                },
              )
            )
          }
        }
      ]
    );
  }

  Widget _buildTaskInfoNoEditingName(){
    return Column(
      children: [
        const SizedBox(height: 5,),
        TextField(
          controller: _nameController,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            hintText: Translations.get('tasks.taskNamePlaceholder', currentLang),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditingName = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: borderColor),
                ),
                child: Text(
                  Translations.get('common.cancel', currentLang), 
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
                    _isLoadingTask = true;
                  });    
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5AF0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  Translations.get('common.edit', currentLang), 
                  style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTaskInfoCreatAt(){
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            if(_taskData?['createdAt'] != null)...{
              Icon(
                Icons.calendar_today_outlined,
                color: iconColor,
                size: 15,
              ),
              Text(
                ' ${Translations.get('tasks.createdAt', currentLang)} ${UIHelpers.formatDate(_taskData?['createdAt'])}',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                ),
              ),
            }
          ]
        ),
        Row(
          children: [
            if(_taskData?['reporter']?['fullName'] != null)...{
              Icon(
                Icons.group_outlined,
                color: iconColor,
                size: 15,
              ),
              Expanded(
                child: Text(
                  ' ${Translations.get('common.by', currentLang)} ${_taskData?['reporter']?['fullName']}',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            }
          ],
        ),
        const SizedBox(height: 24),
      ]
    );
  }

  Widget _buildTaskDescription(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskDescriptionTitle(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditingDescription)
                  _buildTaskDescriptionIsEditing()
                else
                  Text(
                    (_taskData?['description'] == null) ? Translations.get('tasks.noDescriptionProvided', currentLang) : _taskData?['description'],
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
    );
  }

  Widget _buildTaskDescriptionTitle(){
    return Container(
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
          const Icon(
            Icons.description,
            color: Colors.white,
            size: 20
          ),
          const SizedBox(width: 8),
          Text(
            Translations.get('attributes.description', currentLang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (!_isEditingDescription && _isTaskAssignen)...{
            if(_userData?['id'] == _taskData?['assignee']?['id'])...{
              SizedBox(
                width: 20, 
                height: 20,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: () {
                    setState(() {
                      _isEditingDescription = true;
                      _descriptionController.text = _taskData?['description'] ?? '';
                    });
                  },
                )
              )
            }
          }
        ],
      ),
    );
  }

  Widget _buildTaskDescriptionIsEditing(){
    return Column(
      children: [
        TextField(
          controller: _descriptionController,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            hintText: Translations.get('tasks.addDescription', currentLang),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditingDescription = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: borderColor),
                ),
                child: Text(
                  Translations.get('common.cancel', currentLang), 
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
                    _isLoadingTask = true;
                  });    
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5AF0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  Translations.get('common.edit', currentLang), 
                  style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTaskDetails(List<dynamic> listSprints){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskDetailsTitle(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskDetailsAssignee(),
                SizedBox(height: 5),
                Divider(color: dividerColor, thickness: 1),
                SizedBox(height: 5),
                _buildTaskDetailsReporter(),       
                SizedBox(height: 5),
                Divider(color: dividerColor, thickness: 1),
                SizedBox(height: 5),
                _buildTaskDetailsPoints(),         
                SizedBox(height: 5),
                Divider(color: dividerColor, thickness: 1),
                SizedBox(height: 5),
                _buildTaskDetailsType(),   
                SizedBox(height: 5),
                Divider(color: dividerColor, thickness: 1),
                SizedBox(height: 5),
                _buildTaskDetailsStatus(),  
                SizedBox(height: 5),
                Divider(color: dividerColor, thickness: 1),
                SizedBox(height: 5),
                _buildTaskDetailsProject(), 
                SizedBox(height: 5),
                Divider(color: dividerColor, thickness: 1),
                if(_taskData?['parentTaskId'] != null)...{
                  SizedBox(height: 5),
                  _buildTaskDetailsPrarent(),
                  SizedBox(height: 5),
                  Divider(color: dividerColor, thickness: 1),
                },
                SizedBox(height: 5),
                _buildTaskDetailsSprint(listSprints),
              ],
            )
          ),
        ]  
      ),
    );
  }

  Widget _buildTaskDetailsTitle(){
    return Container(
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
        Translations.get('tasks.details', currentLang),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),                     
    );
  }

  Widget _buildTaskDetailsAssignee(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Translations.get('tasks.assignee', currentLang),
          style: TextStyle(
            color: textColor,
            fontSize: 20,
          ),
        ),
        if(_isTaskAssignen)...{
          if(_userData?['id'] != _taskData?['assignee']?['id'])...{
            const SizedBox(height: 5),
          }
        },
        Row(
          children: [
            if(_isTaskAssignen && _taskData?['assignee']?['color'] != null && _taskData?['assignee']?['fullName'] != null)...{
              CircleAvatar(
                radius: 16,
                backgroundColor: UIHelpers.hexToColor(_taskData?['assignee']?['color']),
                child: Text(
                  _taskData?['assignee']?['capitalLetters'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _taskData?['assignee']?['fullName'],
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis
                ),
              )
            }
            else...{
              Expanded(
                child: Text(
                  Translations.get('tasks.unassigned', currentLang),
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                  ),
                ),
              )
            },
            if(_isTaskAssignen)...{
              if(_userData?['id'] == _taskData?['assignee']?['id'])...{
                TextButton(
                  onPressed: () {
                    _unassignTask();
                    setState(() {
                      _isLoadingTask = true;
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
                        Translations.get('tasks.unassignFromMe', currentLang),
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
                    _isLoadingTask = true;
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
                      Translations.get('tasks.assignToMe', currentLang),
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
        )
      ]
    );
  }

  Widget _buildTaskDetailsReporter(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Translations.get('tasks.reporter', currentLang),
          style: TextStyle(
            color: textColor,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 5),
        Row(
          children: [
            if(_taskData?['reporter']?['color'] != null && _taskData?['reporter']?['capitalLetters'] != null)
              CircleAvatar(
                radius: 16,
                backgroundColor: UIHelpers.hexToColor(_taskData?['reporter']?['color']),
                child: Text(
                  _taskData?['reporter']?['capitalLetters'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            if(_taskData?['reporter']?['fullName'] != null)...{
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _taskData?['reporter']?['fullName'],
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis
                ),
                )
            }
          ]
        ),
      ]
    );
  }

  Widget _buildTaskDetailsPoints(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            Translations.get('tasks.estimation', currentLang),
            style: TextStyle(
              color: textColor,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 5),
          if (_isEditingPoints)
            _buildTaskDetailsPointsEditing()
          else
            _buildTaskDetailsPointsNoEditing()
      ]
    );
  }

  Widget _buildTaskDetailsPointsEditing(){
    return Column(
      children: [
        TextField(
          controller: _pointsController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            hintText: _taskData?['estimationPoints']?.toString() ?? '0',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditingPoints = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: borderColor),
                ),
                child: Text(
                  Translations.get('common.cancel', currentLang),
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
                    _isLoadingTask = true;
                  });                                
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5AF0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  Translations.get('common.edit', currentLang),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskDetailsPointsNoEditing(){
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF34D399)),
          ),
          child: Text(
            _taskData?['estimationPoints'] != null ? '${_taskData?['estimationPoints']} ${Translations.get('tasks.points', currentLang)}' : '0 ${Translations.get('tasks.points', currentLang)}',
            style: TextStyle(
              color: const Color(0xFF34D399),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        if (_isTaskAssignen && _userData?['id'] == _taskData?['assignee']?['id'])
          SizedBox(
            width: 15, 
            height: 15,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.edit, color: iconColor, size: 15),
              onPressed: () {
                final reason = _canEditPointsReason();
                if (reason != null) {
                  _showCannotEditSnackBar(reason);
                  return;
                }
                setState(() {
                  _isEditingPoints = true;
                  _pointsController.text = _taskData?['estimationPoints'].toString() ?? "0";
                });
              },
            )
          )
      ]
    );
  }

  Widget _buildTaskDetailsType(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Translations.get('tasks.type', currentLang),
          style: TextStyle(
            color: textColor,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 5),
        if (!_isEditingType)
          _buildTaskDetailsTypeNoEditing()
        else
          _buildTaskDetailsTypeEditing()
      ]
    );
  }

  Widget _buildTaskDetailsTypeNoEditing(){
    return Row(
      children: [
        if(_taskData?['type'] != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: UIHelpers.getTaskBackgroundColor(_taskData?['type']),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: UIHelpers.getTaskColor(_taskData?['type'])),
            ),
            child: Text(
              UIHelpers.translateType(_taskData?['type'], currentLang),
              style: TextStyle(
                color: UIHelpers.getTaskColor(_taskData?['type']),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const Spacer(),
        if (_isTaskAssignen && _userData?['id'] == _taskData?['assignee']?['id'])
          SizedBox(
            width: 16, 
            height: 16,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.edit, color: iconColor, size: 16),
              onPressed: () {
                final reason = _canEditTypeReason();
                if (reason != null) {
                  _showCannotEditSnackBar(reason);
                  return;
                }
                setState(() {
                  _isEditingType = true;
                });
              },
            ),
          )
      ]
    );
  }

  Widget _buildTaskDetailsTypeEditing(){
    return DropdownMenu<String>(
      initialSelection: _taskData?['type'],
      width: MediaQuery.of(context).size.width - 72,
      textStyle: TextStyle(color: textColor, fontSize: 14),
      inputDecorationTheme: UIHelpers.customInputDecorationDropdownMenu(
        inputFillColor: inputFillColor,
        borderColor: borderColor,
        hintColor: hintColor,
      ),
      menuStyle: UIHelpers.customMenuStyle(
        cardColor: cardColor,
        borderColor: borderColor,
      ),
      onSelected: (String? value) async {
          setState(() {
            _isLoadingTask = true;
            _isEditingType = false;
          });
          await _updateType(value);
      },
      dropdownMenuEntries: _taskType.entries.map((entry) {
        return DropdownMenuEntry<String>(
          value: entry.key,
          label: entry.value,
          style: MenuItemButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: cardColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskDetailsStatus(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Translations.get('tasks.status', currentLang),
          style: TextStyle(
            color: textColor,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 5),
        if (!_isEditingStatus)
          _buildTaskDetailsStatusNoEditing()
        else
          _buildTaskDetailsStatusEditing()
      ]
    );
  }

  Widget _buildTaskDetailsStatusNoEditing(){
    return Row(
      children: [
        if(_taskData?['status'] != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(_taskData?['status']),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getStatusTextColor(_taskData?['status'])),
            ),
            child: Text(
              UIHelpers.translateStatus(_taskData?['status'], currentLang),
              style: TextStyle(
                color: _getStatusTextColor(_taskData?['status']),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const Spacer(),
        if (_isTaskAssignen && _userData?['id'] == _taskData?['assignee']?['id'] && _taskData!['type'] != 'USER_STORY')
          SizedBox(
            width: 16, 
            height: 16,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.edit, color: iconColor, size: 16),
              onPressed: (){
              setState(() {
                _isEditingStatus = true;
              });
            }
            ),
          )
      ]
    );
  }

  Widget _buildTaskDetailsStatusEditing(){
    return DropdownMenu<String>(
      initialSelection: _taskData?['status'],
      width: MediaQuery.of(context).size.width - 72,
      textStyle: TextStyle(color: textColor, fontSize: 14),
      inputDecorationTheme: UIHelpers.customInputDecorationDropdownMenu(
        inputFillColor: inputFillColor,
        borderColor: borderColor,
        hintColor: hintColor,
      ),
      menuStyle: UIHelpers.customMenuStyle(
        cardColor: cardColor,
        borderColor: borderColor,
      ),
      onSelected: (String? value) async {
        if (value == null || value == _taskData?['status']) {
          setState(() { 
            _isEditingStatus = false; 
          });
          return;
        }
        final reason = _canEditStatusReason(value);
        if (reason != null) {
          setState(() { 
            _isEditingStatus = false; 
          });
          _showCannotEditSnackBar(reason);
          return;
        }
        setState(() {
          _isLoadingTask = true;
          _isEditingStatus = false;
        });
        await _updateStatus(value);
      },
      dropdownMenuEntries: [
        DropdownMenuEntry(
          value: 'BACKLOG',
          label: UIHelpers.translateStatus('BACKLOG', currentLang),
          style: MenuItemButton.styleFrom(
            textStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            foregroundColor: Colors.white,
          ),
        ),
        DropdownMenuEntry(
          value: 'TODO',
          label: UIHelpers.translateStatus('TODO', currentLang),
          style: MenuItemButton.styleFrom(
            textStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            foregroundColor: Colors.white,
          ),
        ),
        DropdownMenuEntry(
          value: 'INPROGRESS',
          label: UIHelpers.translateStatus('INPROGRESS', currentLang),
          style: MenuItemButton.styleFrom(
            textStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            foregroundColor: Colors.white,
          ),
        ),
        DropdownMenuEntry(
          value: 'VERIFY',
          label: UIHelpers.translateStatus('VERIFY', currentLang),
          style: MenuItemButton.styleFrom(
            textStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            foregroundColor: Colors.white,
          ),
        ),
        DropdownMenuEntry(
          value: 'DONE',
          label: UIHelpers.translateStatus('DONE', currentLang),
          style: MenuItemButton.styleFrom(
            textStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            foregroundColor: Colors.white,
          ),
        ),
      ]
    );
  }

  Widget _buildTaskDetailsProject(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Translations.get('tasks.project', currentLang),
          style: TextStyle(
            color: textColor,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 5),           
        InkWell(
          onTap: () async{
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailsPage(project: _taskData?['project']!)
              ),
            );
            setState((){
              _isLoadingTask = true;
              _isLoadingComment = true;
              _isLoadingPullRequests = true;
            });
            _loadTask();
            _loadCommentData();
            _loadAllPullRequestData();
          },                         
          child: Text(
            _taskData?['project']?['name'],
            style: TextStyle(
              color: subtitleColor,
              fontSize: 16,
            ),
          ),
        ),
      ]
    );
  }

  Widget _buildTaskDetailsPrarent(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(_taskData?['parentTaskId'] != null)...{
          Text(
            Translations.get('tasks.parentTask', currentLang),
            style: TextStyle(
              color: textColor,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 5),
          InkWell(
            onTap: () async{
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailsPage(task: _parentTaskData!)
                ),
              );
              setState((){
                _isLoadingTask = true;
                _isLoadingComment = true;
                _isLoadingPullRequests = true;
              });
              _loadTask();
              _loadCommentData();
              _loadAllPullRequestData();
            },                           
            child: Text(
              _parentTaskData?['name'],
              style: TextStyle(
                color: subtitleColor,
                fontSize: 16,
              ),
            )
          ),
        },
      ]
    );
  }

  Widget _buildTaskDetailsSprint(List<dynamic> listSprints){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              Translations.get('tasks.sprint', currentLang),
              style: TextStyle(
                color: textColor,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            if (_isTaskAssignen && _userData!['id'] == _taskData?['assignee']['id'])...{
                SizedBox(
                  width: 16, 
                  height: 16,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.edit, color: iconColor, size: 16),
                    onPressed: () {
                      setState(() {
                        _isEditingSprint = true;
                      });
                    },
                  ),
                )
            }
          ],
        ),
        SizedBox(height: 5),
        if(_isEditingSprint)
          _buildTaskDetailsSprintEditing(listSprints),
        if(_taskData?['activeSprints'].isEmpty && !_isEditingSprint)...{
          Text(
            'Backlog',
            style: TextStyle(
              color: subtitleColor,
              fontSize: 16,
            ),
          ),
        }
        else if (!_isEditingSprint)
          _buildTaskDetailsSprintNoEditing()
      ]
    );
  }

  Widget _buildTaskDetailsSprintEditing(List<dynamic> listSprints){
    return DropdownMenu<int>(
      initialSelection: _selectedSprintId,
      width: MediaQuery.of(context).size.width - 72,
      textStyle: TextStyle(color: textColor, fontSize: 14),
      inputDecorationTheme: UIHelpers.customInputDecorationDropdownMenu(
        inputFillColor: inputFillColor,
        borderColor: borderColor,
        hintColor: hintColor,
      ),
      menuStyle: UIHelpers.customMenuStyle(
        cardColor: cardColor,
        borderColor: borderColor,
      ),
      onSelected: (int? value) async {
        if (value == null || value == _selectedSprintId) {
          setState(() { 
            _isEditingSprint = false; 
          });
          return;
        }

        final reason = _canEditSprintReason(value);
        if (reason != null) {
          setState(() { 
            _isEditingSprint = false; 
          });
          _showCannotEditSnackBar(reason);
          return;
        }

        setState(() {
          _isLoadingSprint = true;
          _isLoadingTask = true;
          _selectedSprintId = value;
          _isEditingSprint = false;
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
    );
  }

  Widget _buildTaskDetailsSprintNoEditing(){
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _taskData?['activeSprints'].length,
      itemBuilder: (context, index) {
        final sprint = _taskData?['activeSprints'][index];
        return InkWell(
          onTap: () async{
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SprintDetailsPage(sprint: sprint)
              ),
            );
            setState((){
              _isLoadingTask = true;
              _isLoadingComment = true;
              _isLoadingPullRequests = true;
            });
            _loadTask();
            _loadCommentData();
            _loadAllPullRequestData();
          },
          child: Text(
            sprint['name'],
            style: TextStyle(
              color: subtitleColor,
              fontSize: 16,
            ),
          )
        );
      }
    );
  }

  Widget _buildTaskSubtask(){        
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskSubtaskTitle(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_taskData?['childTasks'].length > 0)
                  _buildTaskSubtaskList()
                else
                  Text(
                    Translations.get('tasks.noSubtasks', currentLang),
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
              ]
            )
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSubtaskTitle(){
    return Container(
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
          const Icon(
            Icons.description,
            color: Colors.white,
            size: 20),
          const SizedBox(width: 8),
          Text(
            "${Translations.get('tasks.subtasks', currentLang)} (${_taskData?['childTasks'].length})",
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
                      builder: (context) => AddSubtaskPage(task: _taskData),
                    ),
                  );
                  setState((){
                    _isLoadingTask = true; 
                  });
                  _loadTask();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                ),
                child: Text(
                  Translations.get('tasks.addSubtask', currentLang), 
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
                    Translations.get('tasks.assignAllToMe', currentLang), 
                    style: TextStyle(color: textColor),
                  ),
                ),
            ]
          )
        ],
      ),
    );
  }

  Widget _buildTaskSubtaskList(){
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _taskData?['childTasks'].length,
      itemBuilder: (context, index) {
        final tas = _taskData?['childTasks'][index];
        return InkWell(
          onTap: () async{
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailsPage(task: tas),
              ),
            );
            setState((){
              _isLoadingTask = true; 
            });
            _loadTask();
            },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(tas?['status'] != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(tas?['status']),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(
                      _getStatusIcon(tas?['status']),
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                const SizedBox(width: 12),
                UIHelpers.costumTaskInfo(textColor: textColor, subtitleColor: subtitleColor, task: tas, currentLang: currentLang),                                                                                                                                                  
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskPullRequests(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskPullRequestsTitle(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_taskData!['pullRequests'].length > 0)...{
                  _buildTaskPullRequestsList(),
                }
                else...{
                  Text(
                    Translations.get('tasks.noPullRequestsLinked', currentLang),
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    Translations.get('tasks.mentionTaskKey', currentLang),
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                }
              ],
            ),
          )        
        ],
      ),
    );          
  }

  Widget _buildTaskPullRequestsTitle(){
    return Container(
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
        Translations.get('tasks.pullRequests', currentLang),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTaskPullRequestsList(){
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _taskData?['pullRequests'].length,
      itemBuilder: (context, index) {
        final pr = _taskData!['pullRequests'][index];
        final List<dynamic> history = _pullRequestData[pr?['id']] ?? [];

        final sortedHistory = List<dynamic>.from(history)
          ..sort((a, b) => DateTime.parse(a?['changedAt']).compareTo(DateTime.parse(b?['changedAt'])));

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 2),
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
                          pr?['merged'] ? Icons.merge_type: Icons.call_split,
                          color: pr?['merged'] ? Colors.purpleAccent : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        if(pr?['title'] != null)
                          Expanded(
                            child: Text(
                              pr?['title'],
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if(pr?['merged'] != null)...{
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: pr?['merged'] ? const Color(0xFF3B1F6E) : const Color(0xFF1A4D2E),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: pr?['merged'] ? Colors.purpleAccent : Colors.green,
                              ),
                            ),
                            child: Text(
                              pr?['merged'] ? Translations.get('analytics.merged', currentLang) : Translations.get('analytics.open', currentLang),
                              style: TextStyle(
                                color: pr?['merged'] ? Colors.purpleAccent : Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        }
                      ],
                    ),
                    if(pr?['repoFullName'] != null && pr?['prNumber'] != null && pr?['author']?['fullName'] != null)
                    const SizedBox(height: 6),
                    Text(
                      '${pr?['repoFullName']} #${pr?['prNumber']} ${Translations.get('common.by', currentLang)} ${pr?['author']?['fullName']}',
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
                _buildTaskPullRequestsListHistory(sortedHistory, pr)
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskPullRequestsListHistory(List<dynamic> sortedHistory, Map<String,dynamic> pr){
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 5, 24.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: subtitleColor,
                size: 14
              ),
              const SizedBox(width: 6),
              Text(
                '${Translations.get('tasks.activityTimeline', currentLang)} (${sortedHistory.length})',
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
              final bool isMerged = item?['type'] == 'pr_merged';

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
                                if(item?['authorFullName'] != null)
                                  Text(
                                    '${item?['authorFullName']} ',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),                                                                   
                                Expanded(
                                  child: Text(
                                    isMerged ? Translations.get('tasks.prEventMerged', currentLang) : Translations.get('tasks.prEventOpened', currentLang),
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),  
                                )                                               
                              ],
                            ),
                            if(pr['prNumber'] != null && pr['title'] != null)
                              Expanded(
                                child: Text(
                                  '#${pr['prNumber']} ${pr['title']}',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),    
                              ),         
                            if(item?['changedAt'] != null)
                              Text(
                                UIHelpers.formatDate(item?['changedAt']),
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildTaskDiscussion(List<dynamic> commentsTask){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskDiscussionTitle(commentsTask),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditingNewComment)...{
                  _buildTaskDiscussionEditing(),
                },
                if(commentsTask.isNotEmpty)
                  _buildTaskDiscussionList(commentsTask)
                else
                  Text(
                    Translations.get('tasks.noCommentsYet', currentLang),
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
    );
  }

  Widget _buildTaskDiscussionTitle(List<dynamic> commentsTask){
    return Container(
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
          const Icon(
            Icons.description,
            color: Colors.white,
            size: 20
          ),
          const SizedBox(width: 8),
          Text(
            '${Translations.get('tasks.discussion', currentLang)} (${commentsTask.length})',
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
                _isEditingNewComment = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
            ),
            child: Text(
              Translations.get('tasks.addComment', currentLang), 
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDiscussionEditing(){
    return Column(
      children: [
        TextField(
          controller: _newCommentController,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            hintText: Translations.get('tasks.writeComment', currentLang),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditingNewComment= false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: borderColor),
                ),
                child: Text(
                  Translations.get('common.cancel', currentLang), 
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
                    _isLoadingComment = true;
                  }); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5AF0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  Translations.get('tasks.postComment', currentLang), 
                  style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTaskDiscussionList(List<dynamic> commentsTask){
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: commentsTask.length,
      itemBuilder: (context, index) {
        final comment = commentsTask[index];
        final isEditing = _editingComments[comment?['id']] ?? false;
        
        if (!_commentControllers.containsKey(comment?['id'])) {
          _commentControllers[comment?['id']] = TextEditingController(text: comment?['content']);
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
                    if(comment?['author']?['color'] != null && comment?['author']?['capitalLetters'] != null)
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: UIHelpers.hexToColor(comment?['author']?['color']),
                        child: Text(
                          comment?['author']?['capitalLetters'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if(comment?['author']?['fullName'] != null && comment?['createdAt'] != null)...{
                      const SizedBox(width: 8),
                        Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [                                                
                              Text(
                                comment?['author']?['fullName'],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              UIHelpers.formatDate(comment?['createdAt']),
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    },
                    if (comment?['author']?['id'] == _userData?['id'] && !isEditing)
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
                  _buildTaskDiscussionListNoEditing(comment),
                }
                else
                  _buildTaskDiscussionListEditing(comment),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskDiscussionListNoEditing(Map<String,dynamic> comment){
    return Row(
      children: [
        const SizedBox(width: 32),
        if(comment['content'] != null)
          Expanded(
            child: Text(
              comment['content'],
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1.5,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          )
      ],
    );
  }

  Widget _buildTaskDiscussionListEditing(Map<String,dynamic> comment){
    return Column(
      children: [
        TextField(
          controller: _commentControllers[comment['id']],
          maxLines: 3,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            hintText: Translations.get('tasks.writeComment', currentLang),
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
                  Translations.get('common.cancel', currentLang),
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
                    _isLoadingComment = true;
                  }); 
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5AF0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  Translations.get('common.edit', currentLang),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}