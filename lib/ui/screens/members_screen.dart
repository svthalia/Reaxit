import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/paginated_scroll_view.dart';

class MembersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<MemberListCubit>(context);
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('MEMBERS'),
        collapsingActions: [
          IconAppbarAction('SEARCH', Icons.search, () async {
            final searchCubit = MemberListCubit(
              RepositoryProvider.of<ApiRepository>(context),
            );

            await showSearch(
              context: context,
              delegate: MembersSearchDelegate(searchCubit),
            );

            searchCubit.close();
          }),
        ],
      ),
      drawer: MenuDrawer(),
      body: RefreshIndicator(
        onRefresh: cubit.load,
        child: MemberListScrollView(
          cubit: cubit,
          key: const PageStorageKey('members'),
        ),
      ),
    );
  }
}

class MembersSearchDelegate extends SearchDelegate {
  final MemberListCubit _cubit;

  MembersSearchDelegate(this._cubit);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = super.appBarTheme(context);
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        titleLarge: GoogleFonts.openSans(
          textStyle: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          padding: const EdgeInsets.all(16),
          tooltip: 'Clear search bar',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
      ];
    } else {
      return [];
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    _cubit.search(query);
    return MemberListScrollView(
      cubit: _cubit,
      key: const PageStorageKey('albums-search'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final int? currentYear;
  final void Function(int?) setYear;

  _SliverAppBarDelegate(this.currentYear, this.setYear);

  final double height = 50;
  final List<int> list = List.generate(
    DateTime.now().year - 2014 + 1,
    (i) => 2014 + i,
  ).reversed.toList();

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ListView(
      scrollDirection: Axis.horizontal,
      primary: false,
      children: [
        Wrap(
          children: [
            const Padding(padding: EdgeInsets.all(2.5), child: Stack()),
            Padding(
              padding: const EdgeInsets.all(5),
              child: FilterChip(
                selected: null == currentYear,
                label: const Text('ALL'),
                onSelected: (_) => setYear(null),
              ),
            ),
            ...list.map(
              (year) => Padding(
                padding: const EdgeInsets.all(5),
                child: FilterChip(
                  selected: year == currentYear,
                  label: Text(year.toString()),
                  onSelected: (_) => setYear(year),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(2.5), child: Stack()),
          ],
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate.currentYear != currentYear;
  }
}

/// A ScrollView that shows a grid of [MemberTile]s.
class MemberListScrollView
    extends PaginatedScrollView<MemberListCubit, ListMember> {
  MemberListScrollView({super.key, super.cubit})
    : super(
        resultsBuilder: (context, members) =>
            buildResults(cubit, context, members),
      );

  static List<Widget> buildResults(
    MemberListCubit? cubit,
    BuildContext context,
    List<ListMember> members,
  ) {
    final cubit0 = cubit ?? BlocProvider.of<MemberListCubit>(context);
    return [
      SliverPersistentHeader(
        delegate: _SliverAppBarDelegate(cubit0.year, cubit0.filterYear),
      ),
      SliverPadding(
        padding: const EdgeInsets.all(8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => MemberTile(member: members[index]),
            childCount: members.length,
          ),
        ),
      ),
    ];
  }
}
