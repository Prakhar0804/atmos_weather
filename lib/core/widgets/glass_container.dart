import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A reusable glassmorphism container widget.
///
/// Creates a frosted-glass effect using [BackdropFilter] with a semi-transparent
/// background, subtle border, and customizable blur intensity. This is the
/// building block for all cards and panels in the app.
///
/// ### How it works:
/// 1. [ClipRRect] clips the content to rounded corners.
/// 2. [BackdropFilter] applies a Gaussian blur to whatever is behind the widget.
/// 3. A semi-transparent [Container] creates the frosted overlay.
///
/// ### Usage:
/// ```dart
/// GlassContainer(
///   child: Text('Hello'),
///   borderRadius: 20,
///   blur: 15,
/// )
/// ```
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 15,
    this.opacity = 0.15,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
