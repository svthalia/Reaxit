import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/providers/events_provider.dart';

class EventScreen extends StatefulWidget {

  final int pk;

  EventScreen(this.pk);

  @override
  State<StatefulWidget> createState() => EventScreenState();
}

class EventScreenState extends State<EventScreen> {

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
    return Scaffold(
        appBar: AppBar(
          title: Text('Event'),
        ),
        drawer: MenuDrawer(),
        body: Container(

        )
    );
  }
}
