import 'package:block/core/theme/app_colors.dart';
import 'package:block/features/game/presentation/models/score_popup.dart';
import 'package:flutter/material.dart';

class ScorePopupItem extends StatefulWidget {
  const ScorePopupItem({required this.popup, required this.onDone, super.key});
  final ScorePopup popup;
  final void Function(int id) onDone;

  @override
  State<ScorePopupItem> createState() => _ScorePopupItemState();
}

class _ScorePopupItemState extends State<ScorePopupItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _offsetAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _offsetAnim = Tween<double>(
      begin: 0,
      end: -60,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 50),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) => widget.onDone(widget.popup.id));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Positioned(
        left: widget.popup.position.dx - 30,
        top: widget.popup.position.dy + _offsetAnim.value,
        child: Opacity(
          opacity: _opacityAnim.value.clamp(0.0, 1.0),
          child: Text(
            '+${widget.popup.points}',
            style: const TextStyle(
              color: AppColors.scorePlusText,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: Offset(1, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
