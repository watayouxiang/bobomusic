import "package:flutter/material.dart";

class InfiniteRotate extends StatefulWidget {
  final Widget child;

  const InfiniteRotate({super.key, required this.child});

  @override
  // ignore: no_logic_in_create_state
  InfiniteRotateState createState() => InfiniteRotateState(child: child);
}

class InfiniteRotateState extends State<InfiniteRotate>
    with TickerProviderStateMixin {
  final Widget child;

  InfiniteRotateState({required this.child});

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat(reverse: false);
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      alignment: Alignment.center,
      turns: _animation,
      child: child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
