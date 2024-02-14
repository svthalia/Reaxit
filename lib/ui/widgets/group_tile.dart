import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/ui/screens.dart';
import 'cached_image.dart';

class GroupTile extends StatelessWidget {
  final ListGroup group;

  const GroupTile({super.key, required this.group});

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
              imageUrl: group.photo.large,
              placeholder: 'assets/img/default-avatar.jpg',
            ),
            const _BlackGradient(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  group.name,
                  style: Theme.of(context).primaryTextTheme.bodyMedium,
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
      openBuilder: (_, __) => GroupScreen(pk: group.pk, group: group),
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
