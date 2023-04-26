import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/tosti/models.dart';
import 'package:reaxit/tosti/tosti_api_repository.dart';

typedef TostiHomeState = DetailState<List<TostiVenue>>;

class TostiHomeCubit extends Cubit<TostiHomeState> {
  final TostiApiRepository api;

  TostiHomeCubit(this.api) : super(const LoadingState());

  Future<void> load() async {
    emit(LoadingState.from(state));
    try {
      final venuesFuture = api.getVenues(limit: 99, isOrderVenue: true);
      final playersFuture = api.getPlayers(limit: 99);
      final shiftsFuture = api.getShifts(
        startLTE: DateTime.now(),
        endGTE: DateTime.now(),
        limit: 99,
      );

      final venuesResponse = await venuesFuture;
      final playersResponse = await playersFuture;
      final shiftsResponse = await shiftsFuture;

      final venues = venuesResponse.results.map((final venue) {
        final shift = shiftsResponse.results.firstWhereOrNull(
          (final shift) => shift.venue.venue.id == venue.id,
        );

        return shift != null ? venue.copyWithShift(shift) : venue;
      }).map((final venue) {
        final player = playersResponse.results.firstWhereOrNull(
          (final player) => player.venue == venue.id,
        );

        return player != null ? venue.copyWithPlayer(player) : venue;
      }).toList();

      emit(ResultState(venues));
    } on ApiException catch (exception) {
      emit(ErrorState(exception.message));
    }
  }
}
