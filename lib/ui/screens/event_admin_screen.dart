import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/user_registration.dart';
import 'package:reaxit/providers/api_service.dart';
import 'package:reaxit/providers/events_provider.dart';
import 'package:reaxit/ui/components/network_search_delegate.dart';
import 'package:reaxit/ui/components/network_wrapper.dart';

class EventAdminScreen extends StatefulWidget {
  final int pk;
  final Event event;

  EventAdminScreen(this.pk, [this.event]);

  @override
  _EventAdminScreenState createState() => _EventAdminScreenState();
}

class _EventAdminScreenState extends State<EventAdminScreen> {
  Future<List<UserRegistration>> _registrationListFuture;

  @override
  didChangeDependencies() {
    _registrationListFuture =
        Provider.of<EventsProvider>(context).getEventRegistrations(widget.pk);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: filter/other FAB?
      appBar: AppBar(
        title: Text("Registrations"),
        // TODO: search
      ),
      body: Center(
        child: Text("Event admin"),
      ),
    );
  }
}

class _RegistrationTile extends StatelessWidget {
  final UserRegistration registration;
  const _RegistrationTile(this.registration);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          title: Text(registration.name),
          // TODO: trailing actions
        ),
        Divider(),
      ],
    );
  }
}
