import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/api_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/link.dart';

String deviceRegistrationIdPreferenceName = 'deviceRegistrationId';

/// Request pushnotifications permissions and register a FCM token.
///
/// Return whether pushnotifications have been set up successfully.
Future<bool> registerPushNotifications(ApiRepository api) async {
  final settings = await FirebaseMessaging.instance.requestPermission(
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

  final token = await FirebaseMessaging.instance.getToken();
  if (token == null) return false;
  return await registerPushNotificationsToken(api, token);
}

/// Register a Firebase Cloud Messaging token to the api, and store it.
///
/// Return whether the token has been registered successfully.
Future<bool> registerPushNotificationsToken(
  ApiRepository api,
  String token,
) async {
  final prefs = await SharedPreferences.getInstance();
  final deviceRegistrationId = prefs.getInt(deviceRegistrationIdPreferenceName);
  if (deviceRegistrationId != null) {
    // We have already registered a deviceRegistrationId.
    try {
      await api.getDevice(id: deviceRegistrationId);
      return true;
    } on ApiException {
      // The device token is invalid.
      await prefs.remove(deviceRegistrationIdPreferenceName);
      try {
        var setting = await api.registerDevice(
          token: token,
          type: Platform.isIOS ? 'ios' : 'android',
          active: true,
        );
        await prefs.setInt(deviceRegistrationIdPreferenceName, setting.pk);
        return true;
      } on ApiException {
        return false;
      }
    }
  } else {
    // We must always register the device if there is no `deviceRegistrationId`.
    try {
      var setting = await api.registerDevice(
        token: token,
        type: Platform.isIOS ? 'ios' : 'android',
        active: true,
      );
      await prefs.setInt(deviceRegistrationIdPreferenceName, setting.pk);
      return true;
    } on ApiException {
      return false;
    }
  }
}

class PushNotificationDialog extends StatelessWidget {
  final RemoteMessage message;
  PushNotificationDialog(this.message) : super(key: ObjectKey(message));

  @override
  Widget build(BuildContext context) {
    Uri? uri;
    if (message.data.containsKey('url') && message.data['url'] is String) {
      uri = Uri.tryParse(message.data['url'] as String);
    }

    return AlertDialog(
      title: Text(message.notification!.title!),
      content: Text(
        message.notification!.body!,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
        if (uri != null)
          Link(
            uri: uri,
            builder: (context, followLink) => OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                followLink?.call();
              },
              child: const Text('OPEN'),
            ),
          ),
      ],
    );
  }
}
