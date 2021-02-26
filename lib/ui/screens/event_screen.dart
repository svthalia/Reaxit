import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/user_registration.dart';
import 'package:reaxit/providers/events_provider.dart';
import 'package:reaxit/ui/screens/event_admin_screen.dart';
import 'package:reaxit/ui/screens/event_registration_screen.dart';
import 'package:reaxit/ui/components/member_card.dart';
import 'package:reaxit/ui/screens/pizza_screen.dart';
import 'package:url_launcher/link.dart';

class EventScreen extends StatefulWidget {
  final int pk;

  EventScreen(this.pk);

  @override
  State<StatefulWidget> createState() => EventScreenState();
}

class EventScreenState extends State<EventScreen> {
  Future<Event> _event;
  Future<List<Registration>> _registrations;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _event = Provider.of<EventsProvider>(context).getEvent(widget.pk);
    _event.then(
      (event) {
        if (event?.registrationRequired() ?? false) {
          _registrations = Provider.of<EventsProvider>(context)
              .getEventRegistrations(event.pk);
        }
      },
    );
    super.didChangeDependencies();
  }

  Widget _makeEventProperties(BuildContext context, Event event) {
    List<TableRow> infoItems = [
      TableRow(children: [
        TableCell(
          child: Text(
            "From: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TableCell(
            child: Text(DateFormat('d MMM yyyy, HH:mm').format(event.start)))
      ]),
      TableRow(children: [
        TableCell(
          child: Text(
            "Until: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TableCell(
            child: Text(DateFormat('d MMM yyyy, HH:mm').format(event.end)))
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
      infoItems.add(TableRow(children: [
        TableCell(
          child: Text(
            "Registration deadline: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TableCell(child: Text(event.registrationEnd.toString()))
      ]));
      infoItems.add(TableRow(children: [
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
      infoItems.add(TableRow(children: [
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
        if (event.isLateCancellation()) {
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
        infoItems.add(TableRow(children: [
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

  static Widget _makeRegistrationText(BuildContext context, Event event) {
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
      text = 'Registration is not allowed anymore, as you '
          'cancelled your registration after the deadline.';
    }

    if (event.afterCancelDeadline() && !event.isLateCancellation()) {
      if (text.length > 0) {
        text += ' ';
      }
      text +=
          "Cancellation isn't possible anymore without having to pay the full "
          "costs of €${event.fine}. Also note that you will be unable to re-register.";
    }

    if (text.isNotEmpty) {
      return Text(text);
    } else {
      return SizedBox(height: 0);
    }
  }

  static Widget _makeEventActions(BuildContext context, Event event) {
    if (event.registrationAllowedAndPossible()) {
      if (event.userRegistration == null ||
          event.userRegistration.isCancelled) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Link(
              uri: Uri.parse(
                  "https://staging.thalia.nu/event-registration-terms/"),
              builder: (context, followLink) => RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "By registering, you confirm that you have read the ",
                      style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
                    ),
                    TextSpan(
                      text: "terms and conditions",
                      recognizer: TapGestureRecognizer()..onTap = followLink,
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                    TextSpan(
                      text:
                          ", that you understand them and that you agree to be bound by them.",
                      style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              child: Text(
                event.maxParticipants != null &&
                        event.maxParticipants <= event.numParticipants
                    ? 'PUT ME ON THE WAITING LIST'
                    : 'REGISTER',
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventRegistrationScreen(event)),
                );
              },
            ),
          ],
        );
      }
      if (event.userRegistration != null &&
          !event.userRegistration.isCancelled &&
          event.registrationRequired() &&
          event.registrationStarted()) {
        if (event.registrationStarted() &&
            event.userRegistration != null &&
            !event.userRegistration.isCancelled &&
            event.hasFields) {
          return Column(
            children: [
              ElevatedButton(
                child: Text('UPDATE REGISTRATION'),
                onPressed: () {
                  // TODO: Go to update registration view
                },
              ),
              ElevatedButton(
                child: Text('CANCEL REGISTRATION'),
                onPressed: () {
                  // TODO: Cancel registration
                },
              )
            ],
          );
        } else {
          return Column(
            children: [
              ElevatedButton(
                child: Text('CANCEL REGISTRATION'),
                onPressed: () {},
              ),
            ],
          );
        }
      }
    }
    return Container();
  }

  static Widget _makePizzaAction(BuildContext context, Event event) {
    return ElevatedButton.icon(
      icon: Icon(Icons.local_pizza),
      label: Text("PIZZA"),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PizzaScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Event>(
      future: _event,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Event event = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text('Event'),
              actions: [
                if (event.registrationRequired() && event.isAdmin ?? false)
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventAdminScreen(event.pk),
                        ),
                      );
                    },
                  ),
              ],
            ),
            body: Column(
              children: [
                Link(
                  uri: Uri.parse(
                      "https://maps.${Platform.isIOS ? 'apple' : 'google'}.com"
                      "/maps?daddr=${Uri.encodeComponent(event.mapLocation)}"),
                  builder: (context, followLink) => GestureDetector(
                    onTap: followLink,
                    child: Center(
                      child: FadeInImage.assetNetwork(
                        // TODO: Replace placeholder
                        placeholder: 'assets/img/huygens.jpg',
                        image: event.googleMapsUrl,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    top: 10,
                    right: 20,
                    bottom: 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      _makeEventProperties(context, event),
                      SizedBox(height: 15),
                      _makeEventActions(context, event),
                      _makeRegistrationText(context, event),
                      if (event.isPizzaEvent) _makePizzaAction(context, event),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Html(data: event.description),
                ),
                if (event.registrationRequired() &&
                    event.numParticipants == 0) ...[
                  Divider(),
                  Text("No registrations yet."),
                ],
                if (event.registrationRequired() &&
                    event.numParticipants > 0) ...[
                  Divider(),
                  FutureBuilder(
                    future: _registrations,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        // TODO: transform to grid of registrations,
                        // probably by changing the whole screen to a SliverGrid
                        // return GridView.builder(
                        //   gridDelegate:
                        //       SliverGridDelegateWithFixedCrossAxisCount(
                        //     crossAxisSpacing: 10,
                        //     mainAxisSpacing: 10,
                        //     crossAxisCount: 3,
                        //   ),
                        //   itemCount: snapshot.data.length,
                        //   physics: const AlwaysScrollableScrollPhysics(),
                        //   padding: const EdgeInsets.all(20),
                        //   itemBuilder: (context, index) =>
                        //       MemberCard(snapshot.data[index]),
                        // );
                        return Text("TODO");
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "An error occurred while fetching registrations.",
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ]
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Event'),
            ),
            body: Center(
              child: Text("An error occurred while fetching event data."),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('Event'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
