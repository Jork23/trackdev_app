import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import 'add_task_page.dart';
import 'task_details_page.dart';


class TaskProjectPage extends StatefulWidget {
  final Map<String, dynamic> project;

  const TaskProjectPage({super.key, required this.project});

  @override
  State<TaskProjectPage> createState() => _TaskProjectPageState();
}

class _TaskProjectPageState extends State<TaskProjectPage> with ThemePage{

  static const _storage = FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;

  Map<String, dynamic> _taskData = {};

  String? _selectedType = "";
  String? _selectedStatus = "";
  String? _selectedAssignenId = "";
  int? _selectedSprintId;
  String? _selectedSortOrder = "desc";
  String _selectedSearch = "";

  int _page = 0;
  int _size = 10;

  int _totalElements = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadTask(widget.project['id'], _selectedSprintId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedType = "";
      _selectedStatus = "";
      _selectedAssignenId = "";
      _selectedSprintId = null;
      _selectedSortOrder = "desc";
      _selectedSearch = "";
      _searchController.clear();
      _page = 0;
      _isLoading = true;
    });
    _loadTask(widget.project['id'], null, "", "", "", "desc", "");
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
        return Translations.get('task_proj_page29', currentLang);
      case "TASK":
        return Translations.get('task_proj_page30', currentLang);
      case "USER_STORY":
        return Translations.get('task_proj_page31', currentLang);
      default:
        return type;
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case "BACKLOG":
        return "Backlog";
      case "TODO":
        return Translations.get('task_proj_page32', currentLang);
      case "INPROGRESS":
        return Translations.get('task_proj_page33', currentLang);
      case "VERIFY":
        return Translations.get('task_proj_page34', currentLang);
      case "DONE":
        return Translations.get('task_proj_page35', currentLang);
      default:
        return status;
    }
  }

  Color hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.pinkAccent.shade100;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> _loadTask(int? projectId, int? sprintId, String? assigneeId, String? status, String? type, String? sortOrder, String? search) async{

    String? token = await _storage.read(key: 'auth_token');

    final params ={
      'page': _page.toString(),
      'size': _size.toString(),
      'projectId': '$projectId',
      if(sprintId!=null) 'sprintId': '$sprintId',
      if(assigneeId !=null && assigneeId.isNotEmpty) 'assigneeId': assigneeId,
      if(status !=null && status.isNotEmpty) 'status': status,
      if(type !=null && type.isNotEmpty) 'type': type,
      if(sortOrder !=null && sortOrder.isNotEmpty) 'sortOrder': sortOrder,
      if(search !=null && search.isNotEmpty) 'search': search,
    };

    final url = Uri.https('trackdev.org', '/api/tasks/my', params);
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {     
        setState((){
          _taskData = jsonDecode(response.body);
          _totalElements = _taskData['totalElements'] ?? 0;
          _totalPages = _taskData['totalPages'] ?? 0;
        });
      }
    } 
    catch (e) {
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

    final List sprintsAux = widget.project['sprints'] ?? [];
    final List membersAux = widget.project['members'] ?? [];

    final List listTypes = [
        {'type': "", 'name': Translations.get('task_proj_page8', currentLang)},
        {'type': 'USER_STORY', 'name': Translations.get('task_proj_page31', currentLang)},
        {'type': 'TASK', 'name': Translations.get('task_proj_page30', currentLang)},
        {'type': 'BUG', 'name': Translations.get('task_proj_page29', currentLang)},
    ];

    final List listStatus = [
      {'status': "", 'name': Translations.get('task_proj_page9', currentLang)},
      {'status': 'BACKLOG', 'name': 'Backlog'},
      {'status': 'TODO', 'name': Translations.get('task_proj_page32', currentLang)},
      {'status': 'INPROGRESS', 'name': Translations.get('En task_proj_page33', currentLang)},
      {'status': 'VERIFY', 'name': Translations.get('task_proj_page34', currentLang)},
      {'status': 'DONE', 'name': Translations.get('task_proj_page35', currentLang)},
    ];

    final List listAssignees = [
      {'id': "", 'fullName': Translations.get('task_proj_page11', currentLang)},
      ...membersAux
    ];
    
    final List listSprints = [
      {'id': null, 'name': Translations.get('task_proj_page10', currentLang)},
      ...sprintsAux
    ];

    final List listSortOrder = [
      {'value': 'desc', 'name': Translations.get('task_proj_page12', currentLang)},
      {'value': 'asc', 'name': Translations.get('task_proj_page13', currentLang)},
    ];

    final List<int> pageSizeOptions = [5, 10, 20, 50];

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

    final tasks = _taskData['tasks'] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 50,
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
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: dividerColor, thickness: 1),
            Row(
              children: [
                Text(
                  Translations.get('task_proj_page15', currentLang),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async{
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTaskPage(project: widget.project,),
                      ),
                    );
                    setState((){
                      _isLoading = true; 
                    });
                    _loadTask(widget.project['id'], _selectedSprintId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2D5AF0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    Translations.get('task_proj_page16', currentLang), 
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Divider(color: dividerColor, thickness: 1),
            const SizedBox(height: 20),
            Container(
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5AF0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      )
                    ),         
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: subtitleColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Translations.get('task_proj_page17', currentLang),
                          style: TextStyle(
                            color: subtitleColor, 
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _resetFilters,
                          icon: Icon(
                            Icons.close,
                            color: subtitleColor,
                            size: 18,
                          ),
                          label: Text(
                            Translations.get('task_proj_page18', currentLang),
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DropdownMenu<String?>(
                          initialSelection: _selectedType,
                          width: MediaQuery.of(context).size.width - 72,
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
                              _selectedType = value;
                              _page = 0;
                              _isLoading = true;
                            });
                            _loadTask(widget.project['id'], _selectedSprintId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                          },
                          dropdownMenuEntries: listTypes.map((type) {
                            return DropdownMenuEntry<String?>(
                              value: type['type'], 
                              label: type['name'],
                              style: MenuItemButton.styleFrom(
                                foregroundColor: textColor,
                                backgroundColor: backgroundColor
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 8),
                        DropdownMenu<String?>(
                          initialSelection: _selectedStatus,
                          width: MediaQuery.of(context).size.width - 72,
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
                              _selectedStatus = value;
                              _page = 0;
                              _isLoading = true;
                            });
                            _loadTask(widget.project['id'], _selectedSprintId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                          },
                          dropdownMenuEntries: listStatus.map((stat) {
                            return DropdownMenuEntry<String?>(
                              value: stat['status'], 
                              label: stat['name'],
                              style: MenuItemButton.styleFrom(
                                foregroundColor: textColor,
                                backgroundColor: backgroundColor
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 8),
                        DropdownMenu<int?>(
                          initialSelection: _selectedSprintId,
                          width: MediaQuery.of(context).size.width - 72,
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
                            setState(() {
                              _selectedSprintId = value;
                              _page = 0;
                              _isLoading = true;
                            });
                            _loadTask(widget.project['id'], _selectedSprintId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                          },
                          dropdownMenuEntries: listSprints.map((spri) {
                            return DropdownMenuEntry<int?>(
                              value: spri['id'], 
                              label: spri['name'],
                              style: MenuItemButton.styleFrom(
                                foregroundColor: textColor,
                                backgroundColor: backgroundColor
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 8),
                        DropdownMenu<String?>(
                          initialSelection: _selectedAssignenId,
                          width: MediaQuery.of(context).size.width - 72,
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
                              _selectedAssignenId = value;
                              _page = 0;
                              _isLoading = true;
                            });
                              _loadTask(widget.project['id'], _selectedSprintId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                          },
                          dropdownMenuEntries: listAssignees.map((memb) {
                            return DropdownMenuEntry<String?>(
                              value: memb['id'], 
                              label: memb['fullName'],
                              style: MenuItemButton.styleFrom(
                                foregroundColor: textColor,
                                backgroundColor: backgroundColor
                              )
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 8),
                        DropdownMenu<String?>(
                          initialSelection: _selectedSortOrder,
                          width: MediaQuery.of(context).size.width - 72,
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
                              _selectedSortOrder = value;
                              _page = 0;
                              _isLoading = true;
                            });
                            _loadTask(widget.project['id'], _selectedSprintId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                          },
                          dropdownMenuEntries: listSortOrder.map((sort) {
                            return DropdownMenuEntry<String?>(
                              value: sort['value'], 
                              label: sort['name'],
                              style: MenuItemButton.styleFrom(
                                foregroundColor: textColor,
                                backgroundColor: backgroundColor
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _searchController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: Translations.get('task_proj_page19', currentLang),
                            hintStyle: TextStyle(color: hintColor),
                            filled: true,
                            fillColor: inputFillColor,
                            prefixIcon: Icon(Icons.search, color: iconColor), 
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
                          onChanged: (value) {
                            setState(() {
                              _selectedSearch = value;
                              _page = 0;
                            });
                            _loadTask(widget.project['id'], _selectedSprintId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                          },
                        ),
                      ],        
                    )
                  )
                ]
              )
            ),
            if(!_isLoading && tasks.isEmpty)
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
                      child: Icon(
                        Icons.assignment_outlined,
                        size: 60,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      Translations.get('task_proj_page20', currentLang),
                      style: TextStyle(
                        color: textColor, 
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Translations.get('task_proj_page21', currentLang),
                      style: TextStyle(
                        color: subtitleColor, 
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            if(!_isLoading && tasks.isNotEmpty)...{
              Divider(color: dividerColor, thickness: 1),
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
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
                        _isLoading = true; 
                      });
                      _loadTask(widget.project['id'], _selectedSprintId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
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
                                      task?['taskKey'] ?? '',
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
                                    if(task?['type'] != null)...{
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
                                      Text(
                                        ' • ',
                                        style: TextStyle(
                                          color: subtitleColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    },
                                    if(task?['status'] != null)
                                      Text(
                                        _translateStatus(task?['status']),
                                        style: TextStyle(
                                          color: subtitleColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    if(task?['estimationPoints']!=null && task?['estimationPoints']!=0)...{
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
                                          '${task?['estimationPoints']} ${Translations.get('task_proj_page22', currentLang)}',
                                          style: TextStyle(
                                            color: const Color(0xFF34D399),
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    },
                                    if(task?['assignee']!=null)...{
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
                                        backgroundColor: hexToColor(task?['assignee']?['color']),
                                        child: Text(
                                          "${task?['assignee']?['capitalLetters']}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            )
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          task?['assignee']?['fullName'] ?? '',
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 10),
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
              Divider(color: dividerColor, thickness: 1),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor)
                ),
                child: Column(
                  children: [
                    Text(
                      '${Translations.get('task_proj_page23', currentLang)} ${_page * _size + 1} - ${(_page * _size + tasks.length)} ${Translations.get('task_proj_page24', currentLang)} $_totalElements ${Translations.get('task_proj_page25', currentLang)}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _page > 0
                          ? () {
                              setState(() {
                                _page--;
                                _isLoading = true;
                              });
                              _loadTask(
                                widget.project['id'], 
                                _selectedSprintId, 
                                _selectedAssignenId, 
                                _selectedStatus, 
                                _selectedType, 
                                _selectedSortOrder, 
                                _selectedSearch
                              );
                            }
                          : null,
                          icon: Icon(Icons.chevron_left, size: 20),
                          label: Text(
                            Translations.get('task_proj_page26', currentLang),
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _page > 0 ? const Color(0xFF2D5AF0) : backgroundColor,
                            foregroundColor: _page > 0 ? Colors.white : subtitleColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            disabledBackgroundColor: backgroundColor,
                            disabledForegroundColor: subtitleColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            '${_page + 1} / $_totalPages',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _page < (_totalPages - 1) 
                          ? () {
                              setState(() {
                                _page++;
                                _isLoading = true;
                              });
                              _loadTask(
                                widget.project['id'], 
                                _selectedSprintId, 
                                _selectedAssignenId, 
                                _selectedStatus, 
                                _selectedType, 
                                _selectedSortOrder, 
                                _selectedSearch
                              );
                            }
                          : null,
                          icon: Icon(Icons.chevron_right, size: 20),
                          label: Text(
                            Translations.get('task_proj_page27', currentLang),
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _page < _totalPages - 1 ? const Color(0xFF2D5AF0) : backgroundColor,
                            foregroundColor: _page < _totalPages - 1 ? Colors.white : subtitleColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            disabledBackgroundColor: backgroundColor,
                            disabledForegroundColor: subtitleColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${Translations.get('task_proj_page28', currentLang)}: ',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: DropdownButton<int>(
                            value: _size,
                            dropdownColor: cardColor,
                            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                            underline: Container(),
                            items: pageSizeOptions.map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value'),
                              );
                            }).toList(),
                            onChanged: (int? newSize) {
                              if (newSize != null) {
                                setState(() {
                                  _size = newSize;
                                  _page = 0;
                                  _isLoading = true;
                                });
                                _loadTask(widget.project['id'], _selectedSprintId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),              
            },
            const SizedBox(height: 60),
          ]
        )
      )
    );
  }
}