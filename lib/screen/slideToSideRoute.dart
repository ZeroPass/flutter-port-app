import 'package:flutter/material.dart';

enum Direction {
  FROM_LEFT,
  FROM_RIGHT
}

class SlideToSideRoute<T> extends PageRoute<T> {
  SlideToSideRoute(this.child, [this.direction = Direction.FROM_RIGHT] );
  @override
  Color get barrierColor => Colors.black;

  @override
  String get barrierLabel => "";

  final Widget child;
  final Direction direction;


  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    AnimationController _controller;

    //screen arrives from right side\
    if (this.direction == Direction.FROM_RIGHT)
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1,0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart)),
        child: child,
      );
    else
      //screen arrives from left side
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1,0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart)),
        child: child,
      );


    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);
}