import 'package:flutter/material.dart';
import 'package:reaxit/ui/screens/member_detail.dart';
import 'package:reaxit/models/member.dart';

class MemberCard extends StatelessWidget {
  final ListMember _member;
  MemberCard(this._member);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetail(this._member.pk, this._member),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: this._member.pk,
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/img/default-avatar.jpg',
              image: this._member.avatar.medium,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 300),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.bottomLeft,
            child: Text(
              this._member.displayName,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
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
          )
        ],
      ),
    );
  }
}
