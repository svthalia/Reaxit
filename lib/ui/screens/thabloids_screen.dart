import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/blocs/thabloid_list_cubit.dart';
import 'package:reaxit/models/thabliod.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/thabloid_tile.dart';

class ThabloidScreen extends StatefulWidget {
  @override
  State<ThabloidScreen> createState() => _ThabloidScreenState();
}

class _ThabloidScreenState extends State<ThabloidScreen> {
  late ScrollController _controller;
  late CalendarCubit _cubit;

  @override
  void initState() {
    _cubit = BlocProvider.of<CalendarCubit>(context);
    _controller = ScrollController()..addListener(_scrollListener);
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
      appBar: ThaliaAppBar(
        title: const Text('THABLOIDS'),
      ),
      drawer: MenuDrawer(),
      body: BlocBuilder<ThabloidListCubit, ThabloidListState>(
        builder: (context, thabloidsState) {
          if (thabloidsState.hasException) {
            return ErrorScrollView(thabloidsState.message!);
          } else if (thabloidsState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ThabloidsScrollView(
              key: const PageStorageKey('thabloids'),
              controller: _controller,
              thabloidState: thabloidsState,
              thabloids: thabloidsState.results,
            );
          }
        },
      ),
    );
  }
}

/// A ScrollView that shows a calendar with [Thabloid]s.
///
/// The events are grouped by month, and date.
///
/// This does not take care of communicating with a Bloc. The [controller]
/// should do that. The [thabloidState] also must not have an exception.
class ThabloidsScrollView extends StatelessWidget {
  static final monthFormatter = DateFormat('MMMM');
  static final monthYearFormatter = DateFormat('MMMM yyyy');

  final Key centerkey = UniqueKey();
  final ScrollController controller;
  final ThabloidListState thabloidState;
  final List<Thabloid> thabloids;

  ThabloidsScrollView(
      {super.key,
      required this.controller,
      required this.thabloidState,
      required this.thabloids});

  @override
  Widget build(BuildContext context) {
    ApiRepository api = context.read();
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            controller: controller,
            physics: const RangeMaintainingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1 / sqrt(2),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => ThabloidDetailCard(thabloids[index], api),
                    childCount: thabloids.length,
                  ),
                ),
              ),
              if (thabloidState.isLoadingMore)
                const SliverPadding(
                  padding: EdgeInsets.all(12),
                  sliver: SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
