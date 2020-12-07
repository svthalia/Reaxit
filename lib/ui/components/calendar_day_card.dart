import 'package:flutter/material.dart';
import 'package:reaxit/ui/components/calendar_event_card.dart';

class CalendarDayCard extends StatelessWidget {
  final String _day;
  final int _day_number;
  final List<CalendarEventCard> _event_cards;

  CalendarDayCard(this._day, this._day_number, this._event_cards);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    this._day_number.toString(),
                    style: TextStyle(fontSize: 30),),
                Text(this._day),
              ]
            )
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _event_cards,
            )
          )
        ]
      ),
    );
  }
}