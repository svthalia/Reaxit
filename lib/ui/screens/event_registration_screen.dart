
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/providers/events_provider.dart';

class EventRegistrationScreen extends StatefulWidget {
  final int pk;

  EventRegistrationScreen(this.pk);

  @override
  State<StatefulWidget> createState() => EventRegistrationScreenState();
}

class EventRegistrationScreenState extends State<EventRegistrationScreen> {
  Future<Event> _event;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _event = Provider.of<EventsProvider>(context).getEvent(widget.pk);
    if (_event == null) {
      // TODO: Event loading failed
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

  }
}
