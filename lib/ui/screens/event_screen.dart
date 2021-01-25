import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
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

  Widget eventProperties(Event event) {
    List<TableRow> infoItems = [
      TableRow(children: [
        TableCell(
          child: Text(
            "From: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TableCell(child: Text(DateFormat('d MMM yyyy, HH:mm').format(event.start)))
      ]),
      TableRow(children: [
        TableCell(
          child: Text(
            "Until: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TableCell(child: Text(DateFormat('d MMM yyyy, HH:mm').format(event.end)))
      ]),
      TableRow(children: [
        TableCell(
          child: Text(
            "Location: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TableCell(child: Text(event.location))
      ]),
      TableRow(children: [
        TableCell(
          child: Text(
            "Price: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TableCell(child: Text('€${event.price}'))
      ]),
    ];

    if (event.registrationRequired()) {
      infoItems.add(
          TableRow(children: [
            TableCell(
              child: Text(
                "Registration deadline: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TableCell(child: Text(event.registrationEnd.toString()))
          ]));
      infoItems.add(
          TableRow(children: [
            TableCell(
              child: Text(
                "Cancellation deadline: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TableCell(child: Text(event.cancelDeadline.toString()))
          ]));
      String participantText = '${event.numParticipants} registrations';
      if (event.maxParticipants != null) {
        participantText += ' (${event.maxParticipants} max)';
      }
      infoItems.add(
          TableRow(children: [
            TableCell(
              child: Text(
                "Number of registrations: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TableCell(child: Text(participantText))
          ]));
      if (event.userRegistration != null) {
        String registrationState;
        if (event.userRegistration.isLateCancellation) {
          registrationState =
          'Your registration is cancelled after the cancellation deadline';
        } else if (event.userRegistration.isCancelled) {
          registrationState = 'Your registration is cancelled';
        } else if (event.userRegistration.queuePosition == null) {
          registrationState = 'You are registered';
        } else if (event.userRegistration.queuePosition > 0) {
          registrationState =
          'Queue position ${event.userRegistration.queuePosition}';
        } else {
          registrationState = 'Your registration is cancelled';
        }
        infoItems.add(
            TableRow(children: [
              TableCell(
                child: Text("Registration status: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              TableCell(child: Text(registrationState))
            ]));
      }
    }

    return Table(
      children: infoItems.toList(),
    );
  }

  static Widget registrationText(Event event) {
    String text = "";

    if (!event.registrationRequired()) {
      if (event.noRegistrationMessage != null) {
        text = event.noRegistrationMessage;
      } else {
        text = "No registration required.";
      }
    } else if (!event.registrationStarted()) {
      text = "Registration will open ${event.registrationStart}";
    } else if (!event.registrationAllowedAndPossible()) {
      text = 'Registration is not possible anymore.';
    } else if (event.isLateCancellation()) {
      text =
          'Registration is not allowed anymore, as you cancelled your registration after the deadline.';
    }

    if (event.afterCancelDeadline() && !event.isLateCancellation()) {
      if (text.length > 0) {
        text += ' ';
      }
      text +=
          "Cancellation isn't possible anymore without having to pay the full costs of €${event.fine}. Also note that you will be unable to re-register.";
    }

    return Text(text);
  }

  static Widget eventActions(Event event) {
    if (event.registrationAllowedAndPossible()) {
      if (event.userRegistration == null ||
          event.userRegistration.isCancelled) {
        final String text = event.maxParticipants != null &&
                event.maxParticipants <= event.numParticipants
            ? 'Put me on the waiting list'
            : 'Register';
        return Column(children: [
          // TODO: Make terms and conditions clickable
          Text(
              "By registering, you confirm that you have read the terms and conditions, that you understand them and that you agree to be bound by them."),
          FlatButton(
            textColor: Colors.white,
            color: Color(0xFFE62272),
            child: Text(text),
            onPressed: () {
              // TODO: Register and go to register view
            },
          ),
        ]);
      }
      if (event.userRegistration != null &&
          !event.userRegistration.isCancelled &&
          event.registrationRequired() &&
          event.registrationStarted()) {
        if (event.registrationStarted() &&
            event.userRegistration != null &&
            !event.userRegistration.isCancelled &&
            event.hasFields) {
          return Column(children: [
            FlatButton(
              textColor: Colors.white,
              color: Color(0xFFE62272),
              child: Text('Update registration'),
              onPressed: () {
                // TODO: Go to update registration view
              },
            ),
            FlatButton(
                textColor: Colors.white,
                color: Color(0xFFE62272),
                child: Text('Cancel registration'),
                onPressed: () {
                  // TODO: Cancel registration
                })
          ]);
        } else {
          return Column(children: [
            FlatButton(
              textColor: Colors.white,
              color: Color(0xFFE62272),
              child: Text('Cancel registration'),
              onPressed: () {},
            ),
          ]);
        }
      }
    }
    return Container();
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
                    child: Column(children: [
                  Center(child: Text("Map component placeholder")),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, top: 10, right: 20, bottom: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                            margin: EdgeInsets.only(
                                left: 0, top: 0, right: 0, bottom: 10),
                            child: Text(event.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24))),
                        eventProperties(event),
                        SizedBox(height: 15,),
                        registrationText(event),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Html(data: event.description),
                  )
                ]));
              } else if (snapshot.hasError) {
                return Center(
                    child:
                        Text("An error occurred while fetching event data."));
              } else {
                return Material(
                  color: Color(0xFFE62272),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              }
            }));
  }
}
