import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';


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
        return Translations.get('report_details_page2', currentLang);
      case "SPRINTS":
        return Translations.get('report_details_page3', currentLang);
      case "ESTIMATION_POINTS":
        return Translations.get('report_details_page4', currentLang);
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 60,
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
                    Translations.get('add_repository_page5', currentLang),
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
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5,),
              Divider(color: dividerColor, thickness: 1),
              Text(
                _reportData?['reportName'] ?? '',
                style: TextStyle(
                  color: textColor, 
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            if(_reportData?['projectName'] != null && _reportData?['rowType'] != null && _reportData?['columnType'] != null && _reportData?['magnitude'] != null)...{
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${_reportData?['projectName']} • ${_translateRows(_reportData?['rowType'])} x ${_translateRows(_reportData?['columnType'])} • ${_translateRows(_reportData?['magnitude'])}",
                  style: TextStyle(
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Divider(color: dividerColor, thickness: 1),
              const SizedBox(height: 20),
            },
            Text(
              Translations.get('report_details_page5', currentLang),
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
                  Row(
                    children: [
                       ElevatedButton(
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
                          Translations.get('report_details_page6', currentLang), 
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
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
                          Translations.get('report_details_page7', currentLang), 
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
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
                          Translations.get('report_details_page8', currentLang), 
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
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
                          Translations.get('report_details_page9', currentLang), 
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
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
                          Translations.get('report_details_page10', currentLang), 
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
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
                          Translations.get('report_details_page11', currentLang), 
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DataTable(
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
                          Translations.get('report_details_page12', currentLang),
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
                              Translations.get('report_details_page12', currentLang),
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
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }
}