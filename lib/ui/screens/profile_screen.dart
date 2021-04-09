import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/blocs/member_cubit.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/ui/widgets/error_scroll_view.dart';

class ProfileScreen extends StatefulWidget {
  final int pk;
  final ListMember? member;

  const ProfileScreen({Key? key, required this.pk, this.member})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final MemberCubit _cubit;

  @override
  void initState() {
    _cubit = MemberCubit(
      RepositoryProvider.of<ApiRepository>(context),
    )..load(widget.pk);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MemberCubit, DetailState<Member>>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.hasException) {
            return ErrorScrollView(state.message!);
          } else if (state.isLoading && widget.member == null) {
            return CustomScrollView(
              slivers: [
                _ProfileAppBar(pk: widget.pk),
                SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          } else {
            return CustomScrollView(
              slivers: [
                _ProfileAppBar(
                  pk: widget.pk,
                  member: (state.result ?? widget.member)!,
                ),
                SliverPadding(
                  padding: EdgeInsets.all(10),
                  sliver: SliverToBoxAdapter(
                    child: Center(child: Text('Facts')),
                  ),
                ),
                if (!state.isLoading) ...[
                  SliverPadding(
                    padding: EdgeInsets.all(10),
                    sliver: SliverToBoxAdapter(
                      child: Center(child: Text('Achievements')),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(10),
                    sliver: SliverToBoxAdapter(
                      child: Center(child: Text('Societies')),
                    ),
                  ),
                ] else
                  SliverPadding(
                    padding: EdgeInsets.all(10),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}

class _ProfileAppBar extends SliverAppBar {
  final ListMember? member;
  final int pk;

  _ProfileAppBar({required this.pk, this.member})
      : super(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(member?.displayName ?? 'Profile'),
            background: Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: member != null
                      ? () => _showAvatarView(context, member)
                      : null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'member_$pk',
                        child: member != null
                            ? FadeInImage.assetNetwork(
                                placeholder: 'assets/img/default-avatar.jpg',
                                image: member.photo.full,
                                fit: BoxFit.cover,
                                fadeInDuration:
                                    const Duration(milliseconds: 300),
                              )
                            : Image.asset(
                                'assets/img/default-avatar.jpg',
                                fit: BoxFit.cover,
                              ),
                      ),
                      _BlackGradient()
                    ],
                  ),
                );
              },
            ),
          ),
        );

  static void _showAvatarView(BuildContext context, ListMember member) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return Scaffold(
          body: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(member.photo.full),
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'member_${member.pk}',
                ),
                backgroundDecoration: BoxDecoration(color: Colors.transparent),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 1.2,
              ),
              CloseButton(
                color: Theme.of(context).primaryIconTheme.color,
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
        );
      },
    );
  }
}

class _BlackGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        gradient: LinearGradient(
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.3),
          ],
          stops: [0.5, 1.0],
        ),
      ),
    );
  }
}
