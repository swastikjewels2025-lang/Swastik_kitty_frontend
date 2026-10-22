import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper utilities for smooth luxury route transitions.
abstract final class RouteTransitions {
  /// Standard luxury fade transition page.
  static CustomTransitionPage<void> fadeTransitionPage({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        );
      },
    );
  }

  /// Slide from right transition (standard for horizontal sub-views like OTP / Phone).
  static CustomTransitionPage<void> slideFromRightPage({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        const Offset begin = Offset(1.0, 0.0);
        const Offset end = Offset.zero;
        final Animatable<Offset> tween = Tween<Offset>(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeOutCubic),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Slide from bottom transition (standard for modal overlays and bottom sheets).
  static CustomTransitionPage<void> slideFromBottomPage({
    required Widget child,
    required LocalKey key,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        const Offset begin = Offset(0.0, 1.0);
        const Offset end = Offset.zero;
        final Animatable<Offset> tween = Tween<Offset>(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeOutCubic),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
