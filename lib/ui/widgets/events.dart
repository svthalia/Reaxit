import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/theme.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:url_launcher/url_launcher.dart';

/// CalendarViewDay holds events attached to a day
class CalendarViewDay {
  final DateTime day;
  final List<CalendarEvent> events;

  CalendarViewDay({required this.day, required List<CalendarEvent> events})
    : events = events.sortedBy((element) => element.start);
}

List<CalendarViewMonth> ensureMonthsContainsToday(
  List<CalendarViewMonth> events,
  DateTime now,
) {
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime thisMonth = DateTime(now.year, now.month);
  CalendarViewDay emptyDay = CalendarViewDay(day: today, events: []);
  for (var i = 0; i < events.length; i++) {
    if (events[i].month.isAfter(thisMonth)) {
      // The current month does not exist yet
      // Make a new month with only today
      events.insert(i, CalendarViewMonth(month: thisMonth, events: []));
      events[i].days.add(emptyDay);
      return events;
    }
    if (events[i].month == thisMonth) {
      events[i] = ensureMonthContainsDay(events[i], now.day);
      return events;
    }
  }
  // We did not find the current month, and there was no month after the current month
  // Add a new month to the end
  events.add(CalendarViewMonth(month: thisMonth, events: []));
  events.last.days.add(emptyDay);

  return events;
}

CalendarViewMonth ensureMonthContainsDay(CalendarViewMonth month, int day) {
  DateTime thisMonth = month.month;
  DateTime today = DateTime(thisMonth.year, thisMonth.month, day);

  CalendarViewDay emptyDay = CalendarViewDay(day: today, events: []);
  // Try to find the right day, or a day after
  for (var j = 0; j < month.days.length; j++) {
    if (month.days[j].day == today) {
      // There already exists a day for today in the calendar
      // Nothing to be done
      return month;
    }
    if (month.days[j].day.isAfter(today)) {
      // We did not find today, but there was is a day after today
      // Insert a new day
      month.days.insert(j, emptyDay);
      return month;
    }
  }
  // We did not find today, and there was no day after today
  // Add a new to to the end
  month.days.add(emptyDay);
  return month;
}

List<CalendarViewMonth> groupByMonth(List<CalendarEvent> eventList) =>
    groupBy<CalendarEvent, DateTime>(
          eventList,
          (event) => DateTime(event.start.year, event.start.month),
        ).entries
        .map(
          (entry) => CalendarViewMonth(month: entry.key, events: entry.value),
        )
        .toList();

/// CalendarViewMonth holds events attached to a month
class CalendarViewMonth {
  final DateTime month;
  final List<CalendarViewDay> days;

  CalendarViewMonth({required this.month, required List<CalendarEvent> events})
    : days = groupBy<CalendarEvent, DateTime>(
            events.sortedBy((element) => element.start),
            (event) =>
                DateTime(event.start.year, event.start.month, event.start.day),
          ).entries
          .map((entry) => CalendarViewDay(day: entry.key, events: entry.value))
          .sortedBy((element) => element.day);

  List<CalendarViewDay> byDay() => days;
}

class CalendarMonth extends StatelessWidget {
  final CalendarViewMonth events;
  final Key? todayKey;
  final Key? thisMonthKey;
  final DateTime now;

  static final monthFormatter = DateFormat('MMMM');
  static final monthYearFormatter = DateFormat('MMMM yyyy');

  const CalendarMonth({
    required this.events,
    this.todayKey,
    this.thisMonthKey,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime thisMonth = DateTime(now.year, now.month);
    return StickyHeader(
      header: Column(
        key: events.month == thisMonth ? thisMonthKey : null,
        children: [
          SizedBox(
            width: double.infinity,
            child: Material(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  events.month.year == now.year
                      ? monthFormatter
                          .format(events.month.toLocal())
                          .toUpperCase()
                      : monthYearFormatter
                          .format(events.month.toLocal())
                          .toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final day in events.byDay())
            EventsDayCard(
              day: day.day,
              events: day.events,
              now: now,
              key: day.day == today ? todayKey : null,
            ),
        ],
      ),
    );
  }
}

class EventsDayCard extends StatelessWidget {
  final DateTime day;
  final DateTime now;
  final List<Widget> eventWidgets;

  static final dayFormatter = DateFormat(DateFormat.ABBR_WEEKDAY);

  EventsDayCard({
    required DateTime day,
    required List<CalendarEvent> events,
    required this.now,
    Key? key,
  }) : eventWidgets = events.map((event) => EventCard(event)).toList(),
       day = day.toLocal(),
       super(key: key ?? ValueKey(day));

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime(now.year, now.month, now.day);

    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Padding(
            padding: const EdgeInsets.only(right: 12, top: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  dayFormatter.format(day).toUpperCase(),
                  style: textTheme.bodySmall!.apply(
                    color:
                        day == today
                            ? magenta
                            : textTheme.bodySmall!.color!.withValues(
                              alpha: 0.5,
                            ),
                  ),
                ),
                Text(
                  day.day.toString(),
                  style: textTheme.displaySmall!.apply(
                    color:
                        day == today
                            ? magenta
                            : textTheme.displaySmall!.color!.withValues(
                              alpha: 0.5,
                            ),
                  ),
                  strutStyle: const StrutStyle(
                    forceStrutHeight: true,
                    leading: 2.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                eventWidgets.isNotEmpty
                    ? eventWidgets
                    : [
                      Center(
                        child: Text(
                          'There are no events this day',
                          style: TextStyle(
                            color: textTheme.displaySmall!.color!.withValues(
                              alpha: 0.5,
                            ),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          strutStyle: const StrutStyle(
                            forceStrutHeight: true,
                            leading: 4,
                          ),
                        ),
                      ),
                    ],
          ),
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final CalendarEvent event;

  EventCard(this.event) : super(key: ObjectKey(event));

  void openEvent(BuildContext context) {
    // TODO: because adminevent is also a BaseEvent we should implement it as well, and make it a switch expr

    if (event.parentEvent is PartnerEvent) {
      launchUrl(
        (event.parentEvent as PartnerEvent).url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      context.pushNamed(
        'event',
        pathParameters: {'eventPk': event.pk.toString()},
        extra: event.parentEvent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color = switch (event.parentEvent) {
      Event(isRegistered: var isRegistered) when isRegistered =>
        Theme.of(context).colorScheme.primary,
      PartnerEvent _ => Colors.black,
      _ => Colors.grey[800]!,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        type: MaterialType.card,
        color: color,
        child: InkWell(
          onTap: () => openEvent(context),
          // Prevent painting ink outside of the card.
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  event.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
