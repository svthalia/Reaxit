import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';

sealed class MarkPresentState extends Equatable {
  const MarkPresentState();

  @override
  List<Object?> get props => [];
}

class LoadingMarkPresentState extends MarkPresentState {
  const LoadingMarkPresentState();
}

class SuccessMarkPresentState extends MarkPresentState {
  final String message;

  const SuccessMarkPresentState({required this.message});

  @override
  List<Object?> get props => [message];
}

class FailureMarkPresentState extends MarkPresentState {
  final String message;

  const FailureMarkPresentState(this.message);

  @override
  List<Object?> get props => [message];
}

class MarkPresentCubit extends Cubit<MarkPresentState> {
  final ApiRepository api;

  MarkPresentCubit(this.api) : super(const LoadingMarkPresentState());

  Future<void> load({required int pk, required String token}) async {
    try {
      final detail = await api.markPresentEventRegistration(
        eventPk: pk,
        token: token,
      );
      emit(SuccessMarkPresentState(message: detail));
    } on ApiException catch (exception) {
      emit(
        FailureMarkPresentState(
          exception.getMessage(notFound: 'This event does not exist.'),
        ),
      );
    }
  }
}
