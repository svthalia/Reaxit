import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reaxit/main.dart' as app;
import 'package:reaxit/models.dart';

const imagelink1 =
    'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/album_placeholder.png';

const imagelink2 =
    'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/default-avatar.jpg';

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

WidgetTesterCallback getTestMethod(
    IntegrationTestWidgetsFlutterBinding binding) {
  return (tester) async {
    // Start app
    app.testingMain('/albums');
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));
    print("wheyy0");

    // todo: https://github.com/flutter/flutter/issues/51890
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }
    binding.drawFrame();

    print("wheyy");
    // await binding.takeScreenshot('screenshot-${album.title}');
    print("wheyy1");
    // for (AlbumPhoto photo in album.photos) {
    //TODO: wait for https://github.com/flutter/flutter/issues/115479 to be fixed
    expect(
      find.image(NetworkImage(imagelink1)),
      findsWidgets,
    );
    // }
    expect(find.text('wheyyy'), findsOneWidget);
    print("wheyy2");
    print("wheyy3");
  };
}

void testAlbum(IntegrationTestWidgetsFlutterBinding binding) {
  group('AlbumScreen', () {
    testWidgets(
      'can load an album with 1 photo',
      getTestMethod(
        binding,
      ),
    );
    testWidgets(
      'can load an album with 1 photo',
      getTestMethod(
        binding,
      ),
    );
    testWidgets(
      'can load an album with 1 photo',
      getTestMethod(
        binding,
      ),
    );
  });
}
