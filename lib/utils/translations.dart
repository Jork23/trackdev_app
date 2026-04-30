import 'package:flutter/services.dart';
import 'dart:convert';

class Translations {
  static Map<String, Map<String, String>> _translations = {};
  static bool _loaded = false;

  static Future<void> init() async {
    if (_loaded) return;

    final langs = ['ca', 'es', 'en'];
    for (final lang in langs) {
      final jsonString = await rootBundle.loadString('lib/utils/$lang.json');
      final nested = jsonDecode(jsonString) as Map<String, dynamic>;
      _translations[lang] = _flatten(nested);
    }
    _loaded = true;
  }

  static Map<String, String> _flatten(Map<String, dynamic> map, [String prefix = '']) {
    final result = <String, String>{};
    map.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        result.addAll(_flatten(value, fullKey));
      } else {
        result[fullKey] = value.toString();
      }
    });
    return result;
  }

  static String get(String key, String lang) {
    return _translations[lang]?[key] ?? key;
  }
}