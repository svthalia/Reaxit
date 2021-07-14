import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reaxit/api_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

String deviceRegistrationIdPreferenceName = 'deviceRegistrationId';

Future<bool> register(api) async {
  var settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus != AuthorizationStatus.authorized) {
    return false;
  }

  var token = await FirebaseMessaging.instance.getToken();
  if (token == null) {
    return false;
  }
  return await registerToken(token, api);
}

Future<bool> registerToken(String token, ApiRepository api) async {
  var prefs = await SharedPreferences.getInstance();
  var deviceRegistrationId = prefs.getInt(deviceRegistrationIdPreferenceName);
  if (deviceRegistrationId != null) {
    // We have already registered a deviceRegistrationId
    try {
      await api.getDevice(id: deviceRegistrationId);
      return true;
    } on ApiException {
      // The device token is invalid
      await prefs.remove(deviceRegistrationIdPreferenceName);
      try {
        var setting = await api.registerDevice(
            token, Platform.isIOS ? 'ios' : 'android', true);
        await prefs.setInt(deviceRegistrationIdPreferenceName, setting.pk);
        return true;
      } on ApiException {
        return false;
      }
    }
  } else {
    // We must always register this device if there is no deviceRegistrationId
    try {
      var setting = await api.registerDevice(
          token, Platform.isIOS ? 'ios' : 'android', true);
      await prefs.setInt(deviceRegistrationIdPreferenceName, setting.pk);
      return true;
    } on ApiException {
      return false;
    }
  }
}
