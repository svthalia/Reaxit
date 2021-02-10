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
