import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/ui/widgets.dart';

class MembersScreen extends StatefulWidget {
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late ScrollController _controller;
  late MemberListCubit _cubit;

  @override
  void initState() {
    _cubit = BlocProvider.of<MemberListCubit>(context);
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
        title: const Text('MEMBERS'),
        actions: [
          IconButton(
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.search),
            onPressed: () async {
              final searchCubit = MemberListCubit(
                RepositoryProvider.of<ApiRepository>(context),
              );

              await showSearch(
                context: context,
                delegate: MembersSearchDelegate(searchCubit),
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
        child: BlocBuilder<MemberListCubit, MemberListState>(
          builder: (context, listState) {
            if (listState.hasException) {
              return ErrorScrollView(listState.message!);
            } else {
              return MemberListScrollView(
                key: const PageStorageKey('members'),
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
  final MemberListCubit _cubit;
  late final ScrollController _controller;

  MembersSearchDelegate(this._cubit) {
    _controller = ScrollController()..addListener(_scrollListener);
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
  ThemeData appBarTheme(BuildContext context) {
    final theme = super.appBarTheme(context);
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        headline6: GoogleFonts.openSans(
          textStyle: Theme.of(context).textTheme.headline6,
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
    return BlocBuilder<MemberListCubit, MemberListState>(
      bloc: _cubit..search(query),
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return MemberListScrollView(
            key: const PageStorageKey('members-search'),
            controller: _controller,
            listState: listState,
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocBuilder<MemberListCubit, MemberListState>(
      bloc: _cubit..search(query),
      builder: (context, listState) {
        if (listState.hasException) {
          return ErrorScrollView(listState.message!);
        } else {
          return MemberListScrollView(
            key: const PageStorageKey('members-search'),
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
/// This does not take care of communicating with a Cubit. The [controller]
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
    return Scrollbar(
      controller: controller,
      child: SafeCustomScrollView(
        controller: controller,
        physics: const RangeMaintainingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverGrid(
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
          if (listState.isLoadingMore)
            const SliverPadding(
              padding: EdgeInsets.only(top: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Center(
                    child: CircularProgressIndicator(),
                  )
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
