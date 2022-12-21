import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/groups_cubit.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:collection/collection.dart';

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
      ),
      drawer: MenuDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocBuilder<CommitteesCubit, GroupsState>(
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
          BlocBuilder<SocietiesCubit, GroupsState>(
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
          BlocBuilder<BoardsCubit, GroupsState>(
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
      child: SafeCustomScrollView(
        physics: const RangeMaintainingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          if (activeBoard != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: GroupTile(group: activeBoard!),
                ),
              ),
            ),
          SliverGrid(
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
        ],
      ),
    );
  }
}
