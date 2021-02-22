import 'dart:convert';

import 'package:reaxit/models/setting.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_provider.dart';

class NotificationsProvider extends ApiService {
  Map<Setting, bool> _settings = {};
  final String _PREFIX = "notifications_";
  final bool _DEFAULT_SETTING_VALUE = true;

  NotificationsProvider(AuthProvider authProvider) : super(authProvider);

  @override
  Future<void> loadImplementation() async {
    List<Setting> settings = await _getSettings();
    for (int i = 0; i < settings.length; i++) {
      _settings[settings[i]] = await this._getNotificationSetting(settings[i]);
    }
  }

  List<Setting> getSettingsList() {
    List<Setting> settings;
    _settings.forEach((k, v) => settings.add(v));
    return settings;
  }

  Future<List<Setting>> _getSettings() async {
    String response = await this.get("/devices/categories/");
    List<dynamic> jsonSettings = jsonDecode(response);
    return jsonSettings
        .map((jsonEvent) => Setting.fromJson(jsonEvent))
        .toList();
  }

  Future<bool> _getNotificationSetting(Setting setting) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool value = await prefs.getBool(this._PREFIX + setting.key);
    if (value == null) {
      return _DEFAULT_SETTING_VALUE;
    } else {
      return value;
    }
  }

  Future<void> _setNotificationSetting(Setting setting, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(this._PREFIX + setting.key, value);
  }

  Future<void> setNotificationSetting(Setting setting, bool value) async {
    _settings[setting] = value;
    this._setNotificationSetting(setting, value);
    notifyListeners();
  }
}
