import 'package:flutter/material.dart';

class CardSection extends StatelessWidget {
  final List<Widget> _children;

  CardSection(this._children);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1), borderRadius: BorderRadius.circular(4), color: Colors.white),
        child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _children,
              )
    );
  }
}