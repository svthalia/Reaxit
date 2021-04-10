import 'package:flutter/material.dart';
import 'package:reaxit/blocs/list_event.dart';

class EventScreen extends StatefulWidget {
  final int pk;
  final ListEvent? event;

  EventScreen({required this.pk, this.event}) : super(key: ValueKey(pk));

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('event ${widget.pk}'),
      ),
    );
  }
}
