import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/list_cubit.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';

class PaginatedScrollView<C extends SingleListCubit<S>, S>
    extends StatefulWidget {
  /// The default bloc to use for the blocbuilder. If not provided,
  /// the bloc is obtained from a [BlocProvider<C>].
  final C? cubit;

  /// A builder that creates a list of slivers from the results.
  ///
  /// For example, this could return a list with a single [SliverGrid].
  final List<Widget> Function(BuildContext context, List<S> results)
  resultsBuilder;

  /// An optional builder for a list of slivers to be shown when loading.
  ///
  /// If this is not provided, nothing will be shown.
  final List<Widget> Function(BuildContext context)? loadingBuilder;

  /// An optional builder for a list of slivers to be shown when an error occured.
  ///
  /// If this is not provided, the default error page will be shown.
  final List<Widget> Function(BuildContext context)? errorBuilder;

  const PaginatedScrollView({
    super.key,
    this.cubit,
    required this.resultsBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });
  @override
  State<StatefulWidget> createState() => _PaginatedScrollViewState<C, S>();
}

class _PaginatedScrollViewState<C extends SingleListCubit<S>, S>
    extends State<PaginatedScrollView<C, S>> {
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
    if (!controller.hasClients) {
      return;
    }

    final position = controller.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      final cubit = widget.cubit ?? BlocProvider.of<C>(context);
      cubit.more();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, ListState<S>>(
      bloc: widget.cubit,
      builder: (context, state) {
        late final List<Widget> slivers;

        if (state.hasException) {
          if (widget.errorBuilder == null) {
            final cubit = widget.cubit ?? BlocProvider.of<C>(context);
            return ErrorScrollView(
              state.message!,
              retry: state.retry ?? false ? cubit.load : null,
            );
          }

          slivers = widget.errorBuilder!(context);
        } else if (state.isLoading) {
          if (widget.loadingBuilder != null) {
            slivers = widget.loadingBuilder!(context);
          } else {
            slivers = [];
          }
        } else {
          final resultSlivers = widget.resultsBuilder(context, state.results);

          slivers = [
            ...resultSlivers,
            if (state.isLoadingMore)
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
