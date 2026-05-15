import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import '../project/task_details_page.dart';
import '../../utils/ui_helpers.dart';


class TasksSearchPage extends StatefulWidget {

  const TasksSearchPage({super.key});

  @override
  State<TasksSearchPage> createState() => _TasksSearchPageState();
}

class _TasksSearchPageState extends State<TasksSearchPage> with ThemePage{

  static const _storage = FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoadingTask = true;
  bool _isLoadingProject = true;

  List<dynamic> _projectsData = [];
  Map<String, dynamic> _taskData = {};

  Map<String, dynamic>? _selectedProject;

  String? _selectedType = "";
  String? _selectedStatus = "";
  String? _selectedAssignenId = "";
  String? _selectedSortOrder = "desc";
  String _selectedSearch = "";
  int? _selectedProjectId;

  int _page = 0;
  int _size = 10;

  int _totalElements = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _loadTask(_selectedProjectId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isLoading(){
    return _isLoadingTask || _isLoadingProject;
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
        setState((){
          _projectsData = responseData['projects'];
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

  void _resetFilters() {
    setState(() {
      _selectedType = "";
      _selectedStatus = "";
      _selectedAssignenId = "";
      _selectedProjectId = null;
      _selectedSortOrder = "desc";
      _selectedSearch = "";
      _searchController.clear();
      _page = 0;
      _isLoadingTask = true;
    });
    _loadTask( null, "", "", "", "desc", "");
  }

  Future<void> _loadTask(int? projectId, String? assigneeId, String? status, String? type, String? sortOrder, String? search) async{

    String? token = await _storage.read(key: 'auth_token');

    final params ={
      'page': _page.toString(),
      'size': _size.toString(),
      if(projectId != null) 'projectId': projectId.toString(), 
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
        _isLoadingTask = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    final List membersAux = _selectedProject?['members'] ?? [];
    final List projectsAux = _projectsData;

    final List listTypes = [
        {'type': "", 'name': Translations.get('tasks.allTypes', currentLang)},
        {'type': 'USER_STORY', 'name': Translations.get('tasks.typeUserStory', currentLang)},
        {'type': 'TASK', 'name': Translations.get('tasks.typeTask', currentLang)},
        {'type': 'BUG', 'name': Translations.get('tasks.typeBug', currentLang)},
    ];

    final List listStatus = [
      {'status': "", 'name': Translations.get('tasks.allStatuses', currentLang)},
      {'status': 'BACKLOG', 'name': Translations.get('tasks.statusBacklog', currentLang)},
      {'status': 'TODO', 'name': Translations.get('tasks.statusTodo', currentLang)},
      {'status': 'INPROGRESS', 'name': Translations.get('tasks.statusInProgress', currentLang)},
      {'status': 'VERIFY', 'name': Translations.get('tasks.statusVerify', currentLang)},
      {'status': 'DONE', 'name': Translations.get('tasks.statusDone', currentLang)},
    ];

    final List listAssignees = [
      {'id': "", 'fullName': Translations.get('tasks.allAssignees', currentLang)},
      ...membersAux
    ];
    
    final List listSortOrder = [
      {'value': 'desc', 'name': Translations.get('tasks.sortNewestFirst', currentLang)},
      {'value': 'asc', 'name': Translations.get('tasks.sortOldestFirst', currentLang)},
    ];

    final List listProjects = [
      {'id': null, 'name': Translations.get('activity.allProjects', currentLang)},
      ...projectsAux
    ];

    final List<int> pageSizeOptions = [5, 10, 20, 50];

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

    final tasks = _taskData['tasks'] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 125,
        title: Column(
          children: [
            UIHelpers.costumBackPopAppBar(context: context,text: Translations.get('common.back', currentLang), textColor: textColor),   
            UIHelpers.costumAppBar(
              dividerColor: dividerColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              title: Translations.get('tasks.myTasks', currentLang),
              subtitile: null,
            ),
          ]
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildTaskShearchSelect(listProjects, listTypes, listStatus, listAssignees, listSortOrder),
            if(!_isLoading() && tasks.isEmpty)
              _buildTaskShearchEmpty(),
            if(!_isLoading() && tasks.isNotEmpty)...{
              Divider(color: dividerColor, thickness: 1),
              _buildTaskShearchTasks(tasks),
              Divider(color: dividerColor, thickness: 1),
              const SizedBox(height: 24),
              _buildTaskShearchBottomNavagation(tasks, pageSizeOptions) 
            },
            const SizedBox(height: 60),
          ]
        )
      )
    );
  }

  Widget _buildTaskShearchSelect(List listProjects, List listTypes, List listStatus, List listAssignees, List listSortOrder){
    return Container(
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
          _buildTaskShearchSelectTitle(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTaskShearchDropMenuProjects(listProjects),
                SizedBox(height: 8),
                _buildTaskShearchDropMenuTypes(listTypes),
                SizedBox(height: 8),
                _buildTaskShearchDropMenuStatus(listStatus),
                SizedBox(height: 8),
                _buildTaskShearchDropMenuAssignees(listAssignees),
                SizedBox(height: 8),
                _buildTaskShearchDropMenuSortOrder(listSortOrder),
                SizedBox(height: 8),
                _buildTaskShearchTextFieldShearch(),
              ],        
            )
          )
        ]
      )
    );
  }

  Widget _buildTaskShearchSelectTitle(){
    return Container(
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
            Translations.get('tasks.filters', currentLang),
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
              Translations.get('tasks.clearFilters', currentLang),
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
    );
  }

  Widget _buildTaskShearchDropMenuProjects(List listProjects){
    return DropdownMenu<int?>(
      initialSelection: _selectedProjectId,
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
        setState(() {
          _selectedProjectId = value;                    
          for (var project in _projectsData) {
            if (project['id'] == value) {
              _selectedProject = project;
              break;
            }
            else{
              _selectedProject = null;
            }
          }
          _page = 0;
          _isLoadingTask = true;
        });
        _loadTask(_selectedProjectId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
      },
      dropdownMenuEntries: listProjects.map((spri) {
        return DropdownMenuEntry<int?>(
          value: spri['id'], 
          label: spri['name'],
          style: MenuItemButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: backgroundColor
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskShearchDropMenuTypes(List listTypes){
    return DropdownMenu<String?>(
      initialSelection: _selectedType,
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
          _selectedType = value;
          _page = 0;
          _isLoadingTask = true;
        });
        _loadTask(_selectedProjectId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
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
    );
  }

  Widget _buildTaskShearchDropMenuStatus(List listStatus){
    return DropdownMenu<String?>(
      initialSelection: _selectedStatus,
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
          _selectedStatus = value;
          _page = 0;
          _isLoadingTask = true;
        });
        _loadTask(_selectedProjectId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
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
    );
  }

  Widget _buildTaskShearchDropMenuAssignees(List listAssignees){
    return DropdownMenu<String?>(
      initialSelection: _selectedAssignenId,
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
          _selectedAssignenId = value;
          _page = 0;
          _isLoadingTask = true;
        });
          _loadTask(_selectedProjectId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
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
    );
  }

  Widget _buildTaskShearchDropMenuSortOrder(List listSortOrder){
    return DropdownMenu<String?>(
      initialSelection: _selectedSortOrder,
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
          _selectedSortOrder = value;
          _page = 0;
          _isLoadingTask = true;
        });
        _loadTask(_selectedProjectId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
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
    );
  }

  Widget _buildTaskShearchTextFieldShearch(){
    return TextField(
      controller: _searchController,
      style: TextStyle(color: textColor),
      decoration: UIHelpers.customInputDecorationTextField(
        inputFillColor: inputFillColor,
        borderColor: borderColor,
        hintColor: hintColor,
        hintText: Translations.get('tasks.searchPlaceholder', currentLang),
        prefixIcon: Icon(Icons.search, color: iconColor),
      ),
      onChanged: (value) {
        setState(() {
          _selectedSearch = value;
          _page = 0;
        });
        _loadTask(_selectedProjectId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
      },
    );
  }

  Widget _buildTaskShearchEmpty(){
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
              Icons.assignment_outlined,
              size: 60,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            Translations.get('tasks.noMatchingTasks', currentLang),
            style: TextStyle(
              color: textColor, 
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            Translations.get('tasks.tryAdjustingFilters', currentLang),
            style: TextStyle(
              color: subtitleColor, 
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskShearchTasks(List tasks){
    return ListView.builder(
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
              _isLoadingTask = true; 
            });
            _loadTask(_selectedProjectId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
          },
          child: UIHelpers.costumTask(
            textColor: textColor,
            subtitleColor: subtitleColor,
            task: task,
            currentLang: currentLang
          )
        );
      },
    );
  }

  Widget _buildTaskShearchBottomNavagation(List tasks, List<int> pageSizeOptions){
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor)
      ),
      child: Column(
        children: [
          Text(
            '${Translations.get('tasks.of', currentLang)} ${_page * _size + 1} - ${(_page * _size + tasks.length)} ${Translations.get('tasks.of', currentLang)} $_totalElements ${Translations.get('common.itemsPerPage', currentLang)}',
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
                      _isLoadingTask = true;
                    });
                    _loadTask( _selectedProjectId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                  }
                : null,
                icon: Icon(Icons.chevron_left, size: 20),
                label: Text(
                  Translations.get('common.previous', currentLang),
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
                      _isLoadingTask = true;
                    });
                    _loadTask( _selectedProjectId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                  }
                : null,
                icon: Icon(Icons.chevron_right, size: 20),
                label: Text(
                  Translations.get('common.next', currentLang),
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
                '${Translations.get('tasks.itemsPerPage', currentLang)}: ',
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
                        _isLoadingTask = true;
                      });
                      _loadTask(_selectedProjectId, _selectedAssignenId, _selectedStatus, _selectedType, _selectedSortOrder, _selectedSearch);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}