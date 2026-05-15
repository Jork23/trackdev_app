import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:trackdev_app/main.dart';

class NotificationService {

  final _firebaseMessaging = FirebaseMessaging.instance;
  static const _storage = FlutterSecureStorage();

  initFCM() async{
    await _firebaseMessaging.requestPermission();

    final fcmToken = await _firebaseMessaging.getToken();
    //print('FCM TOKEN: $fcmToken');

    if (fcmToken != null) {
      await uploadTokenToServer(fcmToken);
    }

    
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
    final data = message.data;
    final String? type = data['type'];
    final String? taskId = data['taskId'];

    if ((type == 'comment' || type == 'task_done') && taskId != null) {
      String? token = await _storage.read(key: 'auth_token');

      final url = Uri.parse('https://trackdev.org/api/tasks/$taskId');
      try {
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          final Map<String, dynamic> task = jsonDecode(response.body);
          
          navigatorKey.currentContext?.push('/task-from-notification', extra: task);
        }
      }
      catch (e){
        debugPrint("Error: $e");
      }
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message){
    //print('Message: ${message.notification?.title}');
  });
  }

  Future<void> uploadTokenToServer(String fcmToken) async {
    try {
      String? authToken = await _storage.read(key: 'auth_token');

      if (authToken == null) {
        return;
      }

      final deviceId = await _getDeviceId();
      final platform = Platform.isAndroid ? 'ANDROID' : 'IOS';

      final url = Uri.parse('https://trackdev.org/api/users/me/push-tokens');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': fcmToken,
          'platform': platform,
          'deviceId': deviceId,
        }),
      );

      if(response.statusCode == 200 || response.statusCode == 201){
        debugPrint('Servidor actualitzat: Token registrat correctament.');
      } 
      else{
        debugPrint('Error servidor (${response.statusCode}): ${response.body}');
      }
    } 
    catch (e){
      debugPrint("Error: $e");
    }
  }

  Future<String> _getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid){
      var androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } 
    else if (Platform.isIOS){
      var iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    }
    return 'unknown_device';
  }
}


