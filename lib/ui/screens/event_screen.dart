import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/event.dart';
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

  Widget _registration_section(Event event) {
    if (event.registered) {
      return FlatButton(
        textColor: Colors.white,
        color: Color(0xFFE62272),
        child: Text('Deregister'),
        onPressed: () {},
      );
    }
    else if (event.registrationAllowed) {
      return FlatButton(
        textColor: Colors.white,
        color: Color(0xFFE62272),
        child: Text('Register'),
        onPressed: () {},
      );
    }
    else {
      return Text("No registration required.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Event'),
        ),
        body: FutureBuilder<Event>(
          future: _event,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Event event = snapshot.data;
              return Container(
                child: Column(
                  children: [
                    Center(child: Text("Map component placeholder")),
                    Column(
                      children: [
                        Text(event.title),
                        Column(
                          children: [
                            Row(
                              children: [
                                Text("From: "),
                                Text(event.start.toString())
                              ]
                            ),
                            Row(
                                children: [
                                  Text("Until: "),
                                  Text(event.end.toString())
                                ]
                            ),
                            Row(
                                children: [
                                  Text("Location: "),
                                  Text(event.location)
                                ]
                            ),
                            Row(
                                children: [
                                  Text("Price: "),
                                  Text(event.price)
                                ]
                            ),
                          ],
                        ),

                      ],
                    ),
                  ]
                )
              );
            }
            else if (snapshot.hasError) {
              return Center(child: Text("An error occurred while fetching event data."));
            }
            else {
              return Material(
                color: Color(0xFFE62272),
                child: Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),),
                ),
              );
            }
          }
        )
    );
  }
}
