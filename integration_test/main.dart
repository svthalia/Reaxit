import 'dart:io';

import 'package:integration_test/integration_test.dart';
import 'album_screen_test.dart';
import 'calendar_screen_test.dart';
import 'login_screen_test.dart';

void main() async {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  sleep(const Duration(seconds: 1));
  testAlbum(binding);
  testCallender();
  testLogin();
}
