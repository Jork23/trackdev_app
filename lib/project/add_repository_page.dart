import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import '../../utils/ui_helpers.dart';


class AddRepositoryPage extends StatefulWidget {
  final Map<String, dynamic>? project;

  const AddRepositoryPage({super.key, this.project});

  @override
  State<AddRepositoryPage> createState() => _AddRepositoryPageState();
}

class _AddRepositoryPageState extends State<AddRepositoryPage> with ThemePage {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  static const _storage = FlutterSecureStorage();

  String _message = '';
  bool _isSuccess = false;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _addRepository() async {

    String? token = await _storage.read(key: 'auth_token');

    if (!mounted) return;

    if (_nameController.text.isEmpty || _urlController.text.isEmpty || _tokenController.text.isEmpty) {
      setState(() {
        _message = Translations.get('common.error', currentLang);
      });
      return;
    }

    try {
      final url = Uri.parse('https://trackdev.org/api/projects/${widget.project?['id']}/github-repos');
      
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'url': _urlController.text,
          'accessToken': _tokenController.text
        }),
      );

      if (!mounted) return;

      setState((){
        if(response.statusCode == 200 || response.statusCode == 204){
          _message = Translations.get('common.success', currentLang);
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
        toolbarHeight: 50,
        title: UIHelpers.costumBackPopAppBar(context: context,text: Translations.get('common.back', currentLang), textColor: textColor)
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            UIHelpers.costumAppBar(
              dividerColor: dividerColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
              title: Translations.get('projects.addGithubRepository', currentLang),
              subtitile: null,
            ),
            const SizedBox(height: 10),
            _buildAddRepositoryName(),
            const SizedBox(height: 20),
            _buildAddRepositoryURL(),
            const SizedBox(height: 20),
            _buildAddRepositoryToken(),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              UIHelpers.costumMessage(_isSuccess, _message),
            if(!_isSuccess)
              _buildAddRepositoryIsSuccess()
            else
              UIHelpers.costumAddIsNotSuccess(context: context, textColor: textColor, borderColor:borderColor, currentLang: currentLang)
          ],
        ),
      ),
    );
  }

  Widget _buildAddRepositoryName(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('projects.displayName', currentLang), textColor),
        const SizedBox(height: 5),
        TextField(
          controller: _nameController,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            hintText: Translations.get('projects.addRepository', currentLang),
            prefixIcon: Icon(Icons.email_outlined, color: iconColor),
          ),
        ),
        const SizedBox(height: 5),
        UIHelpers.costumSubtitle(Translations.get('projects.fullUrlToRepo', currentLang), textColor), 
      ]
    );
  }

  Widget _buildAddRepositoryURL(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('projects.repositoryUrl', currentLang), textColor),
        const SizedBox(height: 5),
        TextField(
          controller: _urlController,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            hintText: 'https://github.com/owner/repo',
            prefixIcon: Icon(Icons.link, color: iconColor), 
          ),
        )
      ]
    );
  }

  Widget _buildAddRepositoryToken(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('projects.accessToken', currentLang), textColor),
        const SizedBox(height: 5),
        TextField(
          controller: _tokenController,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            hintText: 'ghp_xxxxxxxxx',
            prefixIcon: Icon(Icons.vpn_key_outlined, color: iconColor),
          ),
        ),
        const SizedBox(height: 5),
        UIHelpers.costumSubtitle(Translations.get('projects.accessTokenScopes', currentLang), textColor), 
      ]
    );
  }

  Widget _buildAddRepositoryIsSuccess(){
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
                _addRepository();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5AF0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                Translations.get('projects.addRepository', currentLang),
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