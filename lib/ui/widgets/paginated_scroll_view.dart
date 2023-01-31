import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/list_state.dart';

abstract class PaginatedCubit<E> extends Cubit<ListState<E>> {
  final int firstPageSize;
  final int pageSize;

  PaginatedCubit({
    required this.firstPageSize,
    required this.pageSize,
  }) : super(const LoadingListState());

  /// Load the first page of results.
  Future<void> load();

  /// Load another page of results.
  Future<void> more();
}

/// A widget that displays and triggers loading of a paginated list.
class PaginatedScrollView<E, B extends PaginatedCubit<E>>
    extends StatefulWidget {
  const PaginatedScrollView({
    super.key,
    required this.resultsBuilder,
    this.loadingBuilder,
  });

  /// A builder that creates a list of slivers from the results.
  ///
  /// For example, this could return a list with a single [SliverGrid].
  final List<Widget> Function(
    BuildContext context,
    List<E> results,
  ) resultsBuilder;

  /// An optional builder for a list of slivers to be shown when loading.
  ///
  /// If this is not provided, nothing will be shown.
  final List<Widget> Function(BuildContext context)? loadingBuilder;

  @override
  State<PaginatedScrollView<E, B>> createState() =>
      _PaginatedScrollViewState<E, B>();
}

class _PaginatedScrollViewState<E, B extends PaginatedCubit<E>>
    extends State<PaginatedScrollView<E, B>> {
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
      final cubit = BlocProvider.of<B>(context);
      final state = cubit.state;
      if (state is ResultsListState &&
          state is! DoneListState &&
          state is! LoadingMoreListState) {
        cubit.more();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, ListState<E>>(
      builder: (context, state) {
        late final List<Widget> slivers;
        if (state is ErrorListState) {
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
                    Text(state.message!, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ];
        } else if (state is LoadingListState) {
          if (widget.loadingBuilder != null) {
            slivers = widget.loadingBuilder!(context);
          } else {
            slivers = [];
          }
        } else {
          final resultSlivers = widget.resultsBuilder(context, state.results);

          slivers = [
            ...resultSlivers,
            if (state is LoadingMoreListState)
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
      },
    );
  }
}
