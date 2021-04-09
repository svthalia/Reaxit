import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/album_list_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/ui/widgets/album_tile.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';
import 'package:reaxit/ui/widgets/menu_drawer.dart';

class AlbumsScreen extends StatefulWidget {
  @override
  _AlbumsScreenState createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  late ScrollController _controller;
  late AlbumListBloc _bloc;

  @override
  void initState() {
    _bloc = BlocProvider.of<AlbumListBloc>(context, listen: false);
    _controller = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      _bloc.add(AlbumListEvent.more());
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
        title: Text('Albums'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AlbumsSearchDelegate(
                  AlbumListBloc(
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
          _bloc.add(AlbumListEvent.load());
          await _bloc.stream.firstWhere(
            (state) => !state.isLoading,
          );
        },
        child: BlocBuilder<AlbumListBloc, AlbumListState>(
          builder: (context, listState) {
            if (listState.hasException) {
              return ErrorScrollView(listState.message!);
            } else {
              return AlbumListScrollView(
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

class AlbumsSearchDelegate extends SearchDelegate {
  late final ScrollController _controller;
  final AlbumListBloc _bloc;

  AlbumsSearchDelegate(this._bloc) {
    _controller = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      // TODO: add a range, so we start fetching before scrolling to the very end.
      _bloc.add(AlbumListEvent.more());
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
    _bloc.add(AlbumListEvent.load(search: query));
    return BlocBuilder<AlbumListBloc, AlbumListState>(
      bloc: _bloc,
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return AlbumListScrollView(
            controller: _controller,
            listState: listState,
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _bloc.add(AlbumListEvent.load(search: query));
    return BlocBuilder<AlbumListBloc, AlbumListState>(
      bloc: _bloc,
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return AlbumListScrollView(
            controller: _controller,
            listState: listState,
          );
        }
      },
    );
  }
}

/// A ScrollView that shows a grid of [AlbumTile]s.
///
/// This does not take care of communicating with a Bloc. The [controller]
/// should do that. The [listState] also must not have an exception.
class AlbumListScrollView extends StatelessWidget {
  final ScrollController controller;
  final AlbumListState listState;

  const AlbumListScrollView({
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
              (context, index) => AlbumTile(
                album: listState.results[index],
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
