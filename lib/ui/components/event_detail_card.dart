import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/ui/components/card_section.dart';

class EventDetailCard extends StatelessWidget {
  final String _title;
  final String _start;
  final String _end;
  final String _location;
  final String _description;
  final bool _registered;

  EventDetailCard(Event event)
      : _title = event.title,
        _start = DateFormat('HH:mm').format(event.start),
        _end = DateFormat('HH:mm').format(event.end),
        _location = event.location,
        _description = event.description,
        _registered = event.registered;

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
                        Text(_title),
                        Text(_start + ' - ' + _end + ' | ' + _location, style: TextStyle(color: Colors.grey))
                      ]),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: this._registered ? Color(0xFFE62272) : Colors.grey,
                        )
                      )
                    ]
                ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child:
                Text(_description, style: TextStyle(color: Colors.black87))
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FlatButton(
                  textColor: Colors.white,
                  color: Color(0xFFE62272),
                  child: Text('MEER INFO'),
                  onPressed: () {},
                ),
            ]
            )
          ],
        )
      ])
    );
  }
}