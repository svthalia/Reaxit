import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/providers/auth_provider.dart';

class EventsProvider extends ChangeNotifier{
  AuthProvider _authProvider;
  List<Event> _eventList = [];

  List<Event> get eventList => _eventList;

  EventsProvider(this._authProvider) {
    loadEvents();
  }

  Future<void> loadEvents () async {
    if (_authProvider.status == Status.SIGNED_IN) {
      _authProvider.helper.get('https://staging.thalia.nu/api/v1/events/').then((response) {
        if (response.statusCode == 200) {
          List<dynamic> jsonEvents = jsonDecode(response.body)['results'];
          _eventList = jsonEvents.map((jsonEvent) => Event.fromJson(jsonEvent)).toList();
          _eventList.sort((event1, event2) => (event1.start.difference(event2.start)).inMinutes);
          notifyListeners();
        }
      });
    }
  }
}