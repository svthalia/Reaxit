import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/main.dart' as app;

import '../test/mocks.mocks.dart';

void testLogin() {
  // ignore: unused_local_variable
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LoginScreen', () {
    testWidgets(
      'lets you log in and logging in redirects to WelcomeScreen',
      (tester) async {},
    );

    testWidgets(
      'is not shown when already logged in',
      (tester) async {
        // Setup signed-in AuthCubit.
        final authCubit = MockAuthCubit();
        final api = MockApiRepository();
        throwOnMissingStub(
          api,
          exceptionBuilder: (_) {
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

        // Start app.
        app.testingMain(authCubit, null);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        expect(find.text('WELCOME'), findsOneWidget);
      },
    );

    testWidgets(
      'is shown again after logging out',
      (tester) async {
        // Setup signed-in AuthCubit.
        final authCubit = MockAuthCubit();
        final api = MockApiRepository();
        throwOnMissingStub(
          api,
          exceptionBuilder: (_) {
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

        when(authCubit.logOut()).thenAnswer((_) => Future.value(null));

        // Start app.
        app.testingMain(authCubit, null);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        await tester.flingFrom(
          const Offset(100, 250),
          const Offset(0, -100),
          200,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();

        verify(authCubit.logOut()).called(1);

        streamController.add(LoggedOutAuthState());
        await tester.pumpAndSettle();

        expect(find.text('LOGIN'), findsOneWidget);
      },
    );
  });
}