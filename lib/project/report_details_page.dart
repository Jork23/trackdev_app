import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import '../../utils/ui_helpers.dart';


class ReportDetailsPage extends StatefulWidget {
  final Map<String, dynamic> report;
  final Map<String, dynamic> project;

  const ReportDetailsPage({super.key, required this.report, required this.project});

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> with ThemePage {

  Map<String, dynamic>? _reportData;

  static const _storage = FlutterSecureStorage();

  bool _isLoading=true;

  bool _taskStatuseAll = true;
  bool _taskStatuseBacklog = true;
  bool _taskStatuseToDo = true;
  bool _taskStatuseInProgress = true;
  bool _taskStatuseVerify = true;
  bool _taskStatuseDone = true;


  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async{

    String? token = await _storage.read(key: 'auth_token');

    List<String> listTaskStatuse = [];
    if (_taskStatuseBacklog) listTaskStatuse.add("BACKLOG");
    if (_taskStatuseToDo) listTaskStatuse.add("TODO");
    if (_taskStatuseInProgress) listTaskStatuse.add("INPROGRESS");
    if (_taskStatuseVerify) listTaskStatuse.add("VERIFY");
    if (_taskStatuseDone) listTaskStatuse.add("DONE");

    final url = Uri.parse('https://trackdev.org/api/projects/${widget.project['id']}/reports/${widget.report['id']}/compute?status=${listTaskStatuse.join(',')}');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _reportData = jsonDecode(response.body); 
        });
      }
    }
    catch (e){
      debugPrint("Error: $e");
    }
    finally{
      setState((){
        _isLoading = false;
      });
    }
  }

  String _translateRows(String type) {
    switch (type) {
      case "STUDENTS":
        return Translations.get('reports.students', currentLang);
      case "SPRINTS":
        return Translations.get('reports.sprints', currentLang);
      case "ESTIMATION_POINTS":
        return Translations.get('reports.estimationPoints', currentLang);
      default:
        return type;
    }
  }

  bool _anyFilterActive(){
    return _taskStatuseBacklog || _taskStatuseToDo || _taskStatuseInProgress || _taskStatuseVerify ||_taskStatuseDone;
  }

  @override
  Widget build(BuildContext context) {

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

    String? projectSubtitle;
    if(_reportData?['projectName'] != null && _reportData?['rowType'] != null && _reportData?['columnType'] != null && _reportData?['magnitude'] != null){   
      projectSubtitle = "${_reportData?['projectName']} • ${_translateRows(_reportData?['rowType'])} x ${_translateRows(_reportData?['columnType'])} • ${_translateRows(_reportData?['magnitude'])}";
    }

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
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIHelpers.costumAppBar(
                dividerColor: dividerColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                title: Translations.get('projects.title', currentLang),
                subtitile: projectSubtitle
              ),
              Text(
                Translations.get('reports.filterByStatus', currentLang),
                style: TextStyle(
                  color: textColor, 
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 5),
              SingleChildScrollView(
              scrollDirection: Axis.horizontal,
                child:Column(
                  children: [
                    _buildReportButtomSelect(),
                    const SizedBox(height: 20),
                    _buildReportDataTable()
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }

  Widget _buildReportButtomSelect(){
    return Row(
      children: [
        _buildReportButtomSelectAll(),
        const SizedBox(width: 5),
        _buildReportButtomSelectBacklog(),
        const SizedBox(width: 5),
        _buildReportButtomSelectToDo(),
        const SizedBox(width: 5),
        _buildReportButtomSelectInProgress(),
        const SizedBox(width: 5),
        _buildReportButtomSelectVerify(),
        const SizedBox(width: 5),
        _buildReportButtomSelectDone(),
      ],
    );
  }

  Widget _buildReportButtomSelectAll(){
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if(_taskStatuseAll){
            _taskStatuseAll = false;
            _taskStatuseBacklog = false;
            _taskStatuseToDo = false;
            _taskStatuseInProgress = false;
            _taskStatuseVerify = false;
            _taskStatuseDone = false;
          }
          else{
            _taskStatuseAll = true;
            _taskStatuseBacklog = true;
            _taskStatuseToDo = true;
            _taskStatuseInProgress = true;
            _taskStatuseVerify = true;
            _taskStatuseDone = true;
          }
          _isLoading = true;
        });
        _loadReport();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _taskStatuseAll ? const Color(0xFF2D5AF0) : const Color(0xFF64748B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        Translations.get('reports.allStatuses', currentLang), 
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _buildReportButtomSelectBacklog(){
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if(_taskStatuseBacklog){
            _taskStatuseBacklog = false;
            if(_taskStatuseAll){
              _taskStatuseAll=false; 
            }
          }
          else{
            _taskStatuseBacklog = true;
            if(_taskStatuseBacklog && _taskStatuseToDo && _taskStatuseInProgress && _taskStatuseVerify && _taskStatuseDone){
              _taskStatuseAll=true;
            }
          }
          _isLoading = true;
        });
        _loadReport();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _taskStatuseBacklog ? const Color(0xFFEF4444) : const Color(0xFF64748B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        Translations.get('tasks.statusBacklog', currentLang), 
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _buildReportButtomSelectToDo(){
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if(_taskStatuseToDo){
            _taskStatuseToDo = false;
            if(_taskStatuseAll){
              _taskStatuseAll=false; 
            }
          }
          else{
            _taskStatuseToDo = true;
            if(_taskStatuseBacklog && _taskStatuseToDo && _taskStatuseInProgress && _taskStatuseVerify && _taskStatuseDone){
              _taskStatuseAll=true;
            }
          }
          _isLoading = true;
        });
        _loadReport();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _taskStatuseToDo ? const Color(0xFFFBBF24) : const Color(0xFF64748B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        Translations.get('tasks.statusTodo', currentLang), 
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _buildReportButtomSelectInProgress(){
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if(_taskStatuseInProgress){
            _taskStatuseInProgress = false;
            if(_taskStatuseAll){
              _taskStatuseAll=false; 
            }
          }
          else{
            _taskStatuseInProgress = true;
            if(_taskStatuseBacklog && _taskStatuseToDo && _taskStatuseInProgress && _taskStatuseVerify && _taskStatuseDone){
              _taskStatuseAll=true;
            }
          }
          _isLoading = true;                        
        });
        _loadReport();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _taskStatuseInProgress ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        Translations.get('tasks.statusInProgress', currentLang), 
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _buildReportButtomSelectVerify(){
    return ElevatedButton(
      onPressed: () {
        setState(() {
        if(_taskStatuseVerify){
            _taskStatuseVerify = false;
            if(_taskStatuseAll){
              _taskStatuseAll=false; 
            }
          }
          else{
            _taskStatuseVerify = true;
            if(_taskStatuseBacklog && _taskStatuseToDo && _taskStatuseInProgress && _taskStatuseVerify && _taskStatuseDone){
              _taskStatuseAll=true;
            }
          }          
          _isLoading = true;                  
        });
        _loadReport();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _taskStatuseVerify ? const Color(0xFFA855F7) : const Color(0xFF64748B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        Translations.get('tasks.statusVerify', currentLang), 
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _buildReportButtomSelectDone(){
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if(_taskStatuseDone){
            _taskStatuseDone = false;
            if(_taskStatuseAll){
              _taskStatuseAll=false; 
            }
          }
          else{
            _taskStatuseDone = true;
            if(_taskStatuseBacklog && _taskStatuseToDo && _taskStatuseInProgress && _taskStatuseVerify && _taskStatuseDone){
              _taskStatuseAll=true;
            }
          }           
          _isLoading = true;                 
        });
        _loadReport();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _taskStatuseDone ? const Color(0xFF22C55E) : const Color(0xFF64748B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        Translations.get('tasks.statusDone', currentLang), 
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _buildReportDataTable(){
    return DataTable(
      border: TableBorder(
        verticalInside: BorderSide(width: 1, color: borderColor),
        horizontalInside: BorderSide(width: 1, color: borderColor),
        bottom: BorderSide(width: 1, color: borderColor),
        top: BorderSide(width: 1, color: borderColor),
        right: BorderSide(width: 1, color: borderColor),
        left: BorderSide(width: 1, color: borderColor),
      ),
      columnSpacing: 25,
      columns: [
        DataColumn(
          label: Text(
            "${_translateRows(_reportData?['rowType'])}/${_translateRows(_reportData?['columnType'])}", 
            style: TextStyle(
              color: textColor, 
              fontWeight: FontWeight.bold       
            )                     
          ),
        ),
        ..._reportData?['columnHeaders'].map((sprint) => DataColumn(
          label: Text(
            sprint['name'].toString(), 
            style: TextStyle(
              color: textColor, 
              fontWeight: FontWeight.bold       
            ),
          ),
          numeric: false,
        )),
        DataColumn(
          label: Text(
            Translations.get('reports.total', currentLang),
            style: TextStyle(
              color: textColor, 
              fontWeight: FontWeight.bold       
            ),
          ),
          numeric: true,
        ),
      ],
      rows: [            
        ..._reportData?['rowHeaders'].map((student){
          return DataRow(
            cells: <DataCell>[
              DataCell(
                Text(
                  student['name'].toString(),
                  style: TextStyle(
                    color: textColor, 
                    fontWeight: FontWeight.bold       
                  ),
                )
              ),
              ..._reportData!['columnHeaders'].map((sprint){
                final key = "${student['id']}:${sprint['id']}";
                return DataCell(
                  Center(
                    child: Text(
                      _anyFilterActive() ? ((_reportData?['data']?[key]) != null ? (_reportData?['data']?[key]).toString() : "0") : "0",
                      style: TextStyle(
                        color: subtitleColor
                      )
                    )
                  )
                );
              }),
              DataCell(
                Center(
                  child: Text(
                    _anyFilterActive() ? ((_reportData?['rowTotals']?[student['id']]) != null ? (_reportData?['rowTotals']?[student['id']]).toString() : "0") : "0",
                    style: TextStyle(
                        color: textColor, 
                        fontWeight: FontWeight.bold       
                    ),
                  )
                )
              ),
            ],
          );
        }),
        DataRow(
          cells: <DataCell>[
            DataCell(
              Text(
                Translations.get('reports.total', currentLang),
                style: TextStyle(
                  color: textColor, 
                  fontWeight: FontWeight.bold       
                ),
              )
            ),
            ..._reportData!['columnHeaders'].map((sprint) {
              return DataCell(
                Center(
                  child: Text(
                    _anyFilterActive() ? ((_reportData?['columnTotals']?[sprint['id']]) != null ? (_reportData?['columnTotals']?[sprint['id']]).toString() : "0") : "0",
                    style: TextStyle(
                      color: subtitleColor
                    )
                  )
                )
              );
            }),
            DataCell(
              Center(
                child: Text(
                  _anyFilterActive() ? (_reportData?['grandTotal'] != null ? (_reportData?['grandTotal']).toString() : "0") : "0",
                  style: TextStyle(
                      color: textColor, 
                      fontWeight: FontWeight.bold       
                  ),
                )
              )
            ),
          ],
        )
      ]
    );
  }
}