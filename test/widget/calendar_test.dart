import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reaxit/blocs/calendar_cubit.dart';
import 'package:reaxit/ui/screens/calendar_screen.dart';

import '../fakes.dart';

void main() {
  group('CalendarScrollView', () {
    testWidgets('renders events correctly', (WidgetTester tester) async {
      final event1 = FakeEvent(
        pk: 1,
        title: 'Lorem 1',
        description: 'Ipsum 1',
        start: DateTime.parse('2022-03-04 13:37'),
        end: DateTime.parse('2022-03-04 14:37'),
        location: 'Dolor 1',
      );

      final event2 = FakeEvent(
        pk: 2,
        title: 'Lorem 2',
        description: 'Ipsum 2',
        start: DateTime.parse('2022-04-29 15:00'),
        end: DateTime.parse('2022-05-01 12:00'),
        location: 'Dolor 2',
      );

      final state = CalendarState.success(
        results: [
          ...CalendarEvent.splitEventIntoCalendarEvents(event1),
          ...CalendarEvent.splitEventIntoCalendarEvents(event2),
        ],
        isDone: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScrollView(
              controller: ScrollController(),
              calendarState: state,
            ),
          ),
        ),
      );

      expect(find.text('Lorem 1'), findsOneWidget);
      expect(find.text('APRIL'), findsOneWidget);
      expect(find.text('MAY'), findsOneWidget);
      expect(find.textContaining('Lorem 2'), findsNWidgets(3));
    });
  });
}
