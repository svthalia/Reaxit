import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/ui/screens/groups_screen.dart';

import '../screens/group_screen.dart';
import 'cached_image.dart';

class GroupTile extends StatelessWidget {
  final ListGroup group;

  const GroupTile({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
        tappable: false,
        routeSettings: RouteSettings(name: 'Group(${group.pk})'),
        transitionType: ContainerTransitionType.fadeThrough,
        closedShape: const RoundedRectangleBorder(),
        closedBuilder: (context, openContainer) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CachedImage(
                imageUrl: group.photo.small,
                placeholder: 'assets/img/default-avatar.jpg',
              ),
              const _BlackGradient(),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    group.name,
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
        openBuilder: (_, __) => GroupScreen(pk: group.pk)
        //openBuilder: (_, __) => ProfileScreen(pk: member.pk, member: member),
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
//TODO: Add a group tile
//TODO: Add a group screen
