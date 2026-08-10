import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/models/album.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:reaxit/ui/widgets/paginated_scroll_view.dart';

class AlbumsScreen extends StatefulWidget {
  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  late AlbumListCubit _cubit;

  @override
  void initState() {
    _cubit = BlocProvider.of<AlbumListCubit>(context);
    super.initState();
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
          IconAppbarAction('SEARCH', Icons.search, () async {
            final searchCubit = AlbumListCubit(
              RepositoryProvider.of<ApiRepository>(context),
            );

            await showSearch(
              context: context,
              delegate: AlbumsSearchDelegate(searchCubit),
            );

            searchCubit.close();
          }),
        ],
      ),
      drawer: MenuDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _cubit.load();
        },
        child: AlbumListScrollView(
          key: const PageStorageKey('albums'),
          cubit: _cubit,
        ),
      ),
    );
  }
}

class AlbumsSearchDelegate extends SearchDelegate {
  final AlbumListCubit _cubit;

  AlbumsSearchDelegate(this._cubit);

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
        ),
      ];
    } else {
      return [];
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    _cubit.search(query);
    return AlbumListScrollView(
      key: const PageStorageKey('albums-search'),
      cubit: _cubit,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

/// A ScrollView that shows a grid of [AlbumTile]s.
class AlbumListScrollView
    extends PaginatedScrollView<AlbumListCubit, ListAlbum> {
  const AlbumListScrollView({super.key, super.cubit})
    : super(resultsBuilder: buildResults);

  static List<Widget> buildResults(
    BuildContext context,
    List<ListAlbum> albums,
  ) {
    return [
      SliverPadding(
        padding: const EdgeInsets.all(8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => AlbumTile(album: albums[index]),
            childCount: albums.length,
          ),
        ),
      ),
    ];
  }
}
