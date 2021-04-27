import 'package:flutter/material.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';

class EventAdminScreen extends StatefulWidget {
  final int pk;

  EventAdminScreen({required this.pk}) : super(key: ValueKey(pk));

  @override
  _EventAdminScreenState createState() => _EventAdminScreenState();
}

class _EventAdminScreenState extends State<EventAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(),
      body: Center(
        child: Text('event admin ${widget.pk}'),
      ),
    );
  }
}
