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
    print("xx");
    // Start app
    app.testingMain();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }
    binding.drawFrame();

    expect(
      find.image(const NetworkImage(imagelink2)),
      findsWidgets,
    );
    print("yy");
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
  });
}
