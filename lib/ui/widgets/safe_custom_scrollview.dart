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

  const SafeCustomScrollView({
    required this.slivers,
    this.controller,
    this.physics,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.left = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaquery = MediaQuery.of(context);
    EdgeInsets padding = mediaquery.padding;

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
