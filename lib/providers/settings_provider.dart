import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:reaxit/models/setting.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class SettingsProvider extends ApiService {
  List<Setting> _settingsList = [];

  SettingsProvider(AuthProvider authProvider) : super(authProvider);

  List<Setting> get settingsList => _settingsList;

  Future<void> load() async {
    if (authProvider.status == AuthStatus.SIGNED_IN) {
      status = ApiStatus.LOADING;
      notifyListeners();

      try {
        Response response = await authProvider.helper
            .get('https://staging.thalia.nu/api/v1/devices/categories/');
        if (response.statusCode == 200) {
          List<dynamic> jsonEvents = jsonDecode(response.body)['results'];
          print(response.body);
          this._settingsList =
              jsonEvents.map((jsonEvent) => Setting.fromJson(jsonEvent)).toList();
          status = ApiStatus.DONE;
        } else if (response.statusCode == 403)
          status = ApiStatus.NOT_AUTHENTICATED;
        else
          status = ApiStatus.UNKNOWN_ERROR;
      } on SocketException catch (_) {
        status = ApiStatus.NO_INTERNET;
      } catch (_) {
        status = ApiStatus.UNKNOWN_ERROR;
      }

      notifyListeners();
    }
  }
}
