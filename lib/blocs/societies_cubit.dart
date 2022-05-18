import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/group.dart';

typedef SocietiesState = DetailState<List<ListGroup>>;

class SocietiesCubit extends Cubit<SocietiesState> {
  final ApiRepository api;

  SocietiesCubit(this.api) : super(const SocietiesState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final listResponse = await api.getGroups(
        limit: 1000,
        type: MemberGroupType.society,
      );
      if (listResponse.results.isNotEmpty) {
        emit(SocietiesState.result(result: listResponse.results));
      } else {
        emit(const SocietiesState.failure(message: 'There are no societies.'));
      }
    } on ApiException catch (exception) {
      emit(SocietiesState.failure(message: _failureMessage(exception)));
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      case ApiException.notFound:
        return 'This page could not be found.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
