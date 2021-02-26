import 'package:flutter/material.dart';
import 'package:reaxit/providers/events_provider.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/ui/components/event_detail_card.dart';
import 'package:reaxit/ui/components/network_wrapper.dart';
import '../components/event_detail_card.dart';
import 'calendar_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      drawer: MenuDrawer(),
      body: NetworkWrapper<EventsProvider>(
        builder: (context, events) => ListView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            children: new List<Widget>.from(events.eventList
                .map((event) => EventDetailCard(event))
                .take(3)
                .toList())
              ..addAll([
                Column(children: [
                  TextButton(
                    child: Text('SHOW THE ENTIRE AGENDA'),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarScreen()),
                    ),
                  )
                ])
              ])),
      ),
    );
  }
}
