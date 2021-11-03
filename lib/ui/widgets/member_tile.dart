import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/cache_manager.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/ui/screens/profile_screen.dart';

class MemberTile extends StatelessWidget {
  final ListMember member;

  const MemberTile({Key? key, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      tappable: false,
      routeSettings: RouteSettings(name: 'Profile(${member.pk})'),
      transitionType: ContainerTransitionType.fadeThrough,
      closedShape: const RoundedRectangleBorder(),
      closedBuilder: (context, openContainer) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              cacheManager: ThaliaCacheManager(),
              cacheKey: Uri.parse(
                member.photo.small,
              ).replace(query: '').toString(),
              imageUrl: member.photo.small,
              fit: BoxFit.cover,
              fadeOutDuration: const Duration(milliseconds: 200),
              fadeInDuration: const Duration(milliseconds: 200),
              placeholder: (_, __) => Image.asset(
                'assets/img/default-avatar.jpg',
                fit: BoxFit.cover,
              ),
            ),
            const _BlackGradient(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  member.displayName,
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: openContainer),
              ),
            ),
          ],
        );
      },
      openBuilder: (_, __) => ProfileScreen(pk: member.pk, member: member),
    );
  }
}

class _BlackGradient extends StatelessWidget {
  static const _black00 = Color(0x00000000);
  static const _black50 = Color(0x80000000);

  const _BlackGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        gradient: LinearGradient(
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          colors: [_black00, _black50],
          stops: [0.4, 1.0],
        ),
      ),
    );
  }
}

/// A replacement for [MemberTile] for when the person is not actually a member.
class DefaultMemberTile extends StatelessWidget {
  final String name;

  const DefaultMemberTile({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/img/default-avatar.jpg'),
        const _BlackGradient(),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('$name is not a member.'),
                ));
              },
            ),
          ),
        ),
      ],
    );
  }
}
