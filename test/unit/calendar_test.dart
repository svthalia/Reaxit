import 'package:flutter_test/flutter_test.dart';
import 'package:reaxit/blocs/calendar_cubit.dart';

import '../fakes.dart';

void main() {
  group('CalendarEvent.splitEventIntoCalendarEvents', () {
    test('returns 1 CalendarEvent for a short event', () {
      final event = FakeEvent(
        pk: 1,
        title: 'Lorem',
        description: 'Ipsum',
        start: DateTime.parse('2022-03-04 13:37'),
        end: DateTime.parse('2022-03-04 14:37'),
        location: 'Dolor',
      );

      final calendarEvents = CalendarEvent.splitEventIntoCalendarEvents(event);

      expect(calendarEvents.length, 1);
      expect(calendarEvents.first.parentEvent, event);
      expect(calendarEvents.first.start, event.start);
      expect(calendarEvents.first.end, event.end);
      expect(calendarEvents.first.title, event.title);
      expect(calendarEvents.first.label, '13:37 - 14:37 | Dolor');
    });
    test('returns 1 CalendarEvent an event ending at 00:00', () {
      final event = FakeEvent(
        pk: 1,
        title: 'Lorem',
        description: 'Ipsum',
        start: DateTime.parse('2022-03-04 13:37'),
        end: DateTime.parse('2022-03-05 00:00'),
        location: 'Dolor',
      );

      final calendarEvents = CalendarEvent.splitEventIntoCalendarEvents(event);

      expect(calendarEvents.length, 1);
      expect(calendarEvents.first.parentEvent, event);
      expect(calendarEvents.first.start, event.start);
      expect(calendarEvents.first.end, event.end);
      expect(calendarEvents.first.title, event.title);
      expect(calendarEvents.first.label, '13:37 - 00:00 | Dolor');
    });

    test('returns 2 CalendarEvents for a night long event', () {
      final event = FakeEvent(
        pk: 1,
        title: 'Lorem',
        description: 'Ipsum',
        start: DateTime.parse('2022-03-04 21:00'),
        end: DateTime.parse('2022-03-05 04:00'),
        location: 'Dolor',
      );

      final calendarEvents = CalendarEvent.splitEventIntoCalendarEvents(event);

      expect(calendarEvents.length, 2);

      expect(calendarEvents.first.parentEvent, event);
      expect(calendarEvents.first.start, event.start);
      expect(calendarEvents.first.end, DateTime.parse('2022-03-05 00:00'));
      expect(calendarEvents.first.title, 'Lorem day 1/2');
      expect(calendarEvents.first.label, 'From 21:00 | Dolor');

      expect(calendarEvents.last.parentEvent, event);
      expect(calendarEvents.last.start, DateTime.parse('2022-03-05 00:00'));
      expect(calendarEvents.last.end, event.end);
      expect(calendarEvents.last.title, 'Lorem day 2/2');
      expect(calendarEvents.last.label, 'Until 04:00 | Dolor');
    });

    test('returns 7 CalendarEvents for a week long event', () {
      final event = FakeEvent(
        pk: 1,
        title: 'Lorem',
        description: 'Ipsum',
        start: DateTime.parse('2022-03-04 15:00'),
        end: DateTime.parse('2022-03-10 12:00'),
        location: 'Dolor',
      );

      final calendarEvents = CalendarEvent.splitEventIntoCalendarEvents(event);

      expect(calendarEvents.length, 7);

      expect(calendarEvents.first.parentEvent, event);
      expect(calendarEvents.first.start, event.start);
      expect(calendarEvents.first.end, DateTime.parse('2022-03-05 00:00'));
      expect(calendarEvents.first.title, 'Lorem day 1/7');
      expect(calendarEvents.first.label, 'From 15:00 | Dolor');

      expect(calendarEvents[3].parentEvent, event);
      expect(calendarEvents[3].start, DateTime.parse('2022-03-07 00:00'));
      expect(calendarEvents[3].end, DateTime.parse('2022-03-08 00:00'));
      expect(calendarEvents[3].title, 'Lorem day 4/7');
      expect(calendarEvents[3].label, 'Dolor');

      expect(calendarEvents.last.parentEvent, event);
      expect(calendarEvents.last.start, DateTime.parse('2022-03-10 00:00'));
      expect(calendarEvents.last.end, event.end);
      expect(calendarEvents.last.title, 'Lorem day 7/7');
      expect(calendarEvents.last.label, 'Until 12:00 | Dolor');
    });
  });
}
