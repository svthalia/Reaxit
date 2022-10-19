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

class GroupScreen extends StatefulWidget {
  final int pk;
  final Group? group;

  const GroupScreen({super.key, required this.pk, this.group});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  late final GroupCubit _groupCubit;

  @override
  void initState() {
    _groupCubit = GroupCubit(
      RepositoryProvider.of<ApiRepository>(context),
      pk: widget.pk,
    )..load();
    super.initState();
  }

  @override
  void dispose() {
    _groupCubit.close();
    super.dispose();
  }

  Widget _makeImage(ListGroup group) {
    return Stack(
      fit: StackFit.loose,
      children: [
        CachedImage(
          imageUrl: group.photo.full,
          placeholder: 'assets/img/default-avatar.jpg',
        )
      ],
    );
  }

  Widget _makeDescription(ListGroup group) {
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

  Widget _makeMembersHeader(ListGroup group) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16),
      sliver: SliverToBoxAdapter(
        child: Text(
          'MEMBERS',
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );
  }

  SliverPadding _makeMembers(List<ListMember> members) {
    if (members.isEmpty) {
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
                member: members[index],
              );
            },
            childCount: members.length,
          ),
        ),
      );
    }
  }

  Widget _makeGroupInfo(Group group) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            group.name.toUpperCase(),
            style: textTheme.headline6,
          ),
          const Divider(height: 24),
          _makeDescription(group),
          const Divider(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, GroupState>(
      bloc: _groupCubit,
      builder: (context, state) {
        if (state.hasException) {
          return Scaffold(
            appBar: ThaliaAppBar(
              title: Text(widget.group?.name.toUpperCase() ?? 'GROUP'),
            ),
            body: RefreshIndicator(
              onRefresh: () => _groupCubit.load(),
              child: ErrorScrollView(state.message!),
            ),
          );
        } else if (state.isLoading &&
            widget.group == null &&
            state.result == null) {
          return Scaffold(
            appBar: ThaliaAppBar(title: const Text('GROUP')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          final group = (state.result ?? widget.group)!;
          return Scaffold(
            appBar: ThaliaAppBar(title: Text(group.name.toUpperCase())),
            body: RefreshIndicator(
              onRefresh: () => _groupCubit.load(),
              child: Scrollbar(
                child: CustomScrollView(
                  key: const PageStorageKey('group'),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _makeImage(group),
                          const Divider(height: 0),
                          _makeGroupInfo(group)
                        ],
                      ),
                    ),
                    _makeMembersHeader(group),
                    _makeMembers(group.members),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
