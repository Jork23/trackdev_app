import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import '../../utils/ui_helpers.dart';


class AddSubtaskPage extends StatefulWidget {
  final Map<String, dynamic>? task;

  const AddSubtaskPage({super.key, this.task});

  @override
  State<AddSubtaskPage> createState() => _AddSubtaskPageState();
}

class _AddSubtaskPageState extends State<AddSubtaskPage> with ThemePage {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedType = "TASK";
  String? _selectedAssignenId = "";

  static const _storage = FlutterSecureStorage();

  Map<String, dynamic>? _userData;

  String _message = '';
  bool _isSuccess = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _addSubtask() async {

    String? token = await _storage.read(key: 'auth_token');

    if (!mounted) return;

    if (_nameController.text.isEmpty) {
      setState((){ 
        _message = Translations.get('common.error', currentLang);
      });
      return;
    }

    try {
      final url = Uri.parse('https://trackdev.org/api/tasks/${widget.task!['id']}/subtasks');
      
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

      if (!mounted) return;

      setState((){
        if(response.statusCode == 200 || response.statusCode == 204) {
          _message = Translations.get('tasks.subtaskCreated', currentLang);
          _isSuccess = true;
        } 
        else{
          _message = '${Translations.get('common.error', currentLang)}: ${response.statusCode}';
        }
      });
    } 
    catch (e){
      if (!mounted) return;
      setState((){
        _message = '${Translations.get('common.error', currentLang)}: $e';
      });
    }
    finally{
      setState((){
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async{

    String? token = await _storage.read(key: 'auth_token');

    if (!mounted) return;

    final url = Uri.parse('https://trackdev.org/api/auth/self');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState((){
          _userData = jsonDecode(response.body); 
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

    final List listTypes = [
      {'type': 'TASK', 'name': Translations.get('tasks.typeTask', currentLang)},
      {'type': 'BUG', 'name': Translations.get('tasks.typeBug', currentLang)},
    ];

    final List listAssignees = [
      {'id': "", 'fullName': Translations.get('tasks.unassigned', currentLang)},
      {'id':_userData!['id'],'fullName': _userData!['fullName']},
    ];

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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UIHelpers.costumAppBar(
              dividerColor: dividerColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              title: Translations.get('tasks.addSubtask', currentLang),
              subtitile: null,
            ),
            const SizedBox(height: 20),
            _buildAddSubtaskName(),
            const SizedBox(height: 20),
            _buildAddSubtaskDescription(),  
            const SizedBox(height: 20),
            _buildAddSubtaskType(listTypes),
            const SizedBox(height: 20),
            _buildAddSubtaskAssignee(listAssignees),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              UIHelpers.costumMessage(_isSuccess, _message),
            if(!_isSuccess)
              _buildAddSubtaskIsSuccess()
            else
              UIHelpers.costumAddIsNotSuccess(context: context, textColor: textColor, borderColor:borderColor, currentLang: currentLang)
          ],
        ),
      ),
    );
  }

  Widget  _buildAddSubtaskName(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('tasks.name', currentLang), textColor),
        const SizedBox(height: 5),
        TextField(
          controller: _nameController,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            hintText: Translations.get('tasks.taskNamePlaceholder', currentLang),
          ),
        )
      ]
    );
  }

  Widget _buildAddSubtaskDescription(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('tasks.description', currentLang), textColor),
        const SizedBox(height: 5),
        TextField(
          controller: _descriptionController,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            hintText: Translations.get('tasks.taskDescriptionPlaceholder', currentLang),
          ),
        )
      ]
    );
  }

  Widget _buildAddSubtaskType(List<dynamic> listTypes){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('tasks.type', currentLang), textColor),
        const SizedBox(height: 5),
        DropdownMenu<String?>(
          initialSelection: _selectedType,
          width: MediaQuery.of(context).size.width,
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
      ]
    );
  }

  Widget _buildAddSubtaskAssignee(List<dynamic> listAssignees){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            Translations.get('tasks.assignee', currentLang),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
        const SizedBox(height: 5),
        DropdownMenu<String?>(
          initialSelection: _selectedAssignenId,
          width: MediaQuery.of(context).size.width,
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
      ]
    );
  }

  Widget _buildAddSubtaskIsSuccess(){
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: BorderSide(color: borderColor),
            ),
            child: Text(
              Translations.get('common.cancel', currentLang),
              style: TextStyle(color: textColor)
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 50,
          child: Expanded(
            child: ElevatedButton(
              onPressed: (){
                setState((){
                  _isLoading = false;
                });
                _addSubtask();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5AF0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                Translations.get('tasks.createTask', currentLang),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

}