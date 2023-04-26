import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/routes.dart';
import 'package:reaxit/ui/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupScreen extends StatelessWidget {
  final ListGroup? group;

  // By PK
  final int? pk;

  // By slug
  final MemberGroupType? groupType;
  final String? slug;

  // Default: by PK
  const GroupScreen({
    super.key,
    this.group,
    required this.pk,
  })  : groupType = null,
        slug = null;

  // Alternative: by Slug
  const GroupScreen.bySlug(
      {super.key, this.group, required this.groupType, required this.slug})
      : pk = null;

  GroupCubit _selectCubit(BuildContext context) {
    if (pk != null) {
      return GroupCubit(
        RepositoryProvider.of<ApiRepository>(context),
        pk: pk!,
      )..load();
    } else {
      return GroupCubit.bySlug(
        RepositoryProvider.of<ApiRepository>(context),
        groupType: groupType!,
        slug: slug!,
      )..load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupCubit>(
      create: (BuildContext context) {
        _selectCubit(context);
      },
      child: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, state) => _Page(
            state: state,
            cubit: BlocProvider.of<GroupCubit>(context),
            listGroup: group),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    Key? key,
    required this.state,
    required this.cubit,
    this.listGroup,
  }) : super(key: key);

  final DetailState<Group> state;
  final GroupCubit cubit;
  final ListGroup? listGroup;

  @override
  Widget build(BuildContext context) {
    if (state is ErrorState) {
      return Scaffold(
        appBar: ThaliaAppBar(
          title: Text(listGroup?.name.toUpperCase() ?? 'GROUP'),
        ),
        body: RefreshIndicator(
          onRefresh: () => cubit.load(),
          child: ErrorScrollView(state.message!),
        ),
      );
    } else if (state is LoadingState &&
        state is! ResultState &&
        listGroup == null) {
      return Scaffold(
        appBar: ThaliaAppBar(title: const Text('GROUP')),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (state is LoadingState &&
        state is! ResultState &&
        listGroup != null) {
      final group = listGroup!;
      return Scaffold(
        appBar: ThaliaAppBar(title: Text(group.name.toUpperCase())),
        body: RefreshIndicator(
          onRefresh: () => cubit.load(),
          child: Scrollbar(
            child: CustomScrollView(
              key: const PageStorageKey('group'),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GroupImage(group: group),
                      const Divider(height: 0),
                      _GroupInfo(group: group)
                    ],
                  ),
                ),
                _MembersHeader(group: group),
                const _MembersGrid(members: null),
              ],
            ),
          ),
        ),
      );
    } else {
      final group = (state.result)!;
      return Scaffold(
        appBar: ThaliaAppBar(title: Text(group.name.toUpperCase())),
        body: RefreshIndicator(
          onRefresh: () => cubit.load(),
          child: Scrollbar(
            child: CustomScrollView(
              key: const PageStorageKey('group'),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GroupImage(group: group),
                      const Divider(height: 0),
                      _GroupInfo(group: group)
                    ],
                  ),
                ),
                _MembersHeader(group: group),
                _MembersGrid(members: group.members),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _MembersHeader extends StatelessWidget {
  const _MembersHeader({
    Key? key,
    required this.group,
  }) : super(key: key);

  final ListGroup group;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16),
      sliver: SliverToBoxAdapter(
        child: Text(
          'MEMBERS',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _GroupImage extends StatelessWidget {
  const _GroupImage({
    Key? key,
    required this.group,
  }) : super(key: key);

  final ListGroup group;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        CachedImage(
          imageUrl: group.photo.large,
          placeholder: 'assets/img/default-avatar.jpg',
        )
      ],
    );
  }
}

class _MembersGrid extends StatelessWidget {
  const _MembersGrid({
    Key? key,
    this.members,
  }) : super(key: key);

  final List<GroupMembership>? members;

  @override
  Widget build(BuildContext context) {
    if (members == null) {
      return const SliverPadding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
        sliver: SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else if (members!.isEmpty) {
      return const SliverPadding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
        sliver: SliverToBoxAdapter(
          child: Center(child: Text('This group has no members.')),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return MemberTile(
                member: members![index].member,
              );
            },
            childCount: members!.length,
          ),
        ),
      );
    }
  }
}

class _GroupInfo extends StatelessWidget {
  const _GroupInfo({
    Key? key,
    required this.group,
  }) : super(key: key);

  final ListGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                group.name.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(height: 24),
              _Description(group: group),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    Key? key,
    required this.group,
  }) : super(key: key);

  final ListGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: HtmlWidget(
        group.description,
        onTapUrl: (String url) async {
          Uri uri = Uri.parse(url);
          if (uri.scheme.isEmpty) uri = uri.replace(scheme: 'https');
          if (isDeepLink(uri)) {
            context.go(Uri(
              path: uri.path,
              query: uri.query,
            ).toString());
            return true;
          } else {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {
              messenger.showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Could not open "$url".'),
              ));
            }
          }
          return true;
        },
      ),
    );
  }
}
