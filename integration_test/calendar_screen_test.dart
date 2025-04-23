import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/main.dart' as app;
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/screens.dart';

import '../test/mocks.mocks.dart';

const imagelink1 =
    'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/album_placeholder.png';

const imagelink2 =
    'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/default-avatar.jpg';

const coverphoto1 = CoverPhoto(
  0,
  0,
  Photo(imagelink1, imagelink1, imagelink1, imagelink1),
);

const albumphoto1 = AlbumPhoto(
  0,
  0,
  Photo(imagelink1, imagelink1, imagelink1, imagelink1),
  false,
  0,
);

const albumphoto2 = AlbumPhoto(
  0,
  0,
  Photo(imagelink2, imagelink2, imagelink2, imagelink2),
  false,
  0,
);

WidgetTesterCallback getTestMethod(List<Event> events, DateTime now) {
  return (tester) async {
    final split = DateTime(now.year, now.month);
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Setup mock.
    final api = MockApiRepository();
    when(api.config).thenReturn(Config.testing);
    when(
      api.getEvents(
        start: split,
        search: null,
        ordering: 'start',
        limit: EventsSource.firstPageSize,
        offset: 0,
        end: null,
      ),
    ).thenAnswer((realInvocation) async => ListResponse(events.length, events));
    when(
      api.getEvents(
        end: split,
        search: null,
        ordering: '-end',
        limit: EventsSource.firstPageSize,
        offset: 0,
      ),
    ).thenAnswer((realInvocation) async {
      return ListResponse(events.length, events);
    });
    when(
      api.getPartnerEvents(
        start: split,
        search: null,
        ordering: 'start',
        offset: 0,
      ),
    ).thenAnswer((realInvocation) async => const ListResponse(0, []));
    when(
      api.getPartnerEvents(
        start: split,
        search: null,
        ordering: '-end',
        offset: 0,
      ),
    ).thenAnswer((realInvocation) async => const ListResponse(0, []));
    final authCubit = MockAuthCubit();

    throwOnMissingStub(
      api,
      exceptionBuilder: (invocation) {
        throw ApiException.unknownError;
      },
    );

    final streamController =
        StreamController<AuthState>.broadcast()
          ..stream.listen((state) {
            when(authCubit.state).thenReturn(state);
          })
          ..add(LoadingAuthState())
          ..add(LoggedInAuthState(apiRepository: api));

    when(authCubit.load()).thenAnswer((_) => Future.value(null));
    when(authCubit.stream).thenAnswer((_) => streamController.stream);

    // Start app
    app.testingMain(authCubit, '/events');
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final calendarEvents = events.expand(
      CalendarEvent.splitEventIntoCalendarEvents,
    );

    for (CalendarEvent event in calendarEvents) {
      expect(find.text(event.title), findsOneWidget);
      expect(find.text(event.label), findsOneWidget);
    }

    if (events.any(
      (element) =>
          element.start.isAfter(today) && element.end.isBefore(tomorrow),
    )) {
      expect(find.text('There are no events this day'), findsOneWidget);
    }
  };
}

void testCallender() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  group('CalendarScreen', () {
    testWidgets(
      'showsEvents',
      getTestMethod([
        Event(
          0,
          'test',
          'https://staging.thalia.nu',
          'test123',
          'test123',
          today,
          today.add(const Duration(hours: 5)),
          EventCategory.leisure,
          null,
          null,
          null,
          'heaven',
          '5 euro',
          '5 euro',
          5,
          null,
          null,
          false,
          null,
          'no',
          const EventPermissions(false, true, false, false, false),
          null,
          [],
          '',
          'sucks2bu',
          true,
          [],
        ),
      ], DateTime.now()),
    );

    testWidgets('showsToday', getTestMethod(const [], DateTime.now()));
    testWidgets('eventuallyAdd', (tester) async {
      List<Event> events = [
        Event(
          0,
          'test',
          'https://staging.thalia.nu',
          'test123',
          'test123',
          today,
          today.add(const Duration(hours: 5)),
          EventCategory.leisure,
          null,
          null,
          null,
          'heaven',
          '5 euro',
          '5 euro',
          5,
          null,
          null,
          false,
          null,
          'no',
          const EventPermissions(false, true, false, false, false),
          null,
          [],
          '',
          'sucks2bu',
          true,
          [],
        ),
        Event(
          1,
          'test1',
          'https://staging.thalia.nu',
          'test123',
          'test123',
          today.add(const Duration(hours: 5)),
          today.add(const Duration(hours: 10)),
          EventCategory.leisure,
          null,
          null,
          null,
          'heaven',
          '5 euro',
          '5 euro',
          5,
          null,
          null,
          false,
          null,
          'no',
          const EventPermissions(false, true, false, false, false),
          null,
          [],
          '',
          'sucks2bu',
          true,
          [],
        ),
        Event(
          2,
          'test2',
          'https://staging.thalia.nu',
          'test123',
          'test123',
          today.add(const Duration(hours: 10)),
          today.add(const Duration(hours: 15, days: 2)),
          EventCategory.leisure,
          null,
          null,
          null,
          'heaven',
          '5 euro',
          '5 euro',
          5,
          null,
          null,
          false,
          null,
          'no',
          const EventPermissions(false, true, false, false, false),
          null,
          [],
          '',
          'sucks2bu',
          true,
          [],
        ),
        Event(
          3,
          'test3',
          'https://staging.thalia.nu',
          'test1234',
          'test1234',
          today.add(const Duration(hours: 10, days: 1)),
          today.add(const Duration(hours: 15, days: 1)),
          EventCategory.leisure,
          null,
          null,
          null,
          'heaven',
          '5 euro',
          '5 euro',
          5,
          null,
          null,
          false,
          null,
          'no',
          const EventPermissions(false, true, false, false, false),
          null,
          [],
          '',
          'sucks2bu',
          true,
          [],
        ),
      ];

      List<PartnerEvent> pevents = [
        PartnerEvent(
          0,
          'PE0',
          'PE0',
          today.add(const Duration(hours: 5)),
          today.add(const Duration(hours: 10)),
          'heaven2',
          Uri.https('thalia.nu'),
        ),
      ];

      final split = DateTime(now.year, now.month);

      // Setup mock.
      final api = MockApiRepository();
      when(api.config).thenReturn(Config.testing);
      when(
        api.getEvents(
          start: split,
          search: null,
          ordering: 'start',
          limit: EventsSource.firstPageSize,
          offset: 0,
          end: null,
        ),
      ).thenAnswer((realInvocation) async {
        return ListResponse(4, events.take(3).toList());
      });
      when(
        api.getEvents(
          start: split,
          search: null,
          ordering: 'start',
          limit: EventsSource.pageSize,
          offset: 3,
          end: null,
        ),
      ).thenAnswer((realInvocation) async {
        return ListResponse(4, [events.last]);
      });
      when(
        api.getEvents(
          end: split,
          search: null,
          ordering: '-end',
          limit: EventsSource.firstPageSize,
          offset: 0,
        ),
      ).thenAnswer((realInvocation) async {
        return const ListResponse(0, []);
      });
      when(
        api.getPartnerEvents(
          start: split,
          search: null,
          ordering: 'start',
          offset: 0,
        ),
      ).thenAnswer(
        (realInvocation) async => ListResponse(pevents.length, pevents),
      );
      when(
        api.getPartnerEvents(
          start: split,
          search: null,
          ordering: '-end',
          offset: 0,
        ),
      ).thenAnswer((realInvocation) async => const ListResponse(0, []));
      final authCubit = MockAuthCubit();

      throwOnMissingStub(
        api,
        exceptionBuilder: (invocation) {
          throw ApiException.unknownError;
        },
      );

      final streamController =
          StreamController<AuthState>.broadcast()
            ..stream.listen((state) {
              when(authCubit.state).thenReturn(state);
            })
            ..add(LoadingAuthState())
            ..add(LoggedInAuthState(apiRepository: api));

      when(authCubit.load()).thenAnswer((_) => Future.value(null));
      when(authCubit.stream).thenAnswer((_) => streamController.stream);

      // Start app
      app.testingMain(authCubit, '/events');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      // Load more events
      CalendarScrollView screen =
          find.byType(CalendarScrollView).first.evaluate().first.widget
              as CalendarScrollView;
      screen.controller.notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final calendarEvents = events.expand(
        CalendarEvent.splitEventIntoCalendarEvents,
      );

      Map<String, int> calendarTitleCounts = {};
      Map<String, int> calendarLableCounts = {};
      for (CalendarEvent event in calendarEvents) {
        calendarTitleCounts.update(
          event.title,
          (c) => c + 1,
          ifAbsent: () => 1,
        );
        calendarLableCounts.update(
          event.label,
          (c) => c + 1,
          ifAbsent: () => 1,
        );
      }
      for (MapEntry title in calendarTitleCounts.entries) {
        // sleep(Duration(seconds: 10));
        expect(find.text(title.key), findsNWidgets(title.value));
      }
      for (MapEntry label in calendarLableCounts.entries) {
        expect(find.text(label.key), findsNWidgets(label.value));
      }

      if (events.any(
        (element) =>
            element.end.isBefore(today) &&
            element.start.isAfter(now.add(const Duration(days: 1))),
      )) {
        expect(find.text('There are no events this day'), findsOneWidget);
      }
    });
  });
}
