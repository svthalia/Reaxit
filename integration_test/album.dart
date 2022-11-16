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

const imagelink1 =
    'https://upload.wikimedia.org/wikipedia/commons/7/7b/Image_in_Glossographia.png';

const coverphoto1 = CoverPhoto(
  0,
  0,
  true,
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
  false,
  Photo(
    imagelink1,
    imagelink1,
    imagelink1,
    imagelink1,
  ),
  false,
  0,
);

WidgetTesterCallback getTestMethod(Album album) {
  return (tester) async {
    // Setup mock.
    final api = MockApiRepository();
    when(api.getAlbum(slug: album.slug)).thenAnswer(
      (realInvocation) async => album,
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

    // Start app
    app.testingMain(authCubit, '/albums/${album.slug}');
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    for (AlbumPhoto photo in album.photos) {
      expect(
        find.image(
          NetworkImage(photo.small),
        ),
        findsOneWidget,
      );
    }
    expect(find.text(album.title.toUpperCase()), findsOneWidget);
  };
}

void testAlbum() {
  final _ = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Album',
    () {
      testWidgets(
        'able to load an album',
        getTestMethod(
          const Album.fromlist(
            '1',
            'mock',
            false,
            false,
            coverphoto1,
            [albumphoto1],
          ),
        ),
      );
    },
  );
}
