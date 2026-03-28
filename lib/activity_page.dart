import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/theme.dart';
import '../utils/translations.dart';


class ActivityPage extends StatefulWidget {

  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with Theme_Page{

  final storage = const FlutterSecureStorage();

  bool isLoading = true;

  Map<String, dynamic> activityData = {};
  Map<String, dynamic> projectsData = {};

  int? _selectedProject;
  int? _selectedSprint;
  String? _selectedMember;

  int page = 0;


  @override
  void initState() {
    super.initState();
    _loadActivities(null,null,"");
    _loadProjects();
    _selectedProject = null;
    _selectedSprint = null;
    _selectedMember = "";
  }

  Future<void> _loadProjects() async{

    String? token = await storage.read(key: 'auth_token');

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
          'name': Translations.get('activity_page3', currentLang),
        });
        setState((){
          projectsData = {'projects': projectList};
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        isLoading = false;
      });
    }
  }

  Future<void> _loadActivities(int? projectId, int? sprintId, String? actorId) async{

    String? token = await storage.read(key: 'auth_token');
    final params ={
      'page': page.toString(),
      'size': '20',
      if(projectId!=null) 'projectId': '$projectId',
      if(sprintId!=null) 'sprintId': '$sprintId',
      if(actorId !=null && actorId.isNotEmpty) 'actorId': actorId,

    };

    final url = Uri.https('trackdev.org', '/api/activities', params);
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {

        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        List activityList = decodedData['activities'] ?? [];

        setState((){
          activityData['activities'] ??= [];
          activityData['activities'].addAll(activityList);
          page++;
        });
      }
    } catch (e) {
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
      default:                    return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    Map<String, dynamic>? selectedProjectData;

    for (var p in (projectsData['projects'] ?? [])) {
      if (p['id'] == _selectedProject) {
        selectedProjectData = p;
        break;
      }
    }

    final List sprintsAux = selectedProjectData?['sprints'] ?? [];
    final List membersAux = selectedProjectData?['members'] ?? [];

    final List sprints = [
        {'id': null, 'name': Translations.get('activity_page4', currentLang)},
        ...sprintsAux
    ];

    final List members = [
        {'id': "", 'fullName': Translations.get('activity_page5', currentLang)},
        ...membersAux
    ];

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

    final activities = activityData['activities'] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        toolbarHeight: 100,
        centerTitle: true,
        title: Column(
          children:[
            Divider(color: dividerColor, thickness: 1),
            Text (Translations.get('activity_page1', currentLang),
              style: TextStyle(
                  color: textColor, 
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            Divider(color: dividerColor, thickness: 1),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5AF0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      )
                    ),         
                    child: Text(
                      Translations.get('activity_page2', currentLang),
                      style: TextStyle(
                        color: subtitleColor, 
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DropdownMenu<int?>(
                          initialSelection: _selectedProject,
                          width: MediaQuery.of(context).size.width - 72,
                          textStyle: TextStyle(color: textColor),
                          menuStyle: MenuStyle(
                            backgroundColor: WidgetStateProperty.all(cardColor),
                            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                            side: WidgetStateProperty.all(
                              BorderSide(color: borderColor, width: 1),
                            ),
                          ),
                          onSelected: (int? value) async {
                            setState(() {
                              if(_selectedProject!=value){
                                _selectedProject = value;
                                _selectedSprint = null;
                                _selectedMember = "";
                              }
                              activityData.clear();
                              page=0;
                            });
                            _loadActivities(value, null, "");
                          },
                          dropdownMenuEntries: (projectsData['projects'] as List? ?? []).map((proj) {
                            return DropdownMenuEntry<int?>(
                              value: proj['id'], 
                              label: proj['name'],
                              style: MenuItemButton.styleFrom(
                                foregroundColor: textColor,
                                backgroundColor: backgroundColor
                              ),
                            );
                          }).toList(),
                        ),
                        if(_selectedProject!=null)...[   
                          SizedBox(height: 10),
                          DropdownMenu<int?>(
                            initialSelection: _selectedSprint,
                            width: MediaQuery.of(context).size.width - 72,
                            textStyle: TextStyle(color: textColor),
                            menuStyle: MenuStyle(
                              backgroundColor: WidgetStateProperty.all(cardColor),
                              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                              side: WidgetStateProperty.all(
                                BorderSide(color: borderColor, width: 1),
                              ),
                            ),
                            onSelected: (int? value) async {
                              setState(() {
                                _selectedSprint = value;
                                activityData.clear();
                                page=0;
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
                          ),
                          SizedBox(height: 10),
                          DropdownMenu<String?>(
                            initialSelection: _selectedMember,
                            width: MediaQuery.of(context).size.width - 72,
                            textStyle: TextStyle(color: textColor),
                            menuStyle: MenuStyle(
                              backgroundColor: WidgetStateProperty.all(cardColor),
                              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                              side: WidgetStateProperty.all(
                                BorderSide(color: borderColor, width: 1),
                              ),
                            ),
                            onSelected: (String? value) async {
                              setState(() {
                                _selectedMember = value;
                                activityData.clear();
                                page=0;
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
                          ),
                        ]
                      ],        
                    )
                  )
                ]
              )
            ),
            if(!isLoading && activities.isEmpty)
              Text(
                Translations.get('activity_page6', currentLang),
                style: TextStyle(
                  color: textColor, 
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ),
            ListView.builder(
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
                                if (activity['type'] == 'TASK_STATUS_CHANGED')...{
                                  Expanded(
                                    child: Text(
                                      "${activity['actorFullName']}${Translations.get('activity_page8', currentLang)}${activity['taskKey']}${Translations.get('activity_page17', currentLang)}${activity['oldValue']}${Translations.get('activity_page16', currentLang)}${activity['newValue']}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                } 
                                else if (activity['type'] == 'TASK_ASSIGNED')...{
                                  Expanded(
                                    child: Text(
                                      "${activity['actorFullName']}${Translations.get('activity_page9', currentLang)}${activity['newValue']}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                } 
                                else if (activity['type'] == 'TASK_CREATED')...{
                                  Expanded(
                                    child: Text(
                                      "${activity['actorFullName']}${Translations.get('activity_page10', currentLang)}${activity['taskKey']}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                } 
                                else if (activity['type'] == 'TASK_ADDED_TO_SPRINT')...{
                                  Expanded(
                                    child: Text(
                                      "${activity['actorFullName']}${Translations.get('activity_page11', currentLang)} ${activity['taskKey']}${Translations.get('activity_page19', currentLang)}${activity['newValue']}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                } 
                                else if (activity['type'] == 'TASK_REMOVED_FROM_SPRINT')...{
                                  Expanded(
                                    child: Text(
                                      "${activity['actorFullName']}${Translations.get('activity_page12', currentLang)} ${activity['taskKey']}${Translations.get('activity_page19', currentLang)}${activity['oldValue']}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                } 
                                else if (activity['type'] == 'TASK_UPDATED')...{
                                  Expanded(
                                    child: Text(
                                      "${activity['actorFullName']}${Translations.get('activity_page13', currentLang)}${activity['taskKey']}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                }
                                else if (activity['type'] == 'TASK_ESTIMATION_CHANGED')...{
                                  Expanded(
                                    child: Text(
                                      "${activity['actorFullName']}${Translations.get('activity_page14', currentLang)}${activity['taskKey']}${Translations.get('activity_page17', currentLang)}${activity['oldValue']}${Translations.get('activity_page16', currentLang)}${activity['newValue']}${Translations.get('activity_page18', currentLang)}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                }
                                else if (activity['type'] == 'PR_LINKED')...{
                                  Expanded(
                                    child: Text(
                                      "${activity['actorFullName']}${Translations.get('activity_page15', currentLang)}${activity['taskKey']}",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                }
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: 5),
                                Text(
                                  activity['taskKey'],
                                  style: TextStyle(
                                    color: const Color(0xFF2D5AF0), 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  activity['projectName'],
                                  style: TextStyle(
                                    color: textColor, 
                                    fontSize: 10,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  activity['createdAt'],
                                  style: TextStyle(
                                    color: subtitleColor, 
                                    fontSize: 10,
                                  ),
                                ),
                              ],                              
                            )
                          ],
                        )
                      )
                    ]
                  )
                );
              }
            ),
            SizedBox(
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
                  Translations.get('activity_page7', currentLang),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ]
        )
      )
    );
  }
}