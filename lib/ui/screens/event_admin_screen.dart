import 'package:flutter/material.dart';

class EventAdminScreen extends StatefulWidget {
  final int eventPk;

  const EventAdminScreen({Key? key, required this.eventPk}) : super(key: key);

  @override
  _EventAdminScreenState createState() => _EventAdminScreenState();
}

class _EventAdminScreenState extends State<EventAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('event admin ${widget.eventPk}'),
      ),
    );
  }
}
