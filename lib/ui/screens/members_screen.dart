import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/member_list_bloc.dart';
import 'package:reaxit/ui/error_scroll_view.dart';
import 'package:reaxit/ui/member_tile.dart';
import 'package:reaxit/ui/menu_drawer.dart';

class MembersScreen extends StatefulWidget {
  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late ScrollController _controller;
  late MemberListBloc _memberListBloc;

  @override
  void initState() {
    _memberListBloc = BlocProvider.of<MemberListBloc>(context, listen: false);
    _controller = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      BlocProvider.of<MemberListBloc>(context).add(MemberListEvent.more());
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
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MembersSearchDelegate(
                  MemberListBloc(
                    RepositoryProvider.of<ApiRepository>(
                      context,
                      listen: false,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: MenuDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          _memberListBloc.add(MemberListEvent.load());
          await _memberListBloc.stream.firstWhere(
            (state) => !state.isLoading,
          );
        },
        child: BlocBuilder<MemberListBloc, MemberListState>(
          builder: (context, listState) {
            print(listState);
            if (listState.hasException) {
              return ErrorScrollView(listState.message!);
            } else {
              return CustomScrollView(
                controller: _controller,
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
                        (context, index) => MemberTile(
                          member: listState.results[index],
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
          },
        ),
      ),
    );
  }
}

class MembersSearchDelegate extends SearchDelegate {
  final MemberListBloc _bloc;
  late final ScrollController _controller;

  MembersSearchDelegate(this._bloc) {
    _controller = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      // TODO: take search query from state if the event is more
      _bloc.add(MemberListEvent.more());
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
    // TODO: make sure we dont search again with the same query, either here or inside the bloc.
    _bloc.add(MemberListEvent.load(search: query));
    return BlocBuilder<MemberListBloc, MemberListState>(
      bloc: _bloc,
      builder: (context, listState) {
        print(listState);
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return CustomScrollView(
            controller: _controller,
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
                    (context, index) => MemberTile(
                      member: listState.results[index],
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
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _bloc.add(MemberListEvent.load(search: query));
    return BlocBuilder<MemberListBloc, MemberListState>(
      bloc: _bloc,
      builder: (context, listState) {
        print(listState);
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return CustomScrollView(
            controller: _controller,
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
                    (context, index) => MemberTile(
                      member: listState.results[index],
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
      },
    );
  }
}
