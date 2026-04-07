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

class _TaskProjectPageState extends State<TaskProjectPage> with Theme_Page{

  final storage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true;

  Map<String, dynamic> taskData = {};

  String? _selectedType = "";
  String? _selectedStatus = "";
  String? _selectedAssignenId = "";
  int? _selectedSprintId;
  String? _selectedSortOrder = "desc";
  String _selectedSearch = "";

  int page = 0;
  int size = 10;

  int totalElements = 0;
  int totalPages = 0;
  int currentPage = 0;

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
      page = 0;
      isLoading = true;
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
        return Translations.get('task_proj_11', currentLang);
      case "TASK":
        return Translations.get('task_proj_12', currentLang);
      case "USER_STORY":
        return Translations.get('task_proj_13', currentLang);
      default:
        return type;
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case "BACKLOG":
        return Translations.get('task_proj_14', currentLang);
      case "TODO":
        return Translations.get('task_proj_15', currentLang);
      case "INPROGRESS":
        return Translations.get('task_proj_16', currentLang);
      case "VERIFY":
        return Translations.get('task_proj_17', currentLang);
      case "DONE":
        return Translations.get('task_proj_18', currentLang);
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

    String? token = await storage.read(key: 'auth_token');

    final params ={
      'page': page.toString(),
      'size': size.toString(),
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

      if (response.statusCode == 200 || response.statusCode == 204) {     
        setState((){
          taskData = jsonDecode(response.body);
          totalElements = taskData['totalElements'] ?? 0;
          totalPages = taskData['totalPages'] ?? 0;
          currentPage = taskData['currentPage'] ?? 0;
        });
      }
    } 
    catch (e) {
      setState(() {
        debugPrint("Error: $e");
      });
    }

    finally{
      setState((){
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    final List sprintsAux = widget.project['sprints'] ?? [];
    final List membersAux = widget.project['members'] ?? [];

    final List listTypes = [
        {'type': "", 'name': Translations.get('task_proj_5', currentLang)},
        {'type': 'USER_STORY', 'name': Translations.get('task_proj_13', currentLang)},
        {'type': 'TASK', 'name': Translations.get('task_proj_12', currentLang)},
        {'type': 'BUG', 'name': Translations.get('task_proj_11', currentLang)},
    ];

    final List listStatus = [
      {'status': "", 'name': Translations.get('task_proj_6', currentLang)},
      {'status': 'BACKLOG', 'name': Translations.get('task_proj_14', currentLang)},
      {'status': 'TODO', 'name': Translations.get('task_proj_15', currentLang)},
      {'status': 'INPROGRESS', 'name': Translations.get('task_proj_16', currentLang)},
      {'status': 'VERIFY', 'name': Translations.get('task_proj_17', currentLang)},
      {'status': 'DONE', 'name': Translations.get('task_proj_18', currentLang)},
    ];

    final List listAssignees = [
      {'id': "", 'fullName': Translations.get('task_proj_7', currentLang)},
      ...membersAux
    ];
    
    final List listSprints = [
      {'id': null, 'name': Translations.get('task_proj_8', currentLang)},
      ...sprintsAux
    ];

    final List listSortOrder = [
      {'value': 'desc', 'name': Translations.get('task_proj_9', currentLang)},
      {'value': 'asc', 'name': Translations.get('task_proj_10', currentLang)},
    ];

    final List<int> pageSizeOptions = [5, 10, 20, 50];

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

    final tasks = taskData['tasks'] ?? [];

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
              Translations.get('Torna', currentLang),
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: dividerColor, thickness: 1),
            Row(
              children: [
                Text(
                  Translations.get('task_proj_1', currentLang),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  ' • ',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.project['name'],
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
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
                      isLoading = true; 
                    });
                    _loadTask(widget.project['id'], _selectedSprintId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2D5AF0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    Translations.get('task_proj_2', currentLang), 
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
                          Translations.get('task_proj_3', currentLang),
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
                            Translations.get('task_proj_4', currentLang),
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
                              page = 0;
                              isLoading = true;
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
                              page = 0;
                              isLoading = true;
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
                              page = 0;
                              isLoading = true;
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
                              page = 0;
                              isLoading = true;
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
                              page = 0;
                              isLoading = true;
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
                            hintText: Translations.get('task_proj_19', currentLang),
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
                              page = 0;
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
            if(!isLoading && tasks.isEmpty)
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
                      Translations.get('task_proj_20', currentLang),
                      style: TextStyle(
                        color: textColor, 
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Translations.get('task_proj_21', currentLang),
                      style: TextStyle(
                        color: subtitleColor, 
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            if(!isLoading && tasks.isNotEmpty)...{
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
                        isLoading = true; 
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
                                          '${task['estimationPoints']} ${Translations.get('task_proj_22', currentLang)}',
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
                      '${Translations.get('task_proj_23', currentLang)} ${page * size + 1} - ${(page * size + tasks.length)} ${Translations.get('task_proj_24', currentLang)} $totalElements ${Translations.get('task_proj_25', currentLang)}',
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
                          onPressed: page > 0
                          ? () {
                              setState(() {
                                page--;
                                isLoading = true;
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
                            Translations.get('task_proj_26', currentLang),
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: page > 0 ? const Color(0xFF2D5AF0) : backgroundColor,
                            foregroundColor: page > 0 ? Colors.white : subtitleColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            disabledBackgroundColor: backgroundColor,
                            disabledForegroundColor: subtitleColor,
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
                            '${page + 1} / $totalPages',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: page < (totalPages - 1) 
                          ? () {
                              setState(() {
                                page++;
                                isLoading = true;
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
                            Translations.get('task_proj_27', currentLang),
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: page < totalPages - 1 ? const Color(0xFF2D5AF0) : backgroundColor,
                            foregroundColor: page < totalPages - 1 ? Colors.white : subtitleColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            disabledBackgroundColor: backgroundColor,
                            disabledForegroundColor: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${Translations.get('task_proj_28', currentLang)}: ',
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
                            value: size,
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
                                  size = newSize;
                                  page = 0;
                                  isLoading = true;
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