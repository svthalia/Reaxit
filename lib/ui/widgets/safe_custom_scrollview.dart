import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class SafeCustomScrollView extends StatelessWidget {
  final List<Widget> slivers;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  const SafeCustomScrollView(
      {required this.slivers, this.controller, this.physics, super.key});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaquery = MediaQuery.of(context);
    EdgeInsets padding = mediaquery.padding;

    return SafeArea(
      top: false,
      bottom: false,
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        child: Padding(
          padding: EdgeInsets.only(left: padding.left, right: padding.right),
          child: CustomScrollView(
            controller: controller,
            physics: physics,
            slivers: [
              SliverPadding(padding: EdgeInsets.only(top: padding.top)),
              ...slivers,
              SliverPadding(padding: EdgeInsets.only(bottom: padding.bottom)),
            ],
          ),
        ),
      ),
    );
  }
}
