

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> init() async {
    print("Init");
    if (!_initialized) {
      print("getting permission");
      var settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      _initialized = true;
    }
  }

  Future<String?> getToken() async {
    print("Get token");
    return await _firebaseMessaging.getToken();
  }
}