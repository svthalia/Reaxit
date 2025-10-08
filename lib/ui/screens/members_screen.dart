import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/ui/widgets.dart';

class MembersScreen extends StatefulWidget {
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late ScrollController _controller;
  late MemberListCubit _cubit;

  @override
  void initState() {
    _cubit = BlocProvider.of<MemberListCubit>(context);
    _controller = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      // Only request loading more if that's not already happening.
      if (!_cubit.state.isLoadingMore) {
        _cubit.more();
      }
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
        onRefresh: _cubit.load,
        child: BlocBuilder<MemberListCubit, MemberListState>(
          builder: (context, listState) {
            if (listState.hasException) {
              return ErrorScrollView(listState.message!, retry: _cubit.load);
            } else {
              return MemberListScrollView(
                key: const PageStorageKey('members'),
                controller: _controller,
                listState: listState,
                currentYear: _cubit.year,
                setYear: _cubit.filterYear,
              );
            }
          },
        ),
      ),
    );
  }
}

class MembersSearchDelegate extends SearchDelegate {
  final MemberListCubit _cubit;
  late final ScrollController _controller;

  MembersSearchDelegate(this._cubit) {
    _controller = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      // Only request loading more if that's not already happening.
      if (!_cubit.state.isLoadingMore) {
        _cubit.more();
      }
    }
  }

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
    return BlocBuilder<MemberListCubit, MemberListState>(
      bloc: _cubit..search(query),
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(
            listState.message!,
            retry: () => _cubit..search(query),
          );
        } else {
          return MemberListScrollView(
            key: const PageStorageKey('members-search'),
            controller: _controller,
            listState: listState,
            currentYear: _cubit.year,
            setYear: _cubit.filterYear,
          );
        }
      },
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
  final List<int> list =
      List.generate(
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
///
/// This does not take care of communicating with a Cubit. The [controller]
/// should do that. The [listState] also must not have an exception.
class MemberListScrollView extends StatelessWidget {
  final ScrollController controller;
  final MemberListState listState;
  final int? currentYear;
  final void Function(int?) setYear;

  const MemberListScrollView({
    super.key,
    required this.controller,
    required this.listState,
    required this.currentYear,
    required this.setYear,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      child: CustomScrollView(
        controller: controller,
        physics: const RangeMaintainingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(currentYear, setYear),
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
                (context, index) =>
                    MemberTile(member: listState.results[index]),
                childCount: listState.results.length,
              ),
            ),
          ),
          if (listState.isLoadingMore)
            const SliverPadding(
              padding: EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Center(child: CircularProgressIndicator()),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
