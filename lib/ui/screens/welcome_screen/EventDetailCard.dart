import 'package:flutter/material.dart';
import 'package:reaxit/ui/components/cardSection/CardSection.dart';

class EventDetailCard extends StatelessWidget {
  final String _title;
  final String _start;
  final String _end;
  final String _location;
  final String _description;
  final bool registered;

  EventDetailCard(this._title, this._start, this._end, this._location, this._description, this.registered);

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(_title),
                        Text(_start + ' - ' + _end + ' | ' + _location, style: TextStyle(color: Colors.grey))
                      ]),
                    Container(

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FlatButton(
                  textColor: Colors.grey,
                  color: Colors.white,
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