import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_repository_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'report_details_page.dart';
import 'sprint_details_page.dart';
import '../../utils/ui_helpers.dart';


class ProjectDetailsPage extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectDetailsPage({
    super.key, required this.project
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> with ThemePage{

  static const _storage = FlutterSecureStorage();

  Map<String, dynamic> _repositorisData = {};
  List<dynamic> _reportsData = [];

  bool _isLoadingRepository = true;
  bool _isLoadingReports = true;

  bool _isLoading(){
    return _isLoadingRepository || _isLoadingReports;
  }

  @override
  void initState() {
    super.initState();
    _loadRepositories();
    _loadReports();
  }

  String _translateRows(String type) {
    switch (type) {
      case "STUDENTS":
        return Translations.get('activity.filterUser', currentLang);
      case "SPRINTS":
        return Translations.get('activity.filterSprint', currentLang);
      default:
        return type;
    }
  }

  Future<void> _loadRepositories() async{

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/projects/${widget.project['id']}/github-repos');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _repositorisData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingRepository = false;
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url, 
        mode: LaunchMode.externalApplication
      );
    }
  }

  Future<void> _deleteRepository(int repositoryId) async{

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/projects/${widget.project['id']}/github-repos/$repositoryId');
    try {
      await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
    }
    catch (e){
      debugPrint("Error: $e");
    }
  }

  Future<void> _loadReports() async{

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/projects/${widget.project['id']}/reports');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _reportsData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoadingReports = false;
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

    final repositoris = _repositorisData['repos'] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 50,
        title: UIHelpers.costumBackPopAppBar(context: context,text: Translations.get('common.back', currentLang), textColor: textColor)
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UIHelpers.costumAppBar(
              dividerColor: dividerColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              title: Translations.get('projects.title', currentLang),
              subtitile: null,
            ),
            const SizedBox(height: 5),
            UIHelpers.costumProjectInfo(textColor: textColor,iconColor: iconColor,subtitleColor: subtitleColor,project: widget.project),
            const SizedBox(height: 15),
            _buildProjectQualification(),
            const SizedBox(height: 15),       
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProjectRepository(repositoris),
                const SizedBox(height: 15),
                _buildProjectReports(),
                const SizedBox(height: 15),
                _buildProjectSprints(),
                const SizedBox(height: 15),
                _buildProjectMembers(),
                const SizedBox(height: 50),
              ],
            )
          ]
        )
      )
    );
  }

  Widget _buildProjectQualification(){
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
              Translations.get('projects.qualification', currentLang),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if(!_isLoading())...{
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFF59E0B), width: 1),
                    ),
                      child: Icon(
                        Icons.assessment,
                        color: const Color(0xFFF59E0B),
                      size: 20
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project['qualification'] == null ? "-":  Translations.get('projects.qualification', currentLang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  )
                ]
              )
            )
          }
        ],
      ),
    );
  }

  Widget _buildProjectRepository(List<dynamic> repositoris){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildProjectRepositoryTitle(repositoris),
          if(!_isLoading() && _repositorisData.isEmpty)
            _buildProjectRepositoryEmpty(),
          if(!_isLoading() && _repositorisData.isNotEmpty)
            _buildProjectRepositoryNoEmpty(repositoris)
        ],
      ),
    );
  }

  Widget _buildProjectRepositoryTitle(List<dynamic> repositoris){
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
          Text(
            "${Translations.get('projects.githubRepos', currentLang)} (${repositoris.length})",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () async{
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddRepositoryPage(project: widget.project),
                ),
              );
              setState((){
                _isLoadingRepository = true; 
              });
              _loadRepositories();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              Translations.get('projects.addRepository', currentLang), 
              style: TextStyle(color: textColor),
            ),
          ),
        ]
      ),
    );
  }

  Widget _buildProjectRepositoryEmpty(){
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
            child: FaIcon(
              FontAwesomeIcons.github,
              size: 60,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            Translations.get('sprints.noSprints', currentLang),
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

  Widget _buildProjectRepositoryNoEmpty(List<dynamic> repositoris){
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: repositoris.length,
      itemBuilder: (context, index) {
        final repository = repositoris[index];
        return InkWell(
          onTap: () {
            _launchURL("https://github.com/${repository['fullName']}");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF5F6368), width: 1),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.github,
                    color: const Color(0xFF5F6368), 
                    size: 20
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repository?['name'] ?? '',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        repository?['fullName'] ?? '',
                        style: TextStyle(color: subtitleColor, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if(repository?['webhookActive']!=null)                                                           
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: repository?['webhookActive'] ? const Color(0xFFE6F4EA) : const Color(0xFFFCE8E6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: repository?['webhookActive'] ? const Color(0xFF1E8E3E) : const Color(0xFFD93025), 
                        width: 1
                      ),
                    ),
                    child: Text(
                      repository?['webhookActive'] ? Translations.get('sprints.statusActive', currentLang) : Translations.get('sprints.statusDraft', currentLang),
                      style: TextStyle(
                        color: repository?['webhookActive'] ? const Color(0xFF1E8E3E) : const Color(0xFFD93025),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.delete, color: iconColor, size: 20),
                  onPressed: () {
                    _deleteRepository(repository['id']);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectReports(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildProjectReportsTitle(),
          if(!_isLoading() && _reportsData.isEmpty)
            _buildProjectEmptyState(icon: Icons.assessment, message: 'proj_details_page16'),
          if(!_isLoading() && _reportsData.isNotEmpty)
            _buildProjectReportsNoEmpty()
        ],
      ),
    );
  }

  Widget _buildProjectReportsTitle(){
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
        "${Translations.get('navigation.reports', currentLang)} (${_reportsData.length})",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildProjectReportsNoEmpty(){
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reportsData.length,
      itemBuilder: (context, index) {
        final report = _reportsData[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetailsPage(report: report, project: widget.project),
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
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF4D97FF), width: 1),
                  ),
                  child: Icon(
                    Icons.assessment,
                    color: const Color(0xFF4D97FF), 
                    size: 20
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report?['name'] ?? '',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if(report?['rowType']!=null && report?['columnType']!=null)
                        Text(
                          "${Translations.get('reports.rows', currentLang)}: ${_translateRows(report?['rowType'])} | ${Translations.get('reports.columns', currentLang)}: ${_translateRows(report?['columnType'])}" ,
                          style: TextStyle(color: subtitleColor, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectSprints(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildProjectSprintsTitle(),
          if(!_isLoading() && widget.project['sprints'].isEmpty)
            _buildProjectEmptyState(icon: Icons.calendar_today_outlined, message: 'proj_details_page12'),
          if(!_isLoading() && widget.project['sprints'].isNotEmpty)
            _buildProjectSprintsNoEmpty()
        ],
      ),
    );
  }

  Widget _buildProjectSprintsTitle(){
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
        "${Translations.get('navigation.sprints', currentLang)} (${widget.project['sprints'].length})",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildProjectSprintsNoEmpty(){
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.project['sprints'].length,
      itemBuilder: (context, index) {
        final sprint = widget.project['sprints'][index];
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
                    color:  UIHelpers.getIconBackgroundColor(sprint['status']),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color:  UIHelpers.getIconColor(sprint['status']), width: 1),
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined, 
                    color:  UIHelpers.getIconColor(sprint['status']), 
                    size: 20
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(sprint?['name']!=null)
                        Text(
                          sprint?['name'],
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      if(sprint['startDate'] != null && sprint['endDate'] != null)
                        Text(                                              
                          "${ UIHelpers.formatDate(sprint['startDate'])} - ${ UIHelpers.formatDate(sprint['endDate'])}",
                          style: TextStyle(color: subtitleColor, fontSize: 12),
                        ),
                    ],
                  ),
                ),  
                if(sprint?['status'] != null)                                                        
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:  UIHelpers.getIconBackgroundColor(sprint?['status']),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color:  UIHelpers.getIconColor(sprint?['status']), width: 1),
                    ),
                    child: Text(
                      sprint?['status'],
                      style: TextStyle(
                        color:  UIHelpers.getIconColor(sprint['status']),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

    Widget _buildProjectMembers(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildProjectMembersTitle(),
          if(!_isLoading() && widget.project['members'].isEmpty)
            _buildProjectEmptyState(icon: Icons.group, message: Translations.get('projects.noTeamMembers', currentLang)),                     
          if(!_isLoading() && widget.project['members'].isNotEmpty)
            _buildProjectMembersNoEmpty()
        ],
      ),
    );
  }

  Widget _buildProjectMembersTitle(){
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
        "${Translations.get('projects.members', currentLang)} (${widget.project['members'].length})",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildProjectMembersNoEmpty(){
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.project['members'].length,
      itemBuilder: (context, index) {
        final member = widget.project['members'][index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child:Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(member?['color']!=null && member?['capitalLetters']!=null)
              CircleAvatar(
                radius: 22,
                backgroundColor:  UIHelpers.hexToColor(member?['color']),
                child: Text(
                  "${member?['capitalLetters']}",
                  style: TextStyle(color: Colors.white)
                ),
              ),
              const SizedBox(width: 10),
              Expanded(  
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member?['fullName'] ?? '',
                      style: TextStyle(color: textColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),                   
                    if(member?['email'] != null)
                      Text(
                        "${member?['email']}",
                        style: TextStyle(color: textColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ]
                )
              )
            ]
          )
        );
      },
    );
  }

  Widget _buildProjectEmptyState({required IconData icon,required String message,}) {
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
}