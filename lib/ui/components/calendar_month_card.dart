import 'package:flutter/material.dart';
import 'package:reaxit/ui/components/calendar_event_card.dart';

import 'calendar_day_card.dart';

class CalendarMonthCard extends StatelessWidget {
  final String _month;
  final List<CalendarDayCard> _dayCards;

  CalendarMonthCard(this._month, this._dayCards);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(this._month, style: TextStyle(fontSize: 20)),
          Column(
            children: this._dayCards,
          )
        ],
      )
    );
  }
}