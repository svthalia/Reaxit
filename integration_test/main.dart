import 'package:integration_test/integration_test.dart';

import 'album_screen_test.dart';
import 'login_screen_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testLogin();
  testAlbum();
}
