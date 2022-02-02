import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/blocs/boards_cubit.dart';
import 'package:reaxit/blocs/committees_cubit.dart';
import 'package:reaxit/blocs/societies_cubit.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/group_tile.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';

class GroupsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaliaAppBar(
        title: const Text('GROUPS'),
        actions: [
          IconButton(
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.search),
            onPressed: () async {
              //TODO: Implement group search
            },
          ),
        ],
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
                return Text('exception');
              } else if (state.isLoading) {
                return Text('loading');
              } else {
                return GroupListScrollView(groups: state.result!);
              }
            },
          ),
          BlocBuilder<SocietiesCubit, DetailState<List<ListGroup>>>(
            builder: (context, state) {
              if (state.hasException) {
                return Text('exception');
              } else if (state.isLoading) {
                return Text('loading');
              } else {
                return GroupListScrollView(groups: state.result!);
              }
            },
          ),
          BlocBuilder<BoardsCubit, DetailState<List<ListGroup>>>(
            builder: (context, state) {
              if (state.hasException) {
                return Text('exception');
              } else if (state.isLoading) {
                return Text('loading');
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

  const GroupListScrollView({
    Key? key,
    required this.groups
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        child: CustomScrollView(
          physics: const RangeMaintainingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => GroupTile(group: groups[index],
                      ),
                  childCount: groups.length,
                ),
              ),
            ),
          ],
        ));
  }
}
