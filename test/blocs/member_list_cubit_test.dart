import 'package:flutter_test/flutter_test.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/member_list_cubit.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  group('MemberListCubit', () {
    late ApiRepository api;

    setUp(() {
      api = MockApiRepository();
    });
    test('starts with loading state.', () {
      final cubit = MemberListCubit(api);
      final firstState = cubit.state;
      expect(firstState.isLoading, isTrue);
    });
  });
}
