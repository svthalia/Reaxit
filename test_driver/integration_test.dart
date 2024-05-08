import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  try {
    await integrationDriver(
      onScreenshot: saveScreenshot,
    );
  } catch (e) {
    throw ('Error occured: $e');
  }
  // integrationDriver();
}

Future<bool> saveScreenshot(String screenshotName, List<int> screenshotBytes,
    [Map<String, Object?>? args]) async {
  final File image =
      await File('screenshots/$screenshotName.png').create(recursive: true);
  image.writeAsBytesSync(screenshotBytes);
  return true;
}
