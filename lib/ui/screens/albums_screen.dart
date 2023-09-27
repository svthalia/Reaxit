import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/ui/widgets.dart';

class AlbumsScreen extends StatefulWidget {
  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  late ScrollController _controller;
  late AlbumListCubit _cubit;

  @override
  void initState() {
    _cubit = BlocProvider.of<AlbumListCubit>(context);
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
        title: const Text('ALBUMS'),
        collapsingActions: [
          IconAppbarAction(
            'LIKED PHOTOS',
            Icons.favorite_border,
            () => context.pushNamed('liked-photos'),
          ),
          IconAppbarAction(
            'SEARCH',
            Icons.search,
            () async {
              final searchCubit = AlbumListCubit(
                RepositoryProvider.of<ApiRepository>(context),
              );

              await showSearch(
                context: context,
                delegate: AlbumsSearchDelegate(searchCubit),
              );

              searchCubit.close();
            },
          ),
        ],
      ),
      drawer: MenuDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _cubit.load();
        },
        child: BlocBuilder<AlbumListCubit, AlbumListState>(
          builder: (context, listState) {
            if (listState.hasException) {
              return ErrorScrollView(listState.message!);
            } else {
              return AlbumListScrollView(
                key: const PageStorageKey('albums'),
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
  final AlbumListCubit _cubit;

  AlbumsSearchDelegate(this._cubit) {
    _controller = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_controller.hasClients) {
      return;
    }
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
    return BlocBuilder<AlbumListCubit, AlbumListState>(
      bloc: _cubit..search(query),
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return AlbumListScrollView(
            key: const PageStorageKey('albums-search'),
            controller: _controller,
            listState: listState,
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocBuilder<AlbumListCubit, AlbumListState>(
      bloc: _cubit..search(query),
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return AlbumListScrollView(
            key: const PageStorageKey('albums-search'),
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
    return Scrollbar(
        controller: controller,
        child: CustomScrollView(
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
                  (context, index) => AlbumTile(
                    album: listState.results[index],
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
        ));
  }
}
