import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/blocs/boards_cubit.dart';
import 'package:reaxit/blocs/committees_cubit.dart';
import 'package:reaxit/blocs/societies_cubit.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
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
                return ListView.builder(
                  itemCount: state.result!.length,
                  itemBuilder: (context, index) {
                    final group = state.result![index];
                    return ListTile(title: Text(group.name));
                  },
                );
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
                return ListView.builder(
                  itemCount: state.result!.length,
                  itemBuilder: (context, index) {
                    final group = state.result![index];
                    return ListTile(title: Text(group.name));
                  },
                );
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
                return ListView.builder(
                  itemCount: state.result!.length,
                  itemBuilder: (context, index) {
                    final group = state.result![index];
                    return ListTile(title: Text(group.name));
                  },
                );
              }
            },
          )
        ],
      ),
    );
  }
}
