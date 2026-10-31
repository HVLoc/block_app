import 'package:block/features/game/presentation/models/score_popup.dart';
import 'package:block/features/game/presentation/widgets/score_popup_item.dart';
import 'package:flutter/material.dart';

class ScorePopupLayer extends StatelessWidget {
  const ScorePopupLayer({
    required this.popupNotifier,
    required this.onPopupDone,
    super.key,
  });
  final ValueNotifier<List<ScorePopup>> popupNotifier;
  final void Function(int id) onPopupDone;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<List<ScorePopup>>(
        valueListenable: popupNotifier,
        builder: (_, popups, __) {
          return Stack(
            children: popups
                .map(
                  (p) => ScorePopupItem(
                    key: ValueKey(p.id),
                    popup: p,
                    onDone: onPopupDone,
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
