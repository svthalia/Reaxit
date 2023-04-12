import 'package:flutter/material.dart';

class AnimatedLoader extends StatefulWidget {
  final bool visible;
  const AnimatedLoader({super.key, required this.visible});

  @override
  State<AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void didUpdateWidget(AnimatedLoader oldWidget) {
    if (widget.visible) {
      _controller.value = 1;
    } else {
      _controller.reverse();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      axis: Axis.vertical,
      child: const Center(
        child: Padding(
            padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
      ),
    );
  }
}
