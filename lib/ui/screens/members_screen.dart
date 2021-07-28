import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/member_list_bloc.dart';
import 'package:reaxit/ui/widgets/app_bar.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/member_tile.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';

class MembersScreen extends StatefulWidget {
  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late ScrollController _controller;
  late MemberListBloc _memberListBloc;

  @override
  void initState() {
    _memberListBloc = BlocProvider.of<MemberListBloc>(context);
    _controller = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      // Only request loading more if that's not already happening.
      if (!_memberListBloc.state.isLoadingMore) {
        _memberListBloc.add(const MemberListEvent.more());
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
          _memberListBloc.add(const MemberListEvent.load());
          await _memberListBloc.stream.firstWhere(
            (state) => !state.isLoading,
          );
        },
        child: BlocBuilder<MemberListBloc, MemberListState>(
          builder: (context, listState) {
            if (listState.hasException) {
              return ErrorScrollView(listState.message!);
            } else {
              return MemberListScrollView(
                controller: _controller,
                listState: listState,
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
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      // Only request loading more if that's not already happening.
      if (!_bloc.state.isLoadingMore) {
        _bloc.add(const MemberListEvent.more());
      }
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          tooltip: 'Clear search bar',
          icon: const Icon(Icons.delete),
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
    _bloc.add(MemberListEvent.load(search: query));
    return BlocBuilder<MemberListBloc, MemberListState>(
      bloc: _bloc,
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return MemberListScrollView(
            controller: _controller,
            listState: listState,
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
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return MemberListScrollView(
            controller: _controller,
            listState: listState,
          );
        }
      },
    );
  }
}

/// A ScrollView that shows a grid of [MemberTile]s.
///
/// This does not take care of communicating with a Bloc. The [controller]
/// should do that. The [listState] also must not have an exception.
class MemberListScrollView extends StatelessWidget {
  final ScrollController controller;
  final MemberListState listState;

  const MemberListScrollView({
    Key? key,
    required this.controller,
    required this.listState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
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
              (context, index) => MemberTile(
                member: listState.results[index],
              ),
              childCount: listState.results.length,
            ),
          ),
        ),
        if (listState.isLoadingMore)
          const SliverPadding(
            padding: EdgeInsets.all(8),
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
