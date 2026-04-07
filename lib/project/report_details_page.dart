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

class _ReportDetailsPageState extends State<ReportDetailsPage> with Theme_Page {

  Map<String, dynamic>? reportData;

  final storage = FlutterSecureStorage();

  bool isLoading=true;

  bool taskStatuseAll = true;
  bool taskStatuseBacklog = true;
  bool taskStatuseToDo = true;
  bool taskStatuseInProgress = true;
  bool taskStatuseVerify = true;
  bool taskStatuseDone = true;


  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async{

    setState((){
      isLoading = true;
    });

    String? token = await storage.read(key: 'auth_token');

    List<String> listTaskStatuse = [];
    if (taskStatuseBacklog) listTaskStatuse.add("BACKLOG");
    if (taskStatuseToDo) listTaskStatuse.add("TODO");
    if (taskStatuseInProgress) listTaskStatuse.add("INPROGRESS");
    if (taskStatuseVerify) listTaskStatuse.add("VERIFY");
    if (taskStatuseDone) listTaskStatuse.add("DONE");

    final url = Uri.parse('https://trackdev.org/api/projects/${widget.project['id']}/reports/${widget.report['id']}/compute?status=${listTaskStatuse.join(',')}');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          reportData = jsonDecode(response.body); 
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

  String _translateRows(String type) {
    switch (type) {
      case "STUDENTS":
        return Translations.get('report_details_2', currentLang);
      case "SPRINTS":
        return Translations.get('report_details_3', currentLang);
      case "ESTIMATION_POINTS":
        return Translations.get('report_details_4', currentLang);
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {

    bool anyFilterActive = taskStatuseBacklog || taskStatuseToDo || taskStatuseInProgress || taskStatuseVerify ||taskStatuseDone;

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
              Translations.get('report_details_1', currentLang),
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
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${reportData!['reportName']}",
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${reportData!['projectName']} • ${_translateRows(reportData!['rowType'])} x ${_translateRows(reportData!['columnType'])} • ${_translateRows(reportData!['magnitude'])}",
                style: TextStyle(
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              Translations.get('report_details_5', currentLang),
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
                            if(taskStatuseAll){
                              taskStatuseAll = false;
                              taskStatuseBacklog = false;
                              taskStatuseToDo = false;
                              taskStatuseInProgress = false;
                              taskStatuseVerify = false;
                              taskStatuseDone = false;
                            }
                            else{
                              taskStatuseAll = true;
                              taskStatuseBacklog = true;
                              taskStatuseToDo = true;
                              taskStatuseInProgress = true;
                              taskStatuseVerify = true;
                              taskStatuseDone = true;
                            }
                          });
                          _loadReport();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: taskStatuseAll ? const Color(0xFF2D5AF0) : const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          Translations.get('report_details_6', currentLang), 
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if(taskStatuseBacklog){
                              taskStatuseBacklog = false;
                              if(taskStatuseAll){
                                taskStatuseAll=false; 
                              }
                            }
                            else{
                              taskStatuseBacklog = true;
                              if(taskStatuseBacklog && taskStatuseToDo && taskStatuseInProgress && taskStatuseVerify && taskStatuseDone){
                                taskStatuseAll=true;
                              }
                            }
                          });
                          _loadReport();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: taskStatuseBacklog ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          Translations.get('report_details_7', currentLang), 
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if(taskStatuseToDo){
                              taskStatuseToDo = false;
                              if(taskStatuseAll){
                                taskStatuseAll=false; 
                              }
                            }
                            else{
                              taskStatuseToDo = true;
                              if(taskStatuseBacklog && taskStatuseToDo && taskStatuseInProgress && taskStatuseVerify && taskStatuseDone){
                                taskStatuseAll=true;
                              }
                            }
                          });
                          _loadReport();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: taskStatuseToDo ? const Color(0xFFFBBF24) : const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          Translations.get('report_details_8', currentLang), 
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if(taskStatuseInProgress){
                              taskStatuseInProgress = false;
                              if(taskStatuseAll){
                                taskStatuseAll=false; 
                              }
                            }
                            else{
                              taskStatuseInProgress = true;
                              if(taskStatuseBacklog && taskStatuseToDo && taskStatuseInProgress && taskStatuseVerify && taskStatuseDone){
                                taskStatuseAll=true;
                              }
                            }                            
                          });
                          _loadReport();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: taskStatuseInProgress ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          Translations.get('report_details_9', currentLang), 
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                          if(taskStatuseVerify){
                              taskStatuseVerify = false;
                              if(taskStatuseAll){
                                taskStatuseAll=false; 
                              }
                            }
                            else{
                              taskStatuseVerify = true;
                              if(taskStatuseBacklog && taskStatuseToDo && taskStatuseInProgress && taskStatuseVerify && taskStatuseDone){
                                taskStatuseAll=true;
                              }
                            }                            
                          });
                          _loadReport();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: taskStatuseVerify ? const Color(0xFFA855F7) : const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          Translations.get('report_details_10', currentLang), 
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if(taskStatuseDone){
                              taskStatuseDone = false;
                              if(taskStatuseAll){
                                taskStatuseAll=false; 
                              }
                            }
                            else{
                              taskStatuseDone = true;
                              if(taskStatuseBacklog && taskStatuseToDo && taskStatuseInProgress && taskStatuseVerify && taskStatuseDone){
                                taskStatuseAll=true;
                              }
                            }                            
                          });
                          _loadReport();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: taskStatuseDone ? const Color(0xFF22C55E) : const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          Translations.get('report_details_11', currentLang), 
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
                          "${_translateRows(reportData!['rowType'])}/${_translateRows(reportData!['columnType'])}", 
                          style: TextStyle(
                            color: textColor, 
                            fontWeight: FontWeight.bold       
                          )                     
                        ),
                      ),
                      ...reportData!['columnHeaders'].map((sprint) => DataColumn(
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
                          Translations.get('report_details_12', currentLang),
                          style: TextStyle(
                            color: textColor, 
                            fontWeight: FontWeight.bold       
                          ),
                        ),
                        numeric: true,
                      ),
                    ],
                    rows: [            
                      ...reportData!['rowHeaders'].map((student){
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
                            ...reportData!['columnHeaders'].map((sprint){
                              final key = "${student['id']}:${sprint['id']}";
                              return DataCell(
                                Center(
                                  child: Text(
                                    anyFilterActive ? (reportData!['data'][key]).toString() : "0",
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
                                  anyFilterActive ? (reportData!['rowTotals'][student['id']]).toString() : "0",
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
                              Translations.get('report_details_12', currentLang),
                              style: TextStyle(
                                color: textColor, 
                                fontWeight: FontWeight.bold       
                              ),
                            )
                          ),
                          ...reportData!['columnHeaders'].map((sprint) {
                            return DataCell(
                              Center(
                                child: Text(
                                  anyFilterActive ? (reportData!['columnTotals'][sprint['id']]).toString() : "0",
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
                                anyFilterActive ? (reportData!['grandTotal']).toString() : "0", 
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