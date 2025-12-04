import 'package:flutter/material.dart';

class CircularPageRoute extends PageRouteBuilder {
  final Widget page;

  CircularPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ClipPath(
              clipper: CircleRevealClipper(animation.value),
              child: child,
            );
          },
        );
}

class CircleRevealClipper extends CustomClipper<Path> {
  final double revealPercent;

  CircleRevealClipper(this.revealPercent);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.longestSide * revealPercent;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) =>
      revealPercent != oldClipper.revealPercent;
}
