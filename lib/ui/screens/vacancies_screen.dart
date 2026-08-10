import 'package:flutter/material.dart';
import 'package:reaxit/blocs/vacancies_cubit.dart';
import 'package:reaxit/models/vacancie.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/paginated_scroll_view.dart';
import 'package:reaxit/ui/widgets/vacancy.dart';

class VacanciesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(title: const Text('VACANCIES')),
      drawer: MenuDrawer(),
      body: VacanciesScrollView(key: const PageStorageKey('vacancies')),
    );
  }
}

/// A ScrollView that shows a calendar with [Vacancy]s.
class VacanciesScrollView
    extends PaginatedScrollView<VacanciesListCubit, Vacancy> {
  const VacanciesScrollView({super.key, super.cubit})
    : super(resultsBuilder: buildResults);

  static List<Widget> buildResults(
    BuildContext context,
    List<Vacancy> vacancies,
  ) {
    return vacancies
        .map((v) => SliverToBoxAdapter(child: VacancieCard(vacancie: v)))
        .toList();
  }
}
