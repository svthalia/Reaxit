import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class SafeCustomScrollView extends StatelessWidget {
  final List<Widget> slivers;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool top;
  final bool right;
  final bool bottom;
  final bool left;
  final EdgeInsets padding;

  const SafeCustomScrollView({
    required this.slivers,
    this.controller,
    this.physics,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.left = true,
    this.padding = const EdgeInsets.all(8),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaquery = MediaQuery.of(context);
    EdgeInsets padding = EdgeInsets.fromLTRB(
        max(mediaquery.padding.left, this.padding.left),
        max(mediaquery.padding.top, this.padding.top),
        max(mediaquery.padding.right, this.padding.right),
        max(mediaquery.padding.bottom, this.padding.bottom));
    return SafeArea(
      top: false,
      bottom: false,
      left: left,
      right: right,
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: left,
        removeTop: top,
        removeRight: right,
        removeBottom: bottom,
        child: Padding(
          padding: EdgeInsets.only(left: padding.left, right: padding.right),
          child: CustomScrollView(
            controller: controller,
            physics: physics,
            slivers: [
              if (top)
                SliverPadding(padding: EdgeInsets.only(top: padding.top)),
              ...slivers,
              if (bottom)
                SliverPadding(padding: EdgeInsets.only(bottom: padding.bottom)),
            ],
          ),
        ),
      ),
    );
  }
}
