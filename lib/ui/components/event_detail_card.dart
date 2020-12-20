import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/ui/components/card_section.dart';
import 'package:reaxit/ui/screens/event_screen.dart';

class EventDetailCard extends StatelessWidget {
  final Event _event;

  EventDetailCard(Event event)
      : _event = event;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CardSection([
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_event.title),
                        Text(DateFormat('HH:mm').format(_event.start) + ' - ' + DateFormat('HH:mm').format(_event.start) + ' | ' + _event.location, style: TextStyle(color: Colors.grey))
                      ]),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _event.registered ? Color(0xFFE62272) : Colors.grey,
                        )
                      )
                    ]
                ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child:
                Text(_event.description, style: TextStyle(color: Colors.black87))
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FlatButton(
                  textColor: Colors.white,
                  color: Color(0xFFE62272),
                  child: Text('MORE INFO'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EventScreen(_event.pk)));
                  },
                ),
            ]
            )
          ],
        )
      ])
    );
  }
}