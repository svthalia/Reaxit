import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/screens.dart';

import '../mocks.mocks.dart';

void main() {
  group('WelcomeScreen', () {
    testWidgets('Displays normal and partner events', (
      WidgetTester tester,
    ) async {
      final normalEvent = Event(
        1,
        'Lorem 1',
        'Ipsum 1',
        '',
        '',
        DateTime.parse('2022-03-04 13:37'),
        DateTime.parse('2022-03-04 14:37'),
        EventCategory.other,
        null,
        null,
        null,
        '',
        '',
        '',
        0,
        null,
        null,
        false,
        null,
        '',
        const EventPermissions(false, true, false, false, false),
        null,
        [],
        '',
        '',
        false,
        [],
      );

      final partnerEvent = PartnerEvent(
        1,
        'Lorem 2',
        'Ipsum 1',
        DateTime.parse('2022-03-04 13:37'),
        DateTime.parse('2022-03-04 14:37'),
        'Dolor 1',
        Uri(),
      );

      final state = WelcomeState.result(
        slides: const [],
        articles: const [],
        upcomingEvents: [normalEvent, partnerEvent],
        announcements: const [],
      );

      final cubit = MockWelcomeCubit();
      final streamController =
          StreamController<WelcomeState>.broadcast()
            ..stream.listen((state) {
              when(cubit.state).thenReturn(state);
            })
            ..add(const WelcomeState.loading())
            ..add(state);

      when(cubit.load()).thenAnswer((_) => Future.value(null));
      when(cubit.stream).thenAnswer((_) => streamController.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: InheritedConfig(
            config: Config.defaultConfig,
            child: Scaffold(
              body: BlocProvider<WelcomeCubit>.value(
                value: cubit,
                child: WelcomeScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.text('LOREM 1'), findsOneWidget);
      expect(find.text('LOREM 2'), findsOneWidget);
    });
  });
}
