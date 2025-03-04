import 'package:flutter/gestures.dart';
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
  const GroupScreen({super.key, this.group, required this.pk})
    : groupType = null,
      slug = null;

  // Alternative: by Slug
  const GroupScreen.bySlug({
    super.key,
    this.group,
    required this.groupType,
    required this.slug,
  }) : pk = null;

  GroupCubit _selectCubit(BuildContext context) {
    if (pk != null) {
      return GroupCubit(RepositoryProvider.of<ApiRepository>(context), pk: pk!)
        ..load();
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
      create: _selectCubit,
      child: BlocBuilder<GroupCubit, GroupState>(
        builder:
            (context, state) => _Page(
              state: state,
              cubit: BlocProvider.of<GroupCubit>(context),
              listGroup: group,
            ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.state, required this.cubit, this.listGroup});

  final DetailState<Group> state;
  final GroupCubit cubit;
  final ListGroup? listGroup;

  @override
  Widget build(BuildContext context) {
    final body = switch (state) {
      ErrorState(message: var message) => RefreshIndicator(
        onRefresh: () => cubit.load(),
        child: ErrorScrollView(message),
      ),
      LoadingState _ when listGroup == null => const Center(
        child: CircularProgressIndicator(),
      ),
      LoadingState _ => Scrollbar(
        child: CustomScrollView(
          key: const PageStorageKey('group'),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GroupImage(group: listGroup!),
                  const Divider(height: 0),
                  _GroupInfo(group: listGroup!),
                ],
              ),
            ),
            _MembersHeader(group: listGroup!),
            const _MembersGrid(members: null),
          ],
        ),
      ),
      ResultState(result: var result) => RefreshIndicator(
        onRefresh: () => cubit.load(),
        child: Scrollbar(
          child: CustomScrollView(
            key: const PageStorageKey('group'),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _GroupImage(group: result),
                    const Divider(height: 0),
                    _GroupInfo(group: result),
                  ],
                ),
              ),
              _MembersHeader(group: result),
              _MembersGrid(members: result.members),
            ],
          ),
        ),
      ),
    };
    return Scaffold(
      appBar: ThaliaAppBar(
        title: Text(listGroup?.name.toUpperCase() ?? 'GROUP'),
      ),
      body: body,
    );
  }
}

class _MembersHeader extends StatelessWidget {
  const _MembersHeader({required this.group});

  final ListGroup group;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16),
      sliver: SliverToBoxAdapter(
        child: Text('MEMBERS', style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}

class _GroupImage extends StatelessWidget {
  const _GroupImage({required this.group});

  final ListGroup group;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        CachedImage(
          imageUrl: group.photo.large,
          placeholder: 'assets/img/default-avatar.jpg',
        ),
      ],
    );
  }
}

class _MembersGrid extends StatelessWidget {
  const _MembersGrid({this.members});

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
          delegate: SliverChildBuilderDelegate((context, index) {
            return MemberTile(member: members![index].member);
          }, childCount: members!.length),
        ),
      );
    }
  }
}

class _GroupInfo extends StatelessWidget {
  const _GroupInfo({required this.group});

  final ListGroup group;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CONTACT', style: textTheme.bodySmall),
                        const SizedBox(height: 4),
                        SelectableText.rich(
                          TextSpan(
                            text: group.contactAddress,
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                      Uri.parse(
                                        'mailto:${group.contactAddress}',
                                      ),
                                    );
                                  },
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
  const _Description({required this.group});

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
            context.go(Uri(path: uri.path, query: uri.query).toString());
            return true;
          } else {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {
              messenger.showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Could not open "$url".'),
                ),
              );
            }
          }
          return true;
        },
      ),
    );
  }
}
