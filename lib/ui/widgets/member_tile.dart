import 'package:flutter/material.dart';
import 'package:reaxit/models/member.dart';
import 'package:reaxit/ui/router/router.dart';
import 'package:reaxit/ui/screens/profile_screen.dart';

class MemberTile extends StatelessWidget {
  final ListMember member;

  const MemberTile({Key? key, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ThaliaRouterDelegate.of(context).push(
          MaterialPage(
            child: ProfileScreen(
              pk: member.pk,
              member: member,
            ),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'member_${member.pk}',
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/img/default-avatar.jpg',
              image: member.photo.small,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 200),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              color: Colors.black,
              gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.5),
                ],
                stops: [0.4, 1.0],
              ),
            ),
            child: Text(
              member.displayName,
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
          )
        ],
      ),
    );
  }
}
