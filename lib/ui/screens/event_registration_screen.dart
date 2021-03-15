import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/providers/events_provider.dart';

class EventRegistrationScreen extends StatefulWidget {
  final Event event;

  EventRegistrationScreen(this.event);

  @override
  State<StatefulWidget> createState() => EventRegistrationScreenState();
}

class EventRegistrationScreenState extends State<EventRegistrationScreen> {
  Event _event;

  @override
  void initState() {
    super.initState();
    this._event = widget.event;
  }

  @override
  void didChangeDependencies() async {
    _event = await Provider.of<EventsProvider>(context, listen: false)
        .getEvent(widget.event.pk);
    if (_event == null) {
      // TODO: Event loading failed
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Container(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
