import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';


class AddTaskPage extends StatefulWidget {
  final Map<String, dynamic>? project;

  const AddTaskPage({super.key, this.project});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> with Theme_Page {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedType = "USER_STORY";
  String? _selectedAssignenId = "";

  final storage = const FlutterSecureStorage();

  Map<String, dynamic>? userData;

  String _message = '';
  bool _isSuccess = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _addTask() async {

    String? token = await storage.read(key: 'auth_token');

    if (_nameController.text.isEmpty) {
      setState(() => _message = Translations.get('Siusplau, omple tots els camps', currentLang));
      return;
    }

    try {
      final url = Uri.parse('https://trackdev.org/api/projects/${widget.project?['id']}/tasks');
      
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'type': _selectedType,
          'assigneeId': _selectedAssignenId
        }),
      );

      setState((){
        if (response.statusCode == 200 || response.statusCode == 204) {
          _message = Translations.get('Tasca creada correctament', currentLang);
          _isSuccess = true;
        } else {
          _message = '${Translations.get('Error del servidor', currentLang)}: ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        _message = '${Translations.get('Error de xarxa', currentLang)}: $e';
      });
    }
  }

  Future<void> _loadUserData() async{

    String? token = await storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/auth/self');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          userData = jsonDecode(response.body); 
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




  @override
  Widget build(BuildContext context) {

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

    final List listTypes = [
      {'type': 'USER_STORY', 'name': Translations.get('Història d\'Usuari', currentLang)},
      {'type': 'TASK', 'name': Translations.get('Tasca', currentLang)},
      {'type': 'BUG', 'name': Translations.get('Error', currentLang)},
    ];

    final List listAssignees = [
      {'id': "", 'fullName': Translations.get('Sense assignar', currentLang)},
      {'id':userData!['id'],'fullName': userData!['fullName']},
    ];

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Divider(color: dividerColor, thickness: 1),
            Text(
              Translations.get('Crear Tasca', currentLang),
              style: TextStyle(
                color: textColor, 
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Divider(color: dividerColor, thickness: 1),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('Nom', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: Translations.get('Introdueix el nom de la tasca', currentLang),
                hintStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: inputFillColor,
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
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('Descripció', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: Translations.get('Introdueix la descripcio de la tasca(opcional)', currentLang),
                hintStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: inputFillColor,
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
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('Tipus', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownMenu<String?>(
              initialSelection: _selectedType,
              width: MediaQuery.of(context).size.width,
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
                });               
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Translations.get('Assignat', currentLang),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownMenu<String?>(
              initialSelection: _selectedAssignenId,
              width: MediaQuery.of(context).size.width,
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
                }); 
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
            const SizedBox(height: 12),
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSuccess ? Colors.green.shade200 : Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle_outline : Icons.error_outline, 
                        color: _isSuccess ? Colors.green : Colors.red, 
                        size: 20
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _message,
                          style: TextStyle(
                            color: _isSuccess ? Colors.green : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if(!_isSuccess)...{
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: borderColor),
                      ),
                      child: Text(Translations.get('Cancel.lar', currentLang), style: TextStyle(color: textColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5AF0),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(Translations.get('Crear Tasca', currentLang), style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            }
            else...{
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Text(Translations.get('Tornar', currentLang), style: TextStyle(color: textColor)),
                ),
              ),
            }
          ],
        ),
      ),
    );
  }
}