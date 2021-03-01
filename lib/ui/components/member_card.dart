import 'package:flutter/material.dart';
import 'package:reaxit/ui/screens/member_detail.dart';
import 'package:reaxit/models/member.dart';

class MemberCard extends StatelessWidget {
  final Member _member;
  MemberCard(this._member);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetail(_member.pk, _member),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: "member_${_member.pk}",
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/img/default-avatar.jpg',
              image: _member.avatar.medium,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 300),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.bottomLeft,
            child: Text(_member.displayName,
                style: Theme.of(context).primaryTextTheme.bodyText2),
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
          )
        ],
      ),
    );
  }
}
