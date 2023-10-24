import 'package:integration_test/integration_test.dart';

import 'album_screen_test.dart';
import 'calendar_screen_test.dart';
import 'login_screen_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await Future.delayed(const Duration(seconds: 5));

  testAlbum();
  testCallender();
  testLogin();
}
