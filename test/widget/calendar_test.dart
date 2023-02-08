import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/ui/screens.dart';

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
      DateTime now = DateTime.now();
      final state = CalendarState(
          now,
          DoubleListState.success(
            resultsDown: [
              ...CalendarEvent.splitEventIntoCalendarEvents(event1),
              ...CalendarEvent.splitEventIntoCalendarEvents(event2),
            ],
            isDoneDown: true,
            isDoneUp: true,
          ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarScrollView(
              controller: ScrollController(),
              calendarState: state,
              loadMoreUp: (() {}),
              now: now,
            ),
          ),
        ),
      );

      expect(find.text('Lorem 1'), findsOneWidget);
      expect(find.textContaining('APRIL'), findsOneWidget);
      expect(find.textContaining('MAY'), findsOneWidget);
      expect(find.textContaining('Lorem 2'), findsNWidgets(3));
    });
  });
}
