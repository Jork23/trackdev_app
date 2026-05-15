import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/theme.dart';
import '../../utils/ui_helpers.dart';


class NotificationsPage extends StatefulWidget {

  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with ThemePage {

  static const _storage = FlutterSecureStorage();

  final Map<String, Map<String, String>> _localTranslations = {
    'ca': {
      'title': 'Notificacions',
      'subtitle': 'Gestiona les teves preferències de notificació',
      'comments': 'Comentaris',
      'commentsDescription': 'Rep notificacions quan algú comenti les teves tasques',
      'pointsReview': 'Revisió de punts',
      'pointsReviewDescription': 'Rep notificacions quan es revisin els punts de les teves tasques',
      'teamActivity': 'Activitat de l\'equip',
      'teamActivityDescription': 'Rep notificacions sobre l\'activitat general de l\'equip',
      'enabled': 'Activada',
      'disabled': 'Desactivada',
      'success': 'actualitzat correctament',
    },
    'es': {
      'title': 'Notificaciones',
      'subtitle': 'Gestiona tus preferencias de notificación',
      'comments': 'Comentarios',
      'commentsDescription': 'Recibe notificaciones cuando alguien comente tus tareas',
      'pointsReview': 'Revisión de puntos',
      'pointsReviewDescription': 'Recibe notificaciones cuando se revisen los puntos de tus tareas',
      'teamActivity': 'Actividad del equipo',
      'teamActivityDescription': 'Recibe notificaciones sobre la actividad general del equipo',
      'enabled': 'Activada',
      'disabled': 'Desactivada',
      'success': 'actualizado correctamente',
    },
    'en': {
      'title': 'Notifications',
      'subtitle': 'Manage your notification preferences',
      'comments': 'Comments',
      'commentsDescription': 'Receive notifications when someone comments on your tasks',
      'pointsReview': 'Points review',
      'pointsReviewDescription': 'Receive notifications when your task points are reviewed',
      'teamActivity': 'Team activity',
      'teamActivityDescription': 'Receive notifications about general team activity',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'success': 'updated successfully',
    },
  };

  String _getMsg(String key) {
    return _localTranslations[currentLang]?[key] ?? key;
  }

  bool _isLoading = true;
  String _message = '';
  bool _isSuccess = false;

  final Map<String, bool> _notifications = {
    'notifyComments': true,
    'notifyPointsReview': true,
    'notifyTeamActivity': true,
  };

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {

    String? token = await _storage.read(key: 'auth_token');
    final url = Uri.parse('https://trackdev.org/api/users/me/notification-preferences');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          for (final key in _notifications.keys) {
            _notifications[key] = data[key] as bool? ?? true;
          }
        });
      }
    }
    catch (e) {
      debugPrint("Error: $e");
    }
    finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotificationPreference(String key, bool value) async {

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _message = '';
    });

    String? token = await _storage.read(key: 'auth_token');
    final url = Uri.parse('https://trackdev.org/api/users/me/notification-preferences');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({key: value}),
      );

      if (!mounted) return;

      setState(() {
        if(response.statusCode == 200 || response.statusCode == 204){
          _message = _getMsg('success');
          _isSuccess = true;
        } 
        else{
          _message = 'Error: ${response.statusCode}';
          _isSuccess = false;
        }
      });
    } 
    catch (e){
      if (!mounted) return;
      setState(() {
        _message = ("Error: $e");
        _isSuccess = false;
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
        toolbarHeight: 100,
        centerTitle: true,
        title: UIHelpers.costumAppBar(
          dividerColor: dividerColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          title: _getMsg('title'),
          subtitile: _getMsg('subtitle'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            _buildNotificationSwitch(
              titleKey: 'comments',
              descriptionKey: 'commentsDescription',
              icon: Icons.chat_bubble_outline,
              apiKey: 'notifyComments',
            ),
            const SizedBox(height: 20),
            _buildNotificationSwitch(
              titleKey: 'pointsReview',
              descriptionKey: 'pointsReviewDescription',
              icon: Icons.star_outline,
              apiKey: 'notifyPointsReview',
            ),
            const SizedBox(height: 20),
            _buildNotificationSwitch(
              titleKey: 'teamActivity',
              descriptionKey: 'teamActivityDescription',
              icon: Icons.group_outlined,
              apiKey: 'notifyTeamActivity',
            ),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              UIHelpers.costumMessage(_isSuccess, _message),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String titleKey,
    required String descriptionKey,
    required IconData icon,
    required String apiKey,
  }) {
    final value = _notifications[apiKey] ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UIHelpers.costumTitle(_getMsg(titleKey), textColor),
        UIHelpers.costumSubtitle(_getMsg(descriptionKey), textColor),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: inputFillColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    value ? _getMsg('enabled') : _getMsg('disabled'),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              Switch(
                value: value,
                activeThumbColor: const Color(0xFF2D5AF0),
                activeTrackColor: const Color(0xFF2D5AF0),
                thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Icon(Icons.notifications_active, color: Colors.white);
                  }
                  return const Icon(Icons.notifications_off, color: Colors.grey);
                }),
                onChanged: (bool v) async {
                  setState((){
                    _notifications[apiKey] = v;
                  });
                  await _saveNotificationPreference(apiKey, v);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}