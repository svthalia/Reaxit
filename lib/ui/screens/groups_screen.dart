import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/blocs/groups_cubit.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:collection/collection.dart';

import '../../api/api_repository.dart';

class GroupsScreen extends StatefulWidget {
  final MemberGroupType? currentScreen;

  const GroupsScreen({Key? key, this.currentScreen}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      length: 3,
      initialIndex: _groupTypeToIndex(widget.currentScreen),
      vsync: this,
    );

    super.initState();
  }

  int _groupTypeToIndex(MemberGroupType? group) {
    if (group == MemberGroupType.committee) {
      return 0;
    } else if (group == MemberGroupType.society) {
      return 1;
    } else if (group == MemberGroupType.board) {
      return 2;
    } else {
      return 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GroupsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController.index = _groupTypeToIndex(widget.currentScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('GROUPS'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Committees'),
            Tab(text: 'Societies'),
            Tab(text: 'Boards'),
          ],
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.search),
            onPressed: () async {
              final searchCubit =
                  AllGroupsCubit(RepositoryProvider.of<ApiRepository>(context));

              await showSearch(
                context: context,
                delegate: GroupSearchDelegate(searchCubit),
              );

              searchCubit.close();
            },
          )
        ],
      ),
      drawer: MenuDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocBuilder<CommitteesCubit, GroupsState>(
            builder: (context, state) {
              if (state is ErrorState) {
                return ErrorScrollView(state.message!);
              } else if (state is LoadingState) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return GroupListScrollView(groups: state.result!);
              }
            },
          ),
          BlocBuilder<SocietiesCubit, GroupsState>(
            builder: (context, state) {
              if (state is ErrorState) {
                return ErrorScrollView(state.message!);
              } else if (state is LoadingState) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return GroupListScrollView(groups: state.result!);
              }
            },
          ),
          BlocBuilder<BoardsCubit, GroupsState>(
            builder: (context, state) {
              if (state is ErrorState) {
                return ErrorScrollView(state.message!);
              } else if (state is LoadingState) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return GroupListScrollView(groups: state.result!);
              }
            },
          )
        ],
      ),
    );
  }
}

class GroupListScrollView extends StatelessWidget {
  final List<ListGroup> groups;
  final ListGroup? activeBoard;

  GroupListScrollView({Key? key, required List<ListGroup> groups})
      : activeBoard = groups.firstWhereOrNull(
          (element) => element.isActiveBoard(),
        ),
        groups = groups
            .where((element) => !element.isActiveBoard())
            .toList()
            .reversed
            .toList(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          if (activeBoard != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: GroupTile(group: activeBoard!),
                ),
              ),
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
                (context, index) => GroupTile(group: groups[index]),
                childCount: groups.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupSearchDelegate extends SearchDelegate {
  final AllGroupsCubit _cubit;

  GroupSearchDelegate(this._cubit);

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
        )
      ];
    } else {
      return [];
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocBuilder<AllGroupsCubit, GroupsState>(
      bloc: _cubit..search(query),
      builder: (context, state) {
        if (state is ErrorState) {
          return ErrorScrollView(state.message!);
        } else {
          return GroupListScrollView(
            key: const PageStorageKey('groups-search'),
            groups: state.result ?? [],
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocBuilder<GroupsCubit, GroupsState>(
      bloc: _cubit..search(query),
      builder: (context, state) {
        if (state is ErrorState) {
          return ErrorScrollView(state.message!);
        } else {
          return GroupListScrollView(
            key: const PageStorageKey('groups-search'),
            groups: state.result ?? [],
          );
        }
      },
    );
    //return const Text('TODO');
  }
}
