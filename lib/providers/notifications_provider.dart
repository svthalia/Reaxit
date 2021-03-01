import 'dart:convert';

import 'package:reaxit/models/setting.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_provider.dart';

class NotificationsProvider extends ApiService {
  Map<Setting, bool> _settings = {};
  static const String _prefix = "notifications_";
  static const bool _defaultSettingValue = true;

  NotificationsProvider(AuthProvider authProvider) : super(authProvider);

  @override
  Future<void> loadImplementation() async {
    List<Setting> settings = await _getSettings();
    for (int i = 0; i < settings.length; i++) {
      _settings[settings[i]] = await _getStoredSetting(settings[i]);
    }
  }

  List<Setting> get settings => _settings.keys.toList();

  Future<List<Setting>> _getSettings() async {
    String response = await this.get("/devices/categories/");
    List<dynamic> jsonSettings = jsonDecode(response);
    return jsonSettings
        .map((jsonEvent) => Setting.fromJson(jsonEvent))
        .toList();
  }

  Future<bool> _getStoredSetting(Setting setting) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool value = await prefs.getBool(_prefix + setting.key);
    return value ?? _defaultSettingValue;
  }

  Future<void> _setStoredSetting(Setting setting, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefix + setting.key, value);
  }

  bool getNotificatinoSetting(Setting setting) {
    return _settings.containsKey(setting) ? _settings[setting] : null;
  }

  Future<void> setNotificationSetting(Setting setting, bool value) async {
    _settings[setting] = value;
    _setStoredSetting(setting, value);
    notifyListeners();
  }
}
