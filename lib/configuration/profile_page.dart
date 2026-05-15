import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../utils/theme.dart';
import '../../utils/translations.dart';
import '../../utils/ui_helpers.dart';


class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onProfileUpdated;

  const ProfilePage({super.key, this.userData,this.onProfileUpdated});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with ThemePage{

  static const  _storage = FlutterSecureStorage();

  late TextEditingController _userNameController;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _colorAvatarController;

  String _message = '';
  bool _isSuccess = false;

  bool _isLoading = false;

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          Translations.get('common.actions', currentLang),
          style: TextStyle(color: textColor),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: UIHelpers.hexToColor(_colorAvatarController.text),
            onColorChanged: (Color color) {
              String hexString = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';                     
              _colorAvatarController.text = hexString;
            },
            enableAlpha: false,
            displayThumbColor: true,
            pickerAreaHeightPercent: 0.7,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.userData?['username'] ?? '');
    _fullNameController = TextEditingController(text: widget.userData?['fullName'] ?? '');
    _emailController = TextEditingController(text: widget.userData?['email'] ?? '');
    _colorAvatarController = TextEditingController(text: widget.userData?['color'] ?? '#2D5AF0');

    _colorAvatarController.addListener(() {
      if (mounted) setState(() {});
    });

  }

  @override
  void dispose() {
    _userNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _colorAvatarController.dispose();
    super.dispose();
  }

  Future<void> _saveProfilEdit() async{

    String? token = await _storage.read(key: 'auth_token');

    final url = Uri.parse('https://trackdev.org/api/users');
    try {
      final response = await http.patch(
        url,
        headers: {'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',},
        body: jsonEncode({
          'username': _userNameController.text,
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'color': _colorAvatarController.text
        }),
      );

      if (!mounted) return;

      setState((){
        if(response.statusCode == 200 || response.statusCode == 204){
          _message = Translations.get('common.success', currentLang);
          _isSuccess = true;
          widget.onProfileUpdated?.call();
        } 
        else {
          _message = '${Translations.get('common.error', currentLang)}: ${response.statusCode}';
        }
      });
    } 
    catch(e){
      if (!mounted) return;
      setState(() {
        _message = '${Translations.get('common.error', currentLang)}: $e';
      });
    }
    finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    if( widget.userData == null || _isLoading){
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
        toolbarHeight: 100,
        centerTitle: true,
        title: UIHelpers.costumAppBar(
          dividerColor: dividerColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          title: Translations.get('settings.profileInfo', currentLang),
          subtitile: Translations.get('settings.profileInfoDescription', currentLang),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileUserInfo(),
            const SizedBox(height: 20),
            _buildProfileUserName(),
            const SizedBox(height: 20),
            _buildProfileFullName(),
            const SizedBox(height: 20),
            _buildProfileEmail(),
            const SizedBox(height: 20),
            _buildProfileAvatarColor(),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)...{
              UIHelpers.costumMessage(_isSuccess, _message),
              const SizedBox(height: 20),
            },
            _buildProfileBottom()
          ]
        ),
      )
    );
  }

  Widget _buildProfileUserInfo(){
    return Row(
      children: [
        if(widget.userData?['capitalLetters'] != null)
          CircleAvatar(
            radius: 30,
            backgroundColor: UIHelpers.hexToColor(widget.userData?['color']),
            child: Text(
              "${widget.userData?['capitalLetters']}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28
              )
            ),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(widget.userData?['fullName'] != null)
                Text(
                  "${widget.userData?['fullName']}",
                  style: TextStyle(
                    color: textColor,                            
                  ),
                  overflow: TextOverflow.ellipsis
                ),
              if(widget.userData?['email'] != null)
                Text(
                  "${widget.userData?['email']}",
                  style: TextStyle(
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis
                ),
              const SizedBox(height: 5),
              if((widget.userData?['roles'] ?? []).isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined, size: 12, color: Color(0xFF2D5AF0)),
                      const SizedBox(width: 4),
                      Text(
                        widget.userData?['roles'][0],
                        style: const TextStyle(
                          color: Color(0xFF2D5AF0),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),                               
                      ),
                    ],
                  ),
                ),
            ]
          )
        )
      ]
    );
  }

  Widget _buildProfileUserName(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [   
        UIHelpers.costumTitle(Translations.get('settings.username', currentLang), textColor),
        const SizedBox(height: 5),
        TextField(
          controller: _userNameController,
          readOnly: true,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            prefixIcon: Icon(Icons.person_outline, color: iconColor),
          ),
        ),
      ]
    );
  }

  Widget _buildProfileFullName(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('settings.fullName', currentLang), textColor),
        const SizedBox(height: 5),
        TextField(
          controller: _fullNameController,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            prefixIcon: Icon(Icons.person_outline, color: iconColor),
          ),
        ),
      ]
    );
  }

  Widget _buildProfileEmail(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('auth.email', currentLang), textColor),
        const SizedBox(height: 5),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: textColor),
          decoration: UIHelpers.customInputDecorationTextField(
            inputFillColor: inputFillColor,
            borderColor: borderColor,
            hintColor: hintColor,
            prefixIcon: Icon(Icons.email_outlined, color: iconColor),
          ),    
        ),
      ]
    );
  }

  Widget _buildProfileAvatarColor(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(Translations.get('settings.avatarColor', currentLang), textColor),
        const SizedBox(height: 5),
        Row(
          children: [
            GestureDetector(
              onTap: _showColorPickerDialog,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: UIHelpers.hexToColor(_colorAvatarController.text),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: const Icon(Icons.colorize, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _colorAvatarController,
                style: TextStyle(color: textColor),
                decoration: UIHelpers.customInputDecorationTextField(
                  inputFillColor: inputFillColor,
                  borderColor: borderColor,
                  hintColor: hintColor,
                  prefixIcon: Icon(Icons.palette_outlined, color: iconColor),
                ),
              ),
            ),
            if(widget.userData?['capitalLetters'] != null)...{
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 22,
                backgroundColor: UIHelpers.hexToColor(_colorAvatarController.text),
                child: Text(
                  "${widget.userData?['capitalLetters']}",
                  style: TextStyle(color: Colors.white)
                ),
              ),
            },
          ]
        ),
        const SizedBox(height: 6),
        UIHelpers.costumSubtitle(Translations.get('settings.avatarColorHint', currentLang), textColor),
      ]
    );
  }

  Widget _buildProfileBottom(){
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (){
          setState(() {
            _isLoading = true;
          });
          _saveProfilEdit();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D5AF0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          Translations.get('settings.saveChanges', currentLang),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );       
  }

}