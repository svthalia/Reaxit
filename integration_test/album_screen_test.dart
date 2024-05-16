import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reaxit/main.dart' as app;

const imagelink1 =
    'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/album_placeholder.png';

const imagelink2 =
    'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/default-avatar.jpg';

WidgetTesterCallback getTestMethod(
    IntegrationTestWidgetsFlutterBinding binding) {
  return (tester) async {
    // Start app
    app.testingMain();
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
      find.image(const NetworkImage(imagelink2)),
      findsWidgets,
    );
    // }
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
