import 'package:flutter/material.dart';

class EventScreen extends StatefulWidget {
  final int eventPk;

  const EventScreen({Key? key, required this.eventPk}) : super(key: key);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
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
