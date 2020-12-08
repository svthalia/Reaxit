import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/providers/events_provider.dart';
import 'package:reaxit/ui/components/calendar_month_card.dart';
import 'package:reaxit/ui/components/menu_drawer.dart';
import 'package:reaxit/ui/components/calendar_day_card.dart';
import 'package:reaxit/ui/components/calendar_event_card.dart';

class CalendarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  Map<String, List<Event>> groupByMonth(List<Event> eventList) {
    return groupBy(eventList, (event) {
      String month = DateFormat(DateFormat.MONTH).format(event.start);
      if (event.start.year == DateTime.now().year)
        return month;
      else
        return '$month - ${event.start.year}';
    });
  }

  Map<DateTime, List<Event>> groupByDate(List<Event> eventList) {
    return groupBy(eventList, (event) => DateTime(event.start.year, event.start.month, event.start.day));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Calendar'),
        ),
        drawer: MenuDrawer(),
        body: Consumer<EventsProvider>(builder: (context, events, child) {
          if (events.loading)
            return Center(child: CircularProgressIndicator());
          else
            return RefreshIndicator(
              onRefresh: () => events.loadEvents(),
              child: SingleChildScrollView(
                child: Container(
                    color: const Color(0xffFAFAFA),
                    padding: EdgeInsets.all(10),
                    child: Consumer<EventsProvider>(builder: (context, events, child) {
                      if (events.loading)
                        return Center(child: CircularProgressIndicator());
                      else {
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: groupByMonth(events.eventList)
                                .entries.map((monthGroup) => CalendarMonthCard(
                                    monthGroup.key,
                                    groupByDate(monthGroup.value)
                                        .entries.map((dayGroup) => CalendarDayCard(DateFormat(DateFormat.ABBR_WEEKDAY).format(dayGroup.key), dayGroup.key.day,
                                            dayGroup.value.map((event) => CalendarEventCard(event)).toList()))
                                        .toList()))
                                .toList());
                      }
                    })),
              ),
            );
        }));
  }
}
