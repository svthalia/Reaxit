import 'dart:convert';

import 'package:reaxit/models/setting.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class SettingsProvider extends ApiService {
  List<Setting> _settingsList = [];

  SettingsProvider(AuthProvider authProvider) : super(authProvider);

  List<Setting> get settingsList => _settingsList;

  @override
  Future<void> loadImplementation() async {
    _settingsList = await _getSettings();
  }

  Future<List<Setting>> _getSettings() async {
    String response = await this.get("/devices/categories/");
    print(response);
    List<dynamic> jsonSettings = jsonDecode(response);
    return jsonSettings
        .map((jsonEvent) => Setting.fromJson(jsonEvent))
        .toList();
  }
}
