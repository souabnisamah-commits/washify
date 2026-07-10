import 'package:flutter/material.dart';
import 'package:washify/core/theme/app_theme.dart';

class ColorAnimatedTitle extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ColorAnimatedTitle({super.key, required this.text, this.style});

  @override
  State<ColorAnimatedTitle> createState() => _ColorAnimatedTitleState();
}

class _ColorAnimatedTitleState extends State<ColorAnimatedTitle> with TickerProviderStateMixin {
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Color Animation
    _colorController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color(0xFFF5F5DC), // Beige
      end: AppTheme.primaryBlue,
    ).animate(_colorController);

    // Slide (Marquee) Animation
    _slideController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _colorController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Text(
            widget.text,
            style: widget.style?.copyWith(color: _colorAnimation.value) ??
                TextStyle(color: _colorAnimation.value, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
