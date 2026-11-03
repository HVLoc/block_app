import 'dart:convert';

import 'package:block/app.dart';
import 'package:block/features/game/presentation/controllers/game_controller.dart';
import 'package:block/features/game/presentation/widgets/game_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(Get.reset);

  testWidgets(
    'tap placement rejects overlap, then saves a valid move without motion',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final board = List.generate(8, (_) => List<int?>.filled(8, null));
      board[0][0] = 3;
      SharedPreferences.setMockInitialValues({
        'bb_active': jsonEncode({
          'score': 0,
          'combo': 0,
          'board': board,
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
      await tester.pumpWidget(BlocksApp(preferences: preferences));
      await tester.pumpAndSettle();
      final game = Get.find<GameController>();
      await tester.tap(find.byKey(const ValueKey('game_dock_0_drag')));
      await tester.pumpAndSettle();
      expect(game.selectedSlot, 0);
      await tester.tap(find.byKey(const ValueKey('game_cell_0_0')));
      await tester.pumpAndSettle();
      expect(game.state.score, 0);
      expect(game.selectedSlot, 0);
      expect(find.text('Không đủ chỗ ở đây. Hãy chọn ô khác.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('game_cell_0_1')));
      await tester.pumpAndSettle();
      expect(game.state.board[0][1], 2);
      expect(game.state.score, 1);
      expect(game.selectedSlot, isNull);
      expect(game.popupNotifier.value, isEmpty);
      expect(game.flashCells, isEmpty);
      expect(preferences.getString('bb_active'), contains('"score":1'));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final size in [
    const Size(375, 667),
    const Size(812, 375),
    const Size(1024, 768),
  ]) {
    testWidgets('UI reflows at $size with large text and reachable themes', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      SharedPreferences.setMockInitialValues({'bb_best': 123456});
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(BlocksApp(preferences: preferences));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(GameBoard)).width,
        lessThanOrEqualTo(520),
      );
      final themes = find.byKey(const Key('game_themes_button'));
      await tester.ensureVisible(themes);
      expect(tester.getSize(themes).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(themes).height, greaterThanOrEqualTo(48));
      await tester.tap(themes);
      await tester.pumpAndSettle();
      final fruit = find.byKey(const ValueKey('theme_option_fruit'));
      await tester.ensureVisible(fruit);
      await tester.tap(fruit);
      await tester.pumpAndSettle();
      expect(preferences.getString('blocks_theme'), 'fruit');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
