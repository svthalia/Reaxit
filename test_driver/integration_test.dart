import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  try {
    await integrationDriver();
  } catch (e) {
    throw ('Error occured: $e');
  }
}
