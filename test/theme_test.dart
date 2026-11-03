import 'dart:ui';

import 'package:block/app.dart';
import 'package:block/core/theme/block_decoration.dart';
import 'package:block/core/theme/block_theme.dart';
import 'package:block/features/appearance/data/theme_repository_impl.dart';
import 'package:block/features/appearance/domain/theme_repository.dart';
import 'package:block/features/appearance/presentation/theme_controller.dart';
import 'package:block/features/game/presentation/controllers/game_controller.dart';
import 'package:block/features/game/presentation/widgets/board_painter.dart';
import 'package:block/features/game/presentation/widgets/piece_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(Get.reset);

  test('unknown or malformed saved themes fall back to classic', () async {
    for (final stored in ['unknown-theme', 42]) {
      SharedPreferences.setMockInitialValues({'blocks_theme': stored});
      final preferences = await SharedPreferences.getInstance();
      expect(ThemeRepositoryImpl(preferences).readTheme(), BlockTheme.classic);
    }
  });

  test('failed save keeps the current theme and allows retry', () async {
    final repository = _FailingThemeRepository();
    final controller = ThemeController(repository);
    await controller.selectTheme(BlockTheme.fruit);
    expect(controller.theme.value, BlockTheme.geometric);
    expect(controller.errorMessage.value, isNotNull);
    expect(controller.isSaving.value, isFalse);
    repository.shouldFail = false;
    await controller.selectTheme(BlockTheme.fruit);
    expect(controller.theme.value, BlockTheme.fruit);
    expect(controller.errorMessage.value, isNull);
  });

  test(
    'all themes serialize and deserialize with unique labels and icons',
    () {
      final names = <String>{};
      final labels = <String>{};
      for (final theme in BlockTheme.values) {
        expect(
          names.add(theme.name),
          isTrue,
          reason: 'Duplicate theme name: ${theme.name}',
        );
        expect(
          labels.add(theme.label),
          isTrue,
          reason: 'Duplicate theme label: ${theme.label}',
        );
        expect(theme.description, isNotEmpty);
        expect(theme.icon, isNotNull);
        expect(BlockTheme.fromName(theme.name), theme);
      }
    },
  );

  test(
    'BlockDecoration paints all themes across all color indices without errors',
    () {
      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      const tile = Rect.fromLTWH(0, 0, 48, 48);

      for (final theme in BlockTheme.values) {
        for (var colorIdx = 0; colorIdx < 7; colorIdx++) {
          expect(
            () => BlockDecoration.paint(canvas, tile, colorIdx, theme),
            returnsNormally,
          );
        }
      }
      pictureRecorder.endRecording().dispose();
    },
  );

  testWidgets(
    'theme selection persists and updates board, dock and dragged piece',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'bb_best': 123});
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(BlocksApp(preferences: preferences));
      await tester.pumpAndSettle();
      final game = Get.find<GameController>();
      final stateBefore = game.state;
      await tester.tap(find.byKey(const Key('game_themes_button')));
      await tester.pumpAndSettle();
      expect(find.text('Cổ điển'), findsOneWidget);
      for (final theme in [BlockTheme.geometric, BlockTheme.fruit]) {
        await tester.tap(find.byKey(ValueKey('theme_option_${theme.name}')));
        await tester.pumpAndSettle();
        expect(preferences.getString('blocks_theme'), theme.name);
      }
      await tester.tap(find.byKey(const Key('theme_picker_close')));
      await tester.pumpAndSettle();
      expect(game.state, same(stateBefore));
      final painters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((widget) => widget.painter);
      expect(painters.whereType<BoardPainter>().single.theme, BlockTheme.fruit);
      expect(
        painters.whereType<PiecePainter>().every(
          (painter) => painter.theme == BlockTheme.fruit,
        ),
        isTrue,
      );
      final start = tester.getCenter(
        find.byKey(const ValueKey('game_dock_0_drag')),
      );
      game.startDrag(0, DragStartDetails(globalPosition: start));
      await tester.pump();
      final draggedPainters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((widget) => widget.painter)
          .whereType<PiecePainter>();
      expect(draggedPainters, isNotEmpty);
      expect(
        draggedPainters.every((painter) => painter.theme == BlockTheme.fruit),
        isTrue,
      );
      game.cancelDrag();
      await tester.pumpWidget(const SizedBox.shrink());
      Get.reset();
      await tester.pumpWidget(BlocksApp(preferences: preferences));
      await tester.pumpAndSettle();
      expect(Get.find<ThemeController>().theme.value, BlockTheme.fruit);
      expect(find.text('KỶ LỤC: 123'), findsOneWidget);
      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('game_themes_button')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('theme_option_fruit')),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'can select and render new themes (gem, space, ocean, candy, animal)',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(BlocksApp(preferences: preferences));
      await tester.pumpAndSettle();

      for (final theme in [
        BlockTheme.gem,
        BlockTheme.space,
        BlockTheme.ocean,
        BlockTheme.candy,
        BlockTheme.animal,
      ]) {
        await tester.tap(find.byKey(const Key('game_themes_button')));
        await tester.pumpAndSettle();
        final option = find.byKey(ValueKey('theme_option_${theme.name}'));
        await tester.ensureVisible(option);
        await tester.tap(option);
        await tester.pumpAndSettle();
        expect(preferences.getString('blocks_theme'), theme.name);
        final closeBtn = find.byKey(const Key('theme_picker_close'));
        await tester.ensureVisible(closeBtn);
        await tester.tap(closeBtn);
        await tester.pumpAndSettle();
        expect(Get.find<ThemeController>().theme.value, theme);
      }
    },
  );
}

class _FailingThemeRepository implements ThemeRepository {
  bool shouldFail = true;
  @override
  BlockTheme readTheme() => BlockTheme.geometric;
  @override
  Future<bool> saveTheme(BlockTheme theme) async => !shouldFail;
}
