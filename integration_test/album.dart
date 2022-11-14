import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/main.dart' as app;
import 'package:reaxit/models.dart';

import '../test/mocks.mocks.dart';

void testAlbum() {
  // ignore: unused_local_variable
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Album', () {
    testWidgets(
      'Able to load an album',
      (tester) async {
        // Setup mock.
        final api = MockApiRepository();
        when(api.getAlbum(slug: '1')).thenAnswer(
          (realInvocation) async => const Album.fromlist(
            '1',
            'mock',
            false,
            false,
            CoverPhoto(
              0,
              0,
              true,
              Photo(
                'https://upload.wikimedia.org/wikipedia/commons/7/7b/Image_in_Glossographia.png',
                'https://upload.wikimedia.org/wikipedia/commons/7/7b/Image_in_Glossographia.png',
                'https://upload.wikimedia.org/wikipedia/commons/7/7b/Image_in_Glossographia.png',
                'https://upload.wikimedia.org/wikipedia/commons/7/7b/Image_in_Glossographia.png',
              ),
            ),
            [
              AlbumPhoto(
                0,
                0,
                false,
                Photo(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/1280px-Image_created_with_a_mobile_phone.png',
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/1280px-Image_created_with_a_mobile_phone.png',
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/1280px-Image_created_with_a_mobile_phone.png',
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/1280px-Image_created_with_a_mobile_phone.png',
                ),
                false,
                0,
              )
            ],
          ),
        );
        final authCubit = MockAuthCubit();

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
        app.testingMain(authCubit, '/albums/1');
        await tester.pumpAndSettle();
        //TODO: Why is this neccesary?
        await Future.delayed(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        expect(
            find.image(
              const NetworkImage(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/1280px-Image_created_with_a_mobile_phone.png'),
            ),
            findsWidgets);
      },
    );
  });
}
