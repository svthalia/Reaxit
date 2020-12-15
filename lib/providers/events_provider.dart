import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/auth_provider.dart';

class EventsProvider extends ApiService{
  List<Event> _eventList = [];

  EventsProvider(AuthProvider authProvider) : super(authProvider);

  List<Event> get eventList => _eventList;

  Future<void> load () async {
    if (authProvider.status == Status.SIGNED_IN) {
      status = ApiStatus.LOADING;
      notifyListeners();

      try {
        Response response = await authProvider.helper.get('https://staging.thalia.nu/api/v1/events/');
        if (response.statusCode == 200) {
          List<dynamic> jsonEvents = jsonDecode(response.body)['results'];
          _eventList = jsonEvents.map((jsonEvent) => Event.fromJson(jsonEvent)).toList();
          _eventList.sort((event1, event2) => (event1.start.difference(event2.start)).inMinutes);
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

  Future<Event> getEvent(int pk) async {
    if (authProvider.status == Status.SIGNED_IN) {
      authProvider.helper.get('https://staging.thalia.nu/api/v1/events/1').then((response) {
        if (response.statusCode == 200) {
          return Event.fromJson(jsonDecode(response.body));
        }
      });
      return null;
    }
    else {
      return null;
    }
  }
}