
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/providers/events_provider.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/ui/components/event_detail_card.dart';
import '../components/event_detail_card.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome'),),
      drawer: MenuDrawer(),
      body: Container(
          color: const Color(0xffFAFAFA),
          child: Consumer<EventsProvider>(
            builder: (context, events, child) => Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: events.eventList.map((event) => EventDetailCard(
                    event.title,
                    "${event.start.hour.toString()}:${event.start.minute.toString()}",
                    "${event.end.hour.toString()}:${event.end.minute.toString()}",
                    event.location,
                    event.description,
                    event.registered
                )
                ).take(3).toList()
            )
          )
        )
      );
  }
}