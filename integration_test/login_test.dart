import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs/auth_cubit.dart';
import 'package:reaxit/main.dart' as app;

import '../test/mocks.mocks.dart';

void main() {
  // ignore: unused_local_variable
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'LoginScreen works and logging in redirects to WelcomeScreen',
    (tester) async {
      final authCubit = MockAuthCubit();
      final streamController = StreamController<AuthState>.broadcast()
        ..add(LoadingAuthState())
        ..add(LoggedOutAuthState());

      when(authCubit.load()).thenAnswer((_) => Future.value(null));
      when(authCubit.state).thenReturn(LoggedOutAuthState());
      when(authCubit.stream).thenAnswer((_) => streamController.stream);

      app.testingMain(authCubit);
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);
      await tester.tap(find.text('LOGIN'));

      streamController.add(LoadingAuthState());
      when(authCubit.state).thenReturn(LoadingAuthState());

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final apiRepository = MockApiRepository();
      throwOnMissingStub(
        apiRepository,
        exceptionBuilder: (_) {
          throw ApiException.unknownError;
        },
      );

      final loggedInState = LoggedInAuthState(apiRepository: apiRepository);
      streamController.add(loggedInState);
      when(authCubit.state).thenReturn(loggedInState);

      await tester.pumpAndSettle();

      expect(find.text('WELCOME'), findsOneWidget);
    },
  );
}
