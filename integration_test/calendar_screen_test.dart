import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/main.dart' as app;
import 'package:reaxit/models.dart';

import '../test/mocks.mocks.dart';

const imagelink1 =
    'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/album_placeholder.png';

const imagelink2 =
    'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/default-avatar.jpg';

const coverphoto1 = CoverPhoto(
  0,
  0,
  Photo(
    imagelink1,
    imagelink1,
    imagelink1,
    imagelink1,
  ),
);

const albumphoto1 = AlbumPhoto(
  0,
  0,
  Photo(
    imagelink1,
    imagelink1,
    imagelink1,
    imagelink1,
  ),
  false,
  0,
);

const albumphoto2 = AlbumPhoto(
  0,
  0,
  Photo(
    imagelink2,
    imagelink2,
    imagelink2,
    imagelink2,
  ),
  false,
  0,
);

WidgetTesterCallback getTestMethod(List<Event> events, DateTime now) {
  return (tester) async {
    final split = DateTime(now.year, now.month);

    // Setup mock.
    final api = MockApiRepository();
    when(api.getEvents(
      start: split,
      search: null,
      ordering: 'start',
      limit: CalendarCubit.firstPageSize,
      offset: 0,
      end: null,
    )).thenAnswer(
      (realInvocation) async {
        return ListResponse(events.length, events);
      },
    );
    when(api.getEvents(
            end: split,
            search: null,
            ordering: '-end',
            limit: CalendarCubit.firstPageSize,
            offset: 0))
        .thenAnswer(
      (realInvocation) async {
        return ListResponse(events.length, events);
      },
    );
    when(api.getPartnerEvents(start: split, search: null, ordering: 'start'))
        .thenAnswer((realInvocation) async => const ListResponse(0, []));
    when(api.getPartnerEvents(start: split, search: null, ordering: '-end'))
        .thenAnswer((realInvocation) async => const ListResponse(0, []));
    final authCubit = MockAuthCubit();

    throwOnMissingStub(
      api,
      exceptionBuilder: (invocation) {
        throw ApiException.unknownError;
      },
    );

    final streamController = StreamController<AuthState>.broadcast()
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

    final calendarEvents =
        events.expand(CalendarEvent.splitEventIntoCalendarEvents);

    for (CalendarEvent event in calendarEvents) {
      expect(find.text(event.title), findsOneWidget);
      expect(find.text(event.label), findsOneWidget);
    }

    if (events.any(
        (element) => element.start.isBefore(now) && element.end.isAfter(now))) {
      expect(find.text('There are no events this day'), findsOneWidget);
    }
  };
}

void testCallender() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  group('AlbumScreen', () {
    testWidgets(
      'showsEvents',
      getTestMethod([
        Event(
          0,
          'test',
          'https://staging.thalia.nu',
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
          const EventPermissions(false, false, false, false),
          null,
          'sucks2bu',
          true,
          [],
        )
      ], DateTime.now()),
    );

    testWidgets(
      'showsToday',
      getTestMethod(const [], DateTime.now()),
    );
  });
}
