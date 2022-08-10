import 'package:mockito/annotations.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/auth_cubit.dart';
import 'package:reaxit/blocs/payment_user_cubit.dart';

@GenerateMocks([
  AuthCubit,
  ApiRepository,
  PaymentUserCubit,
])
void main() {}
