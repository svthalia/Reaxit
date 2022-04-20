import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/group_cubit.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/ui/widgets/cached_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes.dart';
import '../widgets/app_bar.dart';
import '../widgets/error_scroll_view.dart';
import '../widgets/member_tile.dart';

class GroupScreen extends StatefulWidget {
  final int pk;
  final Group? group;

  GroupScreen({required this.pk, this.group}) : super(key: ValueKey(pk));

  @override
  State createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  late final GroupCubit _groupCubit;

  @override
  void initState() {
    final api = RepositoryProvider.of<ApiRepository>(context);
    _groupCubit = GroupCubit(api, pk: widget.pk)..load();
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
            placeholder: 'assets/img/default-avatar.jpg')
      ],
    );
  }

  Widget _makeDescription(ListGroup group) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: HtmlWidget(
        group.description,
        onTapUrl: (String url) async {
          final uri = Uri(path: url);
          if (isDeepLink(uri)) {
            context.go(Uri(
              path: uri.path,
              query: uri.query,
            ).toString());
            return true;
          } else {
            try {
              await launch(
                url,
                forceSafariVC: false,
                forceWebView: false,
              );
            } catch (_) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Could not open "$url".'),
              ));
            }
            return true;
          }
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
            child: Center(
          child: Text('This group has no members.'),
        )),
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
                onRefresh: () async {
                  // Await the load.
                  await _groupCubit.load();
                },
                child: ErrorScrollView(state.message!),
              ),
            );
          } else if (state.isLoading &&
              widget.group == null &&
              state.result == null) {
            return Scaffold(
              appBar: ThaliaAppBar(
                title: const Text('GROUP'),
              ),
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
                      key: const PageStorageKey('event'),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _makeImage(group),
                              const Divider(height: 0),
                              _makeGroupInfo(group)
                              //const Divider(),
                              //_makeMembers(group.members)
                            ],
                          ),
                        ),
                        //_makeDescriptionHeader(group),
                        //const SliverToBoxAdapter(child: Divider()),
                        _makeMembersHeader(group),
                        _makeMembers(group.members),
                      ],
                    ),
                  )),
            );
          }
        });
  }
}
