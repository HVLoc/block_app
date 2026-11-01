import 'package:block/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AnimatedScoreDisplay extends StatefulWidget {
  const AnimatedScoreDisplay({required this.scoreNotifier, super.key});
  final ValueNotifier<int> scoreNotifier;

  @override
  State<AnimatedScoreDisplay> createState() => _AnimatedScoreDisplayState();
}

class _AnimatedScoreDisplayState extends State<AnimatedScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.25,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_ctrl);

    widget.scoreNotifier.addListener(_onScoreChanged);
  }

  void _onScoreChanged() {
    if (!mounted) return;
    _ctrl.forward(from: 0);
    setState(() {});
  }

  @override
  void dispose() {
    widget.scoreNotifier.removeListener(_onScoreChanged);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, __) => Transform.scale(
        scale: _scaleAnim.value,
        child: Text(
          '${widget.scoreNotifier.value}',
          style: const TextStyle(
            color: AppColors.scoreText,
            fontSize: 46,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
