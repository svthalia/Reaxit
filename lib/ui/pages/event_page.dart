import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  final int eventPk;

  const EventPage({Key? key, @PathParam('pk') required this.eventPk})
      : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('event ${widget.eventPk}'),
      ),
    );
  }
}
