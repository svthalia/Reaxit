import 'package:flutter/material.dart';
import 'package:reaxit/blocs/list_state.dart';

/// A widget that displays and triggers loading of a paginated list.
class PaginatedScrollView<T> extends StatefulWidget {
  const PaginatedScrollView({
    super.key,
    required this.state,
    required this.onLoadMore,
    required this.resultsBuilder,
    this.loadingBuilder,
  });

  final XListState<T> state;

  /// A builder that creates a list of slivers from the results.
  ///
  /// For example, this could return a list with a single [SliverGrid].
  final List<Widget> Function(
    BuildContext context,
    List<T> results,
  ) resultsBuilder;

  /// An optional builder for a list of slivers to be shown when loading.
  ///
  /// If this is not provided, nothing will be shown.
  final List<Widget> Function(BuildContext context)? loadingBuilder;

  /// A callback that is called when more results should be loaded.
  ///
  /// This should trigger the loading of another page of results.
  /// This is only called when the current state is [ResultsListState],
  /// not from [LoadingMoreListState] or [DoneListState].
  final void Function(BuildContext context) onLoadMore;

  @override
  State<PaginatedScrollView<T>> createState() => _PaginatedScrollViewState<T>();
}

class _PaginatedScrollViewState<T> extends State<PaginatedScrollView<T>> {
  late ScrollController controller;

  @override
  void initState() {
    controller = ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final position = controller.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      if (widget.state is ResultsListState &&
          widget.state is! DoneListState &&
          widget.state is! LoadingMoreListState) {
        widget.onLoadMore(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    late final List<Widget> slivers;
    if (widget.state is ErrorListState) {
      slivers = [
        SliverSafeArea(
          minimum: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  height: 100,
                  margin: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/img/sad-cloud.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Text(widget.state.message!, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ];
    } else if (widget.state is LoadingListState) {
      if (widget.loadingBuilder != null) {
        slivers = widget.loadingBuilder!(context);
      } else {
        slivers = [];
      }
    } else {
      final resultsSlivers = widget.resultsBuilder(
        context,
        widget.state.results,
      );

      slivers = [
        ...resultsSlivers,
        if (widget.state is LoadingMoreListState)
          const SliverPadding(
            padding: EdgeInsets.only(top: 16),
            sliver: SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        const SliverSafeArea(
          minimum: EdgeInsets.only(bottom: 8),
          sliver: SliverPadding(padding: EdgeInsets.zero),
        ),
      ];
    }

    return Scrollbar(
      controller: controller,
      child: CustomScrollView(
        controller: controller,
        physics: const RangeMaintainingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: slivers,
      ),
    );
  }
}
