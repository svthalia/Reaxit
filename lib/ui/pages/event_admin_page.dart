import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

class EventAdminPage extends StatefulWidget {
  final int eventPk;

  const EventAdminPage({Key? key, @PathParam('pk') required this.eventPk})
      : super(key: key);

  @override
  _EventAdminPageState createState() => _EventAdminPageState();
}

class _EventAdminPageState extends State<EventAdminPage> {
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
