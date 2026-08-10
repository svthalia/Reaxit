import 'dart:async';

import 'package:reaxit/blocs.dart';
import 'package:reaxit/blocs/list_cubit.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/models/vacancie.dart';

typedef VacanciesState = InnerListState<Vacancy>;

class VacanciesListCubit extends SingleListCubit<Vacancy> {
  VacanciesListCubit(super.api);

  @override
  List<Vacancy> combineDown(
    List<Vacancy> downResults,
    ListState<Vacancy> oldstate,
  ) => getResults(oldstate) + downResults;

  @override
  ListState<Vacancy> empty(String? query) => switch (query) {
    null => const ErrorState('No vacancies found.'),
    '' => const ResultState(
      InnerListState.withMessage(message: 'Start searching for vacancies'),
    ),
    var q => ErrorState('No vacancies found found for query "$q"'),
  };

  @override
  Future<ListResponse<Vacancy>> getDown(int offset) =>
      api.getVacancies(limit: 1000, offset: offset);

  @override
  List<Vacancy> processDown(List<Vacancy> downResults) {
    return downResults;
  }
}
