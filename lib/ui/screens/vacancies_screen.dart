import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/blocs/vacancies_cubit.dart';
import 'package:reaxit/models/vacancie.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/vacancy.dart';

class VacanciesScreen extends StatefulWidget {
  @override
  State<VacanciesScreen> createState() => _ThabloidScreenState();
}

class _ThabloidScreenState extends State<VacanciesScreen> {
  late ScrollController _controller;
  late VacanciesListCubit _cubit;

  @override
  void initState() {
    _cubit = BlocProvider.of<VacanciesListCubit>(context);
    _controller = ScrollController()..addListener(_scrollListener);

    _cubit.load();
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      _cubit.moreDown();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(title: const Text('VACANCIES')),
      drawer: MenuDrawer(),
      body: BlocBuilder<VacanciesListCubit, VacanciesState>(
        builder: (context, thabloidsState) {
          if (thabloidsState.hasException) {
            return ErrorScrollView(thabloidsState.message!, retry: _cubit.load);
          } else if (thabloidsState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return VacanciesScrollView(
              key: const PageStorageKey('vacancies'),
              controller: _controller,
              thabloidState: thabloidsState,
              vacancies: thabloidsState.results,
            );
          }
        },
      ),
    );
  }
}

/// A ScrollView that shows a calendar with [Vacancies]s.
///
/// The events are grouped by month, and date.
///
/// This does not take care of communicating with a Bloc. The [controller]
/// should do that. The [thabloidState] also must not have an exception.
class VacanciesScrollView extends StatelessWidget {
  static final monthFormatter = DateFormat('MMMM');
  static final monthYearFormatter = DateFormat('MMMM yyyy');

  final Key centerkey = UniqueKey();
  final ScrollController controller;
  final VacanciesState thabloidState;
  final List<Vacancy> vacancies;

  VacanciesScrollView({
    super.key,
    required this.controller,
    required this.thabloidState,
    required this.vacancies,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: controller,
              physics: const RangeMaintainingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers:
                  vacancies
                      .map(
                        (v) => SliverToBoxAdapter(
                          child: VacancieCard(vacancie: v),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
