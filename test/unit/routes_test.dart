import 'package:flutter_test/flutter_test.dart';
import 'package:reaxit/routes.dart';
import 'package:reaxit/config.dart' as config;

void main() {
  group('isDeepLink', () {
    test('returns true if uri is a deep link', () {
      const apiHost = config.apiHost;
      final validUris = [
        'https://$apiHost/events/1/',
        'https://$apiHost/events/1',
        'http://$apiHost/events/1/',
        'https://$apiHost/',
        'https://$apiHost/pizzas/',
        'https://$apiHost/members/photos/',
        'https://$apiHost/members/photos/some-album-1/',
        'https://$apiHost/sales/order/11111111-aaaa-bbbb-cccc-222222222222/pay/',
        'https://$apiHost/events/1/mark-present/11111111-aaaa-bbbb-cccc-222222222222/',
      ];

      for (final uri in validUris) {
        expect(
          isDeepLink(Uri.parse(uri)),
          true,
          reason: '$uri is a valid deep link',
        );
      }
    });

    test('returns false if uri is not a deep link', () {
      const apiHost = config.apiHost;
      final invalidUris = [
        'https://$apiHost/contact',
        'https://example.org/events/1/',
        'https://subdomain.$apiHost/events/1/',
        'http://$apiHost/events/xxx/',
        'https://$apiHost/sales/order/11111111-bbbb-cccc-222222222222/pay/',
        'https://$apiHost/events/1/mark-present/11111111-bbbb-cccc-222222222222/',
        'https://$apiHost/events/1/mark_present/11111111-aaaa-bbbb-cccc-222222222222/',
      ];

      for (final uri in invalidUris) {
        expect(
          isDeepLink(Uri.parse(uri)),
          false,
          reason: '$uri is not a valid deep link',
        );
      }
    });
  });
}
