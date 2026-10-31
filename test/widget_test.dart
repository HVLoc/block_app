import 'dart:convert';

import 'package:block/app.dart';
import 'package:block/features/game/presentation/controllers/game_controller.dart';
import 'package:block/features/game/presentation/widgets/board_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(Get.reset);
  testWidgets('game renders, resets, and disposes its route controller', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'bb_best': 120});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(BlockBlastLiteApp(preferences: preferences));
    await tester.pumpAndSettle();
    expect(find.text('KỶ LỤC: 120'), findsOneWidget);
    expect(Get.isRegistered<GameController>(), isTrue);
    await tester.tap(find.byKey(const Key('game_reset_button')));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    expect(preferences.getString('bb_active'), isNotNull);
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
    expect(tester.takeException(), isNull);
  });
  testWidgets('drag cancel restores dock and release waits for latest hover', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'bb_active': jsonEncode({
        'score': 0,
        'combo': 0,
        'board': List.generate(8, (_) => List<int?>.filled(8, null)),
        'dock': [
          {
            'm': [
              [1],
            ],
            'c': 2,
          },
          null,
          null,
        ],
      }),
    });
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(BlockBlastLiteApp(preferences: preferences));
    await tester.pumpAndSettle();
    final game = Get.find<GameController>();
    final slot = find.byKey(const ValueKey('game_dock_0_drag'));
    final start = tester.getCenter(slot);
    game.startDrag(0, DragStartDetails(globalPosition: start));
    expect(game.dock[0], isNull);
    game.cancelDrag();
    expect(game.dock[0], isNotNull);
    game.startDrag(0, DragStartDetails(globalPosition: start));
    final rect = game.boardRectNotifier.value!;
    final target = Offset(
      rect.left + rect.width / 16,
      rect.top + rect.width / 16 + 80,
    );
    // Intentionally release without awaiting hover validation.
    final pending = game.updateDrag(DragUpdateDetails(globalPosition: target));
    await game.endDrag(DragEndDetails());
    await pending;
    await tester.pumpAndSettle();
    expect(game.state.board[0][0], 2);
    expect(game.state.score, 1);
    expect(game.popupNotifier.value, isEmpty);
    expect(preferences.getString('bb_active'), contains('"score":1'));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
  test('board repaints when board cells change', () {
    final before = BoardPainter(
      board: List.generate(8, (_) => List.filled(8, null)),
    );
    final after = BoardPainter(
      board: List.generate(8, (_) => List.filled(8, 0)),
    );
    expect(after.shouldRepaint(before), isTrue);
  });
}
