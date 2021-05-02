import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/boards_cubit.dart';
import 'package:reaxit/blocs/committees_cubit.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/blocs/group_list_bloc.dart';
import 'package:reaxit/blocs/societies_cubit.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';

class GroupsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: MenuDrawer(),
        appBar: ThaliaAppBar(
          title: Text('Groups'),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: GroupsSearchDelegate(
                    GroupListBloc(
                      RepositoryProvider.of<ApiRepository>(context),
                    )..add(GroupListEvent.load()),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Committees'),
              Tab(text: 'Societies'),
              Tab(text: 'Boards'),
            ],
          ),
        ),
        body: TabBarView(
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
            ),
          ],
        ),
      ),
    );
  }
}

class GroupsSearchDelegate extends SearchDelegate {
  late final ScrollController _controller;
  final GroupListBloc _bloc;

  GroupsSearchDelegate(this._bloc) {
    _controller = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      // TODO: add a range, so we start fetching before scrolling to the very end.
      _bloc.add(GroupListEvent.more());
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          tooltip: 'Clear search bar',
          icon: Icon(Icons.delete),
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
    return CloseButton(
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _bloc.add(GroupListEvent.load(search: query));
    return BlocBuilder<GroupListBloc, GroupListState>(
      bloc: _bloc,
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return GroupListScrollView(
            controller: _controller,
            listState: listState,
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _bloc.add(GroupListEvent.load(search: query));
    return BlocBuilder<GroupListBloc, GroupListState>(
      bloc: _bloc,
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return GroupListScrollView(
            controller: _controller,
            listState: listState,
          );
        }
      },
    );
  }
}

/// A ScrollView that shows a grid of [GroupTile]s.
///
/// This does not take care of communicating with a Bloc. The [controller]
/// should do that. The [listState] also must not have an exception.
class GroupListScrollView extends StatelessWidget {
  final ScrollController controller;
  final GroupListState listState;

  const GroupListScrollView({
    Key? key,
    required this.controller,
    required this.listState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(10),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text(listState.results[index].name),
              ),
              childCount: listState.results.length,
            ),
          ),
        ),
        if (listState.isLoadingMore)
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Center(
                  child: CircularProgressIndicator(),
                )
              ]),
            ),
          ),
      ],
    );
  }
}
