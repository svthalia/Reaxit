import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/blocs/thabloid_list_cubit.dart';
import 'package:reaxit/models/thabloid.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/paginated_scroll_view.dart';
import 'package:reaxit/ui/widgets/thabloid_tile.dart';

class ThabloidScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(title: const Text('THABLOIDS')),
      drawer: MenuDrawer(),
      body: ThabloidsScrollView(key: const PageStorageKey('thabloids')),
    );
  }
}

/// A ScrollView that shows tabloids with [Thabloid]s.
///
/// The tabloids are sorted by date
class ThabloidsScrollView
    extends PaginatedScrollView<ThabloidListCubit, Thabloid> {
  static final monthFormatter = DateFormat('MMMM');
  static final monthYearFormatter = DateFormat('MMMM yyyy');

  const ThabloidsScrollView({super.key, super.cubit})
    : super(resultsBuilder: buildResults);

  static List<Widget> buildResults(
    BuildContext context,
    List<Thabloid> thabloids,
  ) {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1 / sqrt(2),
          ),
          delegate: SliverChildBuilderDelegate(
            (_, index) => ThabloidDetailCard(thabloids[index]),
            childCount: thabloids.length,
          ),
        ),
      ),
    ];
  }
}
