import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef MemberState = DetailState<Member>;

class MemberCubit extends Cubit<MemberState> {
  final ApiRepository api;

  MemberCubit(this.api) : super(const LoadingState());

  Future<void> load(int pk) async {
    emit(LoadingState.from(state));
    try {
      final member = await api.getMember(pk: pk);
      emit(ResultState(member));
    } on ApiException catch (exception) {
      emit(
        ErrorState(
          exception.getMessage(notFound: 'The member does not exist.'),
        ),
      );
    }
  }
}
