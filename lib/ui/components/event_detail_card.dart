import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/ui/components/card_section.dart';
import 'package:reaxit/ui/screens/event_screen.dart';

class EventDetailCard extends StatelessWidget {
  final Event _event;

  EventDetailCard(this._event);

  @override
  Widget build(BuildContext context) {
    String start = DateFormat('HH:mm').format(_event.start);
    String end = DateFormat('HH:mm').format(_event.end);
    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_event.title),
              subtitle: Text("$start - $end | ${_event.location}"),
              trailing: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _event.registered ? Color(0xFFE62272) : Colors.grey,
                ),
              ),
            ),
            Divider(),
            Text(_event.description),
            Divider(),
            ElevatedButton(
              child: Text('MORE INFO'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventScreen(_event.pk),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
