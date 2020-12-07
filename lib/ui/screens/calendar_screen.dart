
import 'package:flutter/material.dart';
import 'package:reaxit/ui/components/calendar_month_card.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/ui/components/calendar_day_card.dart';
import 'package:reaxit/ui/components/calendar_event_card.dart';

class CalendarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar'),),
      drawer: MenuDrawer(),
      body: Container(
          color: const Color(0xffFAFAFA),
          padding: EdgeInsets.all(10),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CalendarMonthCard("december", [CalendarDayCard("ma", 7, [CalendarEventCard("Titel", "20:00", "21:00", "Nijmegen", true), CalendarEventCard("Titel", "20:00", "21:00", "Nijmegen", false)])]),
            ]
          )
        )
      );
  }
}