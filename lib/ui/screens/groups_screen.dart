import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/blocs/groups_cubit.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/group_tile.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';
import 'package:collection/collection.dart';

class GroupsScreen extends StatefulWidget {
  final MemberGroupType? startScreen;

  const GroupsScreen({this.startScreen});

  @override
  State<StatefulWidget> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    late final int initialIndex;
    if (widget.startScreen == MemberGroupType.board) {
      initialIndex = 0;
    } else if (widget.startScreen == MemberGroupType.committee) {
      initialIndex = 1;
    } else if (widget.startScreen == MemberGroupType.society) {
      initialIndex = 2;
    } else {
      initialIndex = 0;
    }

    _tabController = TabController(
      length: 3,
      initialIndex: initialIndex,
      vsync: this,
    );

    super.initState();
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
      ),
      drawer: MenuDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocBuilder<CommitteesCubit, DetailState<List<ListGroup>>>(
            builder: (context, state) {
              if (state.hasException) {
                return ErrorScrollView(state.message!);
              } else if (state.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return GroupListScrollView(groups: state.result!);
              }
            },
          ),
          BlocBuilder<SocietiesCubit, DetailState<List<ListGroup>>>(
            builder: (context, state) {
              if (state.hasException) {
                return ErrorScrollView(state.message!);
              } else if (state.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return GroupListScrollView(groups: state.result!);
              }
            },
          ),
          BlocBuilder<BoardsCubit, DetailState<List<ListGroup>>>(
            builder: (context, state) {
              if (state.hasException) {
                return ErrorScrollView(state.message!);
              } else if (state.isLoading) {
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