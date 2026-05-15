import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import '../../utils/ui_helpers.dart';


class ActivityPage extends StatefulWidget {

  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with ThemePage{

  static const _storage = FlutterSecureStorage();

  bool _isLoadingActivities = true;
  bool _isLoadingProjects = true;

  final Map<String, dynamic> _activityData = {};
  Map<String, dynamic> _projectsData = {};

  int? _selectedProject;
  int? _selectedSprint;
  String? _selectedMember;

  int _page = 0;

  bool _hasNext = false;


  @override
  void initState() {
    super.initState();
    _loadActivities(null,null,"");
    _loadProjects();
    _selectedProject = null;
    _selectedSprint = null;
    _selectedMember = "";
  }

  bool _isLoading(){
    return _isLoadingActivities || _isLoadingProjects;
  }

  Future<void> _loadProjects() async{

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/projects');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);

        List projectList = decodedData['projects'] ?? [];

        projectList.insert(0,{
          'id':null,
          'name': Translations.get('activity.allProjects', currentLang),
        });
        if (!mounted) return;

        setState((){
          _projectsData = {'projects': projectList};
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingProjects = false;
      });
    }
  }

  Future<void> _loadActivities(int? projectId, int? sprintId, String? actorId) async{

    String? token = await _storage.read(key: 'auth_token');

    final params ={
      'page': _page.toString(),
      'size': '20',
      if(projectId!=null) 'projectId': '$projectId',
      if(sprintId!=null) 'sprintId': '$sprintId',
      if(actorId !=null && actorId.isNotEmpty) 'actorId': actorId,
    };

    final url = Uri.https('trackdev.org', '/api/activities', params);
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        List activityList = decodedData['activities'] ?? [];

        setState((){
          _activityData['activities'] ??= [];
          _activityData['activities'].addAll(activityList);
          _hasNext = decodedData['hasNext'];
          _page++;
        });
      }
    } 
    catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingActivities = false;
      });
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case "TASK_STATUS_CHANGED": return Icons.play_circle_outline;
      case "TASK_ASSIGNED":       return Icons.person_outline;
      case "TASK_CREATED":        return Icons.add_circle_outline;
      case "TASK_ADDED_TO_SPRINT": return Icons.check_circle_outline;
      case "TASK_REMOVED_FROM_SPRINT": return Icons.check_circle_outline;
      case "TASK_UPDATED":        return Icons.timeline;
      case "TASK_ESTIMATION_CHANGED": return Icons.sync;
      case "PR_LINKED": return Icons.merge_type;
      case "TASK_UNASSIGNED": return Icons.person_remove;
      default:                    return Icons.help_outline;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case "TASK_STATUS_CHANGED": return Colors.blue;
      case "TASK_ASSIGNED":       return Colors.purple;
      case "TASK_CREATED":        return Colors.green;
      case "TASK_ADDED_TO_SPRINT": return Colors.indigo;
      case "TASK_REMOVED_FROM_SPRINT": return Colors.indigo;
      case "TASK_UPDATED":        return Colors.grey;
      case "TASK_ESTIMATION_CHANGED": return Colors.cyan;
      case "PR_LINKED": return Colors.pinkAccent;
      case "TASK_UNASSIGNED": return Colors.orange;
      default:                    return Colors.grey;
    }
  }

  String _t(String key, Map<String, String> params) {
    String text = Translations.get(key, currentLang);
    params.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  String _getText(Map<String, dynamic> activity) {
    final actor = activity['actorFullName'] ?? '';
    final taskKey = activity['taskKey'] ?? '';
    final oldValue = activity['oldValue'] ?? '';
    final newValue = activity['newValue'] ?? '';

    switch (activity['type']) {
      case 'TASK_STATUS_CHANGED':
        return _t('activity.eventTaskStatusChanged', {'actor': actor, 'taskKey': taskKey, 'oldValue': oldValue, 'newValue': newValue});
      case 'TASK_ASSIGNED':
        return _t('activity.eventTaskAssigned', {'actor': actor, 'taskKey': taskKey, 'newValue': newValue});
      case 'TASK_UNASSIGNED':
        return _t('activity.eventTaskUnassigned', {'actor': actor, 'taskKey': taskKey, 'oldValue': oldValue});
      case 'TASK_CREATED':
        return _t('activity.eventTaskCreated', {'actor': actor, 'taskKey': taskKey});
      case 'TASK_ADDED_TO_SPRINT':
        return _t('activity.eventTaskAddedToSprint', {'actor': actor, 'taskKey': taskKey, 'newValue': newValue});
      case 'TASK_REMOVED_FROM_SPRINT':
        return _t('activity.eventTaskRemovedFromSprint', {'actor': actor, 'taskKey': taskKey, 'oldValue': oldValue});
      case 'TASK_UPDATED':
        return _t('activity.eventTaskUpdated', {'actor': actor, 'taskKey': taskKey});
      case 'TASK_ESTIMATION_CHANGED':
        return _t('activity.eventTaskEstimationChanged', {'actor': actor, 'taskKey': taskKey, 'oldValue': oldValue, 'newValue': newValue});
      case 'PR_LINKED':
        return _t('activity.eventPrLinked', {'actor': actor, 'taskKey': taskKey});
      default:
        return '';
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

    Map<String, dynamic>? selectedProjectData;

    for (var p in (_projectsData['projects'] ?? [])) {
      if (p['id'] == _selectedProject) {
        selectedProjectData = p;
        break;
      }
    }

    final List sprintsAux = selectedProjectData?['sprints'] ?? [];
    final List membersAux = selectedProjectData?['members'] ?? [];

    final List sprints = [
        {'id': null, 'name': Translations.get('activity.allSprints', currentLang)},
        ...sprintsAux
    ];

    final List members = [
        {'id': "", 'fullName': Translations.get('activity.allUsers', currentLang)},
        ...membersAux
    ];

    final activities = _activityData['activities'] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        toolbarHeight: 90,
        centerTitle: true,
        title: UIHelpers.costumAppBar(
          dividerColor: dividerColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          title: Translations.get('activity.title', currentLang),
          subtitile: null,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityContainerSearch(sprints, members),
            if(!_isLoading() && activities.isEmpty)
              _buildActivityEmpty(),
            if(!_isLoading() && activities.isNotEmpty)...{
              _buildActivities(activities),
            },
            if(_hasNext)
              _buildActivityMoreLoadBottom()
          ]
        )
      )
    );
  }

  Widget _buildActivityContainerSearch(List sprints, List members){
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D5AF0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              )
            ),         
            child: Text(
              Translations.get('navigation.projects', currentLang),
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildActivityDropMenuProject(),
                if(_selectedProject!=null)...[   
                  SizedBox(height: 10),
                  _buildActivityDropMenuSprint(sprints),
                  SizedBox(height: 10),
                  _buildActivityDropMenuMmember(members)
                ]
              ],        
            )
          )
        ]
      )
    );
  }

  Widget _buildActivityDropMenuProject(){
    return DropdownMenu<int?>(
      initialSelection: _selectedProject,
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
          if(_selectedProject!=value){
            _selectedProject = value;
            _selectedSprint = null;
            _selectedMember = "";
          }
          _activityData.clear();
          _page=0;
          _isLoadingActivities = true;
        });
        _loadActivities(value, null, "");
      },
      dropdownMenuEntries: (_projectsData['projects'] as List? ?? []).map((proj) {
        return DropdownMenuEntry<int?>(
          value: proj['id'], 
          label: proj['name'],
          style: MenuItemButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: backgroundColor
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityDropMenuSprint(List sprints){
    return DropdownMenu<int?>(
      initialSelection: _selectedSprint,
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
          _selectedSprint = value;
          _activityData.clear();
          _page=0;
          _isLoadingActivities = true;
        });
        _loadActivities(_selectedProject, value, _selectedMember);
      },
      dropdownMenuEntries: (sprints).map((spri) {
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

  Widget _buildActivityDropMenuMmember(List members){
    return DropdownMenu<String?>(
      initialSelection: _selectedMember,
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
          _selectedMember = value;
          _activityData.clear();
          _page=0;
          _isLoadingActivities = true;
        });
        _loadActivities(_selectedProject, _selectedSprint, value);
      },
      dropdownMenuEntries: (members).map((memb) {
        return DropdownMenuEntry<String?>(
          value: memb['id'], 
          label: memb['fullName'],
          style: MenuItemButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: backgroundColor
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityEmpty(){
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
              Icons.bar_chart,
              size: 60,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            Translations.get('activity.noActivity', currentLang),
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

  Widget _buildActivities(List activities){
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index){
        final activity = activities[index];
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor)
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child:Icon(                         
                  _getIcon(activity['type']),
                  color:_getIconColor(activity['type'])
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _getText(activity),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2,),
                    Row(
                      children: [
                        if(activity?['taskKey'] != null)...{
                          SizedBox(width: 5),
                          Text(
                            activity?['taskKey'] ?? '',
                            style: TextStyle(
                              color: const Color(0xFF2D5AF0), 
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        },
                        if(activity?['projectName'] != null)...{
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              activity?['projectName'] ?? '',
                              style: TextStyle(
                                color: textColor, 
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        },
                        if(activity?['createdAt'] != null)...{
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              UIHelpers.formatDate(activity?['createdAt']),
                              style: TextStyle(
                                color: subtitleColor, 
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        }
                      ],                              
                    )
                  ],
                )
              )
            ]
          )
        );
      }
    );
  }

  Widget _buildActivityMoreLoadBottom(){
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed:(){
          _loadActivities(_selectedProject, _selectedSprint, _selectedMember);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D5AF0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          Translations.get('activity.loadMore', currentLang),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

}