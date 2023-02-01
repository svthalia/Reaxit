import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';

class RegistrationsCubit extends PaginatedCubit<EventRegistration> {
  final ApiRepository api;
  final int eventPk;

  /// The offset to be used for the next paginated request.
  int _nextOffset = 0;

  RegistrationsCubit(this.api, {required this.eventPk})
      : super(firstPageSize: 60, pageSize: 30);

  @override
  Future<void> load() async {
    try {
      final listResponse = await api.getEventRegistrations(
          pk: eventPk, limit: firstPageSize, offset: 0);

      final isDone = listResponse.results.length == listResponse.count;

      _nextOffset = firstPageSize;

      if (listResponse.results.isNotEmpty) {
        emit(ResultsListState.withDone(listResponse.results, isDone));
      } else {
        emit(const ErrorListState('There are no registrations yet.'));
      }
    } on ApiException catch (exception) {
      emit(ErrorListState(
        exception.getMessage(notFound: 'The event does not exist.'),
      ));
    }
  }

  @override
  Future<void> more() async {
    // Ignore calls to `more()` if there is no data, or already more coming.
    final oldState = state;
    if (oldState is! ResultsListState ||
        oldState is LoadingMoreListState ||
        oldState is DoneListState) return;

    final resultsState = oldState as ResultsListState<EventRegistration>;

    emit(LoadingMoreListState.from(resultsState));
    try {
      var listResponse = await api.getEventRegistrations(
        pk: eventPk,
        limit: pageSize,
        offset: _nextOffset,
      );

      final registrations = resultsState.results + listResponse.results;
      final isDone = registrations.length == listResponse.count;

      _nextOffset += pageSize;

      emit(ResultsListState.withDone(registrations, isDone));
    } on ApiException catch (exception) {
      emit(ErrorListState(
        exception.getMessage(notFound: 'The event does not exist.'),
      ));
    }
  }
}
