import 'dart:math' as math;

import 'package:block/core/theme/block_theme.dart';
import 'package:flutter/material.dart';

/// Draws original vector symbols directly into a tile, without image assets.
class BlockDecoration {
  const BlockDecoration._();

  static void paint(
    Canvas canvas,
    Rect tile,
    int colorIndex,
    BlockTheme theme, {
    double opacity = 1,
  }) {
    if (theme == BlockTheme.classic || tile.shortestSide < 10) return;
    final side = tile.shortestSide * 0.60;
    canvas
      ..save()
      ..translate(tile.center.dx - side / 2, tile.center.dy - side / 2)
      ..scale(side / 24);
    final ink = Paint()
      ..color = Colors.white.withValues(alpha: 0.82 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (theme) {
      case BlockTheme.classic:
        break;
      case BlockTheme.geometric:
        _geometry(canvas, colorIndex % 7, ink);
      case BlockTheme.fruit:
        _fruit(canvas, colorIndex % 7, ink);
      case BlockTheme.gem:
        _gem(canvas, colorIndex % 7, ink);
      case BlockTheme.space:
        _space(canvas, colorIndex % 7, ink);
      case BlockTheme.ocean:
        _ocean(canvas, colorIndex % 7, ink);
      case BlockTheme.candy:
        _candy(canvas, colorIndex % 7, ink);
      case BlockTheme.animal:
        _animal(canvas, colorIndex % 7, ink);
    }
    canvas.restore();
  }

  static void _polygon(
    Canvas canvas,
    int sides,
    Paint ink, {
    bool star = false,
  }) {
    final path = Path();
    final points = star ? sides * 2 : sides;
    for (var i = 0; i < points; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / points;
      final radius = star && i.isOdd ? 4.2 : 9.0;
      final x = 12 + math.cos(angle) * radius;
      final y = 12 + math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path..close(), ink);
  }

  static void _geometry(Canvas canvas, int index, Paint ink) {
    switch (index) {
      case 0:
        _polygon(canvas, 5, ink, star: true);
      case 1:
        canvas.drawPath(
          Path()
            ..moveTo(14, 2)
            ..lineTo(5, 13)
            ..lineTo(11, 13)
            ..lineTo(9, 22)
            ..lineTo(20, 10)
            ..lineTo(13, 10)
            ..close(),
          ink,
        );
      case 2:
        _polygon(canvas, 4, ink);
      case 3:
        canvas.drawPath(
          Path()
            ..moveTo(12, 21)
            ..cubicTo(-7, 8, 7, -3, 12, 7)
            ..cubicTo(17, -3, 31, 8, 12, 21)
            ..close(),
          ink,
        );
      case 4:
        canvas
          ..drawCircle(const Offset(12, 12), 8, ink)
          ..drawCircle(const Offset(12, 12), 2, ink);
      case 5:
        _polygon(canvas, 6, ink);
      case 6:
        _polygon(canvas, 4, ink, star: true);
    }
  }

  static void _fruit(Canvas canvas, int index, Paint ink) {
    switch (index) {
      case 0: // Strawberry.
        canvas
          ..drawPath(
            Path()
              ..moveTo(5, 7)
              ..quadraticBezierTo(12, 3, 19, 7)
              ..quadraticBezierTo(21, 14, 12, 22)
              ..quadraticBezierTo(3, 14, 5, 7)
              ..close(),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(6, 3)
              ..lineTo(10, 6)
              ..lineTo(12, 2)
              ..lineTo(14, 6)
              ..lineTo(18, 3),
            ink,
          );
        for (final point in const [
          Offset(8, 10),
          Offset(15, 10),
          Offset(12, 15),
        ]) {
          canvas.drawCircle(point, 0.8, Paint()..color = ink.color);
        }
      case 1: // Orange slice.
        canvas.drawCircle(const Offset(12, 13), 8.5, ink);
        for (var i = 0; i < 6; i++) {
          final angle = i * math.pi / 3;
          canvas.drawLine(
            const Offset(12, 13),
            Offset(12 + math.cos(angle) * 6, 13 + math.sin(angle) * 6),
            ink,
          );
        }
        canvas.drawLine(const Offset(12, 4), const Offset(15, 1), ink);
      case 2: // Banana.
        canvas.drawPath(
          Path()
            ..moveTo(4, 4)
            ..cubicTo(3, 20, 17, 26, 22, 9)
            ..cubicTo(15, 18, 8, 15, 7, 5)
            ..close(),
          ink,
        );
      case 3: // Apple and leaf.
        canvas
          ..drawPath(
            Path()
              ..moveTo(12, 7)
              ..cubicTo(2, 1, 0, 18, 8, 21)
              ..quadraticBezierTo(12, 19, 16, 21)
              ..cubicTo(24, 18, 22, 1, 12, 7)
              ..close(),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(12, 7)
              ..quadraticBezierTo(10, 1, 17, 2)
              ..quadraticBezierTo(16, 6, 12, 7),
            ink,
          );
      case 4: // Cherries.
        canvas
          ..drawCircle(const Offset(6, 16), 4, ink)
          ..drawCircle(const Offset(18, 17), 4, ink)
          ..drawPath(
            Path()
              ..moveTo(6, 12)
              ..quadraticBezierTo(7, 3, 14, 2)
              ..quadraticBezierTo(13, 9, 18, 13),
            ink,
          );
      case 5: // Blueberries.
        for (final point in const [
          Offset(8, 9),
          Offset(16, 9),
          Offset(12, 17),
        ]) {
          canvas
            ..drawCircle(point, 4.5, ink)
            ..drawCircle(point, 0.9, Paint()..color = ink.color);
        }
      case 6: // Grapes.
        for (final point in const [
          Offset(7, 8),
          Offset(15, 8),
          Offset(11, 14),
          Offset(18, 14),
          Offset(14, 20),
        ]) {
          canvas.drawCircle(point, 3.2, ink);
        }
        canvas.drawPath(
          Path()
            ..moveTo(11, 5)
            ..quadraticBezierTo(11, 0, 17, 2),
          ink,
        );
    }
  }

  static void _gem(Canvas canvas, int index, Paint ink) {
    final fill = Paint()..color = ink.color;
    switch (index) {
      case 0: // Brilliant diamond / Ruby.
        canvas
          ..drawPath(
            Path()
              ..moveTo(7, 5)
              ..lineTo(17, 5)
              ..lineTo(21, 10)
              ..lineTo(12, 21)
              ..lineTo(3, 10)
              ..close(),
            ink,
          )
          ..drawLine(const Offset(3, 10), const Offset(21, 10), ink)
          ..drawLine(const Offset(7, 5), const Offset(10, 10), ink)
          ..drawLine(const Offset(17, 5), const Offset(14, 10), ink)
          ..drawLine(const Offset(10, 10), const Offset(12, 5), ink)
          ..drawLine(const Offset(14, 10), const Offset(12, 5), ink)
          ..drawLine(const Offset(10, 10), const Offset(12, 21), ink)
          ..drawLine(const Offset(14, 10), const Offset(12, 21), ink);
      case 1: // Emerald step cut.
        canvas
          ..drawPath(
            Path()
              ..moveTo(6, 4)
              ..lineTo(18, 4)
              ..lineTo(21, 7)
              ..lineTo(21, 17)
              ..lineTo(18, 20)
              ..lineTo(6, 20)
              ..lineTo(3, 17)
              ..lineTo(3, 7)
              ..close(),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(8, 7)
              ..lineTo(16, 7)
              ..lineTo(18, 9)
              ..lineTo(18, 15)
              ..lineTo(16, 17)
              ..lineTo(8, 17)
              ..lineTo(6, 15)
              ..lineTo(6, 9)
              ..close(),
            ink,
          )
          ..drawLine(const Offset(6, 4), const Offset(8, 7), ink)
          ..drawLine(const Offset(18, 4), const Offset(16, 7), ink)
          ..drawLine(const Offset(21, 17), const Offset(18, 15), ink)
          ..drawLine(const Offset(3, 17), const Offset(6, 15), ink);
      case 2: // Royal crown.
        canvas
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(4, 16.5, 16, 3),
              const Radius.circular(1.5),
            ),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(4, 16.5)
              ..lineTo(4, 9.5)
              ..lineTo(8, 13.5)
              ..lineTo(12, 6)
              ..lineTo(16, 13.5)
              ..lineTo(20, 9.5)
              ..lineTo(20, 16.5),
            ink,
          )
          ..drawCircle(const Offset(4, 8.5), 1.2, fill)
          ..drawCircle(const Offset(12, 5), 1.5, fill)
          ..drawCircle(const Offset(20, 8.5), 1.2, fill)
          ..drawCircle(const Offset(8, 18), 0.7, fill)
          ..drawCircle(const Offset(12, 18), 0.7, fill)
          ..drawCircle(const Offset(16, 18), 0.7, fill);
      case 3: // Crystal cluster.
        canvas
          ..drawPath(
            Path()
              ..moveTo(10, 20)
              ..lineTo(10, 8)
              ..lineTo(12, 4)
              ..lineTo(14, 8)
              ..lineTo(14, 20),
            ink,
          )
          ..drawLine(const Offset(12, 4), const Offset(12, 20), ink)
          ..drawPath(
            Path()
              ..moveTo(6, 20)
              ..lineTo(6, 12)
              ..lineTo(8, 9)
              ..lineTo(10, 12),
            ink,
          )
          ..drawLine(const Offset(8, 9), const Offset(8, 20), ink)
          ..drawPath(
            Path()
              ..moveTo(14, 20)
              ..lineTo(16, 14)
              ..lineTo(18, 12)
              ..lineTo(18, 20),
            ink,
          )
          ..drawLine(const Offset(18, 12), const Offset(17, 20), ink);
      case 4: // Heart gem.
        canvas
          ..drawPath(
            Path()
              ..moveTo(12, 20)
              ..cubicTo(4, 14, 2, 8, 6.5, 5)
              ..cubicTo(9.5, 3.5, 11.5, 6, 12, 8)
              ..cubicTo(12.5, 6, 14.5, 3.5, 17.5, 5)
              ..cubicTo(22, 8, 20, 14, 12, 20)
              ..close(),
            ink,
          )
          ..drawLine(const Offset(12, 8), const Offset(12, 13), ink)
          ..drawLine(const Offset(12, 13), const Offset(12, 20), ink)
          ..drawLine(const Offset(12, 13), const Offset(5, 10), ink)
          ..drawLine(const Offset(12, 13), const Offset(19, 10), ink);
      case 5: // Sparkle flare star.
        canvas
          ..drawPath(
            Path()
              ..moveTo(12, 2)
              ..cubicTo(12, 8, 16, 12, 22, 12)
              ..cubicTo(16, 12, 12, 16, 12, 22)
              ..cubicTo(12, 16, 8, 12, 2, 12)
              ..cubicTo(8, 12, 12, 8, 12, 2)
              ..close(),
            ink,
          )
          ..drawLine(const Offset(7, 7), const Offset(5, 5), ink)
          ..drawLine(const Offset(17, 7), const Offset(19, 5), ink)
          ..drawLine(const Offset(7, 17), const Offset(5, 19), ink)
          ..drawLine(const Offset(17, 17), const Offset(19, 19), ink)
          ..drawCircle(const Offset(12, 12), 1.2, fill);
      case 6: // Pear / Teardrop cut gem.
        canvas
          ..drawPath(
            Path()
              ..moveTo(12, 3)
              ..cubicTo(19, 10, 19.5, 17.5, 12, 21)
              ..cubicTo(4.5, 17.5, 5, 10, 12, 3)
              ..close(),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(12, 7)
              ..lineTo(15.5, 12.5)
              ..lineTo(12, 16.5)
              ..lineTo(8.5, 12.5)
              ..close(),
            ink,
          )
          ..drawLine(const Offset(12, 3), const Offset(12, 7), ink)
          ..drawLine(const Offset(12, 16.5), const Offset(12, 21), ink)
          ..drawLine(const Offset(8.5, 12.5), const Offset(5.5, 13.5), ink)
          ..drawLine(const Offset(15.5, 12.5), const Offset(18.5, 13.5), ink);
    }
  }

  static void _space(Canvas canvas, int index, Paint ink) {
    final fill = Paint()..color = ink.color;
    switch (index) {
      case 0: // Rocket ship.
        canvas
          ..drawPath(
            Path()
              ..moveTo(12, 3)
              ..cubicTo(16, 7, 16, 14, 15, 17)
              ..lineTo(9, 17)
              ..cubicTo(8, 14, 8, 7, 12, 3)
              ..close(),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(9, 14)
              ..lineTo(5, 18)
              ..lineTo(9, 17)
              ..close(),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(15, 14)
              ..lineTo(19, 18)
              ..lineTo(15, 17)
              ..close(),
            ink,
          )
          ..drawCircle(const Offset(12, 10), 2.2, ink)
          ..drawPath(
            Path()
              ..moveTo(10, 17)
              ..lineTo(12, 22)
              ..lineTo(14, 17),
            ink,
          );
      case 1: // Saturn planet.
        canvas
          ..drawCircle(const Offset(12, 12), 6, ink)
          ..save()
          ..translate(12, 12)
          ..rotate(-0.4)
          ..translate(-12, -12)
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(12, 12),
              width: 22,
              height: 6.5,
            ),
            ink,
          )
          ..restore();
      case 2: // Crescent moon and star.
        canvas
          ..drawPath(
            Path()
              ..moveTo(13, 3)
              ..cubicTo(5, 5, 4, 19, 14, 21)
              ..cubicTo(8.5, 18, 8.5, 6, 13, 3)
              ..close(),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(18, 6.5)
              ..lineTo(18.7, 8.3)
              ..lineTo(20.5, 9)
              ..lineTo(18.7, 9.7)
              ..lineTo(18, 11.5)
              ..lineTo(17.3, 9.7)
              ..lineTo(15.5, 9)
              ..lineTo(17.3, 8.3)
              ..close(),
            ink,
          )
          ..drawCircle(const Offset(17, 16), 0.8, fill);
      case 3: // Radiant sun.
        canvas
          ..drawCircle(const Offset(12, 12), 4.5, ink)
          ..drawLine(const Offset(12, 3), const Offset(12, 5.5), ink)
          ..drawLine(const Offset(12, 18.5), const Offset(12, 21), ink)
          ..drawLine(const Offset(3, 12), const Offset(5.5, 12), ink)
          ..drawLine(const Offset(18.5, 12), const Offset(21, 12), ink)
          ..drawLine(const Offset(5.5, 5.5), const Offset(7.5, 7.5), ink)
          ..drawLine(const Offset(18.5, 5.5), const Offset(16.5, 7.5), ink)
          ..drawLine(const Offset(5.5, 18.5), const Offset(7.5, 16.5), ink)
          ..drawLine(const Offset(18.5, 18.5), const Offset(16.5, 16.5), ink);
      case 4: // UFO flying saucer.
        canvas
          ..drawArc(
            Rect.fromCenter(
              center: const Offset(12, 11),
              width: 8,
              height: 8,
            ),
            math.pi,
            math.pi,
            false,
            ink,
          )
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(12, 12),
              width: 18,
              height: 5,
            ),
            ink,
          )
          ..drawCircle(const Offset(8, 13), 0.9, fill)
          ..drawCircle(const Offset(12, 13.5), 0.9, fill)
          ..drawCircle(const Offset(16, 13), 0.9, fill)
          ..drawLine(const Offset(9, 15), const Offset(6, 21), ink)
          ..drawLine(const Offset(15, 15), const Offset(18, 21), ink);
      case 5: // Meteor / Comet.
        canvas
          ..drawCircle(const Offset(7, 17), 3.2, ink)
          ..drawCircle(const Offset(7, 17), 1.2, fill)
          ..drawLine(const Offset(9, 15), const Offset(21, 4), ink)
          ..drawLine(const Offset(11, 17), const Offset(21, 8), ink)
          ..drawLine(const Offset(5, 13), const Offset(15, 4), ink);
      case 6: // Astronaut helmet.
        canvas
          ..drawPath(
            Path()
              ..moveTo(6, 18)
              ..cubicTo(4, 7, 20, 7, 18, 18)
              ..close(),
            ink,
          )
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(7, 10, 10, 6),
              const Radius.circular(3),
            ),
            ink,
          )
          ..drawLine(const Offset(9, 12), const Offset(12, 12), ink)
          ..drawLine(const Offset(4.5, 12), const Offset(4.5, 15), ink)
          ..drawLine(const Offset(19.5, 12), const Offset(19.5, 15), ink);
    }
  }

  static void _ocean(Canvas canvas, int index, Paint ink) {
    final fill = Paint()..color = ink.color;
    switch (index) {
      case 0: // Little fish.
        canvas
          ..drawPath(
            Path()
              ..moveTo(21, 12)
              ..cubicTo(16, 6, 8, 7, 4, 12)
              ..cubicTo(8, 17, 16, 18, 21, 12)
              ..close(),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(4, 12)
              ..lineTo(2, 7)
              ..lineTo(3.5, 12)
              ..lineTo(2, 17)
              ..close(),
            ink,
          )
          ..drawCircle(const Offset(17, 11), 1, fill)
          ..drawArc(
            const Rect.fromLTWH(11, 10, 4, 4),
            -math.pi / 2,
            math.pi,
            false,
            ink,
          );
      case 1: // Starfish.
        _polygon(canvas, 5, ink, star: true);
        canvas.drawCircle(const Offset(12, 12), 1.2, fill);
        for (var i = 0; i < 5; i++) {
          final a = -math.pi / 2 + i * 2 * math.pi / 5;
          canvas.drawCircle(
            Offset(12 + math.cos(a) * 6.5, 12 + math.sin(a) * 6.5),
            0.7,
            fill,
          );
        }
      case 2: // Scallop seashell.
        canvas
          ..drawLine(const Offset(9, 20), const Offset(15, 20), ink)
          ..drawPath(
            Path()
              ..moveTo(9, 20)
              ..cubicTo(4, 16, 3, 9, 8, 5)
              ..cubicTo(12, 3, 12, 3, 16, 5)
              ..cubicTo(21, 9, 20, 16, 15, 20)
              ..close(),
            ink,
          )
          ..drawLine(const Offset(12, 20), const Offset(12, 4), ink)
          ..drawLine(const Offset(12, 20), const Offset(8, 6), ink)
          ..drawLine(const Offset(12, 20), const Offset(16, 6), ink);
      case 3: // Jellyfish.
        canvas
          ..drawPath(
            Path()
              ..moveTo(5, 12)
              ..cubicTo(5, 4, 19, 4, 19, 12)
              ..quadraticBezierTo(16, 14, 14, 12)
              ..quadraticBezierTo(12, 14, 10, 12)
              ..quadraticBezierTo(7, 14, 5, 12)
              ..close(),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(8, 13)
              ..cubicTo(6, 16, 9, 19, 7, 22),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(12, 13)
              ..cubicTo(14, 16, 10, 19, 12, 22),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(16, 13)
              ..cubicTo(18, 16, 15, 19, 17, 22),
            ink,
          );
      case 4: // Crab.
        canvas
          ..drawOval(const Rect.fromLTWH(7, 10, 10, 8), ink)
          ..drawLine(const Offset(9.5, 10), const Offset(9.5, 8), ink)
          ..drawLine(const Offset(14.5, 10), const Offset(14.5, 8), ink)
          ..drawCircle(const Offset(9.5, 8), 1, fill)
          ..drawCircle(const Offset(14.5, 8), 1, fill)
          ..drawPath(
            Path()
              ..moveTo(7, 12)
              ..quadraticBezierTo(3, 10, 4, 6)
              ..lineTo(6, 7)
              ..moveTo(4, 6)
              ..lineTo(3, 8),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(17, 12)
              ..quadraticBezierTo(21, 10, 20, 6)
              ..lineTo(18, 7)
              ..moveTo(20, 6)
              ..lineTo(21, 8),
            ink,
          )
          ..drawLine(const Offset(7, 15), const Offset(4, 17), ink)
          ..drawLine(const Offset(17, 15), const Offset(20, 17), ink);
      case 5: // Nautical anchor.
        canvas
          ..drawCircle(const Offset(12, 5), 2.2, ink)
          ..drawLine(const Offset(12, 7.2), const Offset(12, 20), ink)
          ..drawLine(const Offset(7, 10), const Offset(17, 10), ink)
          ..drawPath(
            Path()
              ..moveTo(4, 15)
              ..cubicTo(5, 22, 19, 22, 20, 15),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(3, 16)
              ..lineTo(4, 14)
              ..lineTo(6, 16),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(18, 16)
              ..lineTo(20, 14)
              ..lineTo(21, 16),
            ink,
          );
      case 6: // Whale.
        canvas
          ..drawPath(
            Path()
              ..moveTo(3, 15)
              ..cubicTo(4, 9, 13, 8, 18, 12)
              ..cubicTo(20, 13, 22, 12, 23, 10)
              ..lineTo(22, 14)
              ..lineTo(23, 17)
              ..cubicTo(20, 15, 15, 18, 8, 18)
              ..cubicTo(5, 18, 3, 17, 3, 15)
              ..close(),
            ink,
          )
          ..drawCircle(const Offset(7, 14), 0.9, fill)
          ..drawPath(
            Path()
              ..moveTo(11, 8)
              ..quadraticBezierTo(9, 4, 6, 5),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(11, 8)
              ..quadraticBezierTo(13, 3, 16, 5),
            ink,
          );
    }
  }

  static void _candy(Canvas canvas, int index, Paint ink) {
    final fill = Paint()..color = ink.color;
    switch (index) {
      case 0: // Swirl lollipop.
        canvas
          ..drawLine(const Offset(12, 14), const Offset(12, 22), ink)
          ..drawCircle(const Offset(12, 8.5), 6, ink)
          ..drawArc(
            Rect.fromCircle(center: const Offset(12, 8.5), radius: 3.5),
            0,
            math.pi * 1.5,
            false,
            ink,
          )
          ..drawCircle(const Offset(12, 8.5), 1, fill);
      case 1: // Wrapped candy.
        canvas
          ..drawOval(const Rect.fromLTWH(8, 8, 8, 8), ink)
          ..drawLine(const Offset(10.5, 8.5), const Offset(10.5, 15.5), ink)
          ..drawLine(const Offset(13.5, 8.5), const Offset(13.5, 15.5), ink)
          ..drawPath(
            Path()
              ..moveTo(8, 12)
              ..lineTo(3, 8)
              ..lineTo(3, 16)
              ..close(),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(16, 12)
              ..lineTo(21, 8)
              ..lineTo(21, 16)
              ..close(),
            ink,
          );
      case 2: // Popsicle.
        canvas
          ..drawLine(const Offset(12, 17), const Offset(12, 22), ink)
          ..drawPath(
            Path()
              ..moveTo(7, 17)
              ..lineTo(17, 17)
              ..lineTo(17, 9)
              ..cubicTo(16, 7.5, 13.5, 8, 14, 5)
              ..quadraticBezierTo(9, 3, 7, 7)
              ..close(),
            ink,
          )
          ..drawLine(const Offset(10.5, 8), const Offset(10.5, 14), ink);
      case 3: // Donut with sprinkles.
        canvas
          ..drawCircle(const Offset(12, 12), 8.5, ink)
          ..drawCircle(const Offset(12, 12), 3.2, ink)
          ..drawLine(const Offset(8, 7), const Offset(10, 6), ink)
          ..drawLine(const Offset(14, 7), const Offset(16, 9), ink)
          ..drawLine(const Offset(6, 12), const Offset(8, 13), ink)
          ..drawLine(const Offset(14, 15), const Offset(16, 14), ink);
      case 4: // Cupcake.
        canvas
          ..drawPath(
            Path()
              ..moveTo(7, 13)
              ..lineTo(8.5, 20)
              ..lineTo(15.5, 20)
              ..lineTo(17, 13)
              ..close(),
            ink,
          )
          ..drawLine(const Offset(10.5, 13), const Offset(11, 20), ink)
          ..drawLine(const Offset(13.5, 13), const Offset(13, 20), ink)
          ..drawPath(
            Path()
              ..moveTo(6, 13)
              ..cubicTo(5, 8.5, 11, 8.5, 12, 8)
              ..cubicTo(13, 8.5, 19, 8.5, 18, 13),
            ink,
          )
          ..drawCircle(const Offset(12, 6), 1.8, fill)
          ..drawPath(
            Path()
              ..moveTo(12, 5)
              ..quadraticBezierTo(14, 2, 16, 3),
            ink,
          );
      case 5: // Chocolate bar.
        canvas
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(5, 4, 14, 16),
              const Radius.circular(2.5),
            ),
            ink,
          )
          ..drawLine(const Offset(5, 12), const Offset(19, 12), ink)
          ..drawLine(const Offset(12, 4), const Offset(12, 20), ink)
          ..drawCircle(const Offset(8.5, 8), 0.8, fill)
          ..drawCircle(const Offset(15.5, 8), 0.8, fill)
          ..drawCircle(const Offset(8.5, 16), 0.8, fill)
          ..drawCircle(const Offset(15.5, 16), 0.8, fill);
      case 6: // Gummy bear.
        canvas
          ..drawCircle(const Offset(12, 8.5), 3.8, ink)
          ..drawCircle(const Offset(8.5, 5.5), 1.6, fill)
          ..drawCircle(const Offset(15.5, 5.5), 1.6, fill)
          ..drawOval(const Rect.fromLTWH(8, 11, 8, 8.5), ink)
          ..drawCircle(const Offset(8.5, 19.5), 1.3, fill)
          ..drawCircle(const Offset(15.5, 19.5), 1.3, fill);
    }
  }

  static void _animal(Canvas canvas, int index, Paint ink) {
    final fill = Paint()..color = ink.color;
    switch (index) {
      case 0: // Paw print.
        canvas
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(12, 14.5),
              width: 9,
              height: 6.5,
            ),
            fill,
          )
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(7, 8.5),
              width: 3,
              height: 4,
            ),
            fill,
          )
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(10.3, 6.5),
              width: 3,
              height: 4.2,
            ),
            fill,
          )
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(13.7, 6.5),
              width: 3,
              height: 4.2,
            ),
            fill,
          )
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(17, 8.5),
              width: 3,
              height: 4,
            ),
            fill,
          );
      case 1: // Cute cat.
        canvas
          ..drawPath(
            Path()
              ..moveTo(6, 7)
              ..lineTo(10, 9)
              ..lineTo(14, 9)
              ..lineTo(18, 7)
              ..lineTo(18.5, 14)
              ..cubicTo(19, 20, 5, 20, 5.5, 14)
              ..close(),
            ink,
          )
          ..drawCircle(const Offset(9, 13.5), 1.1, fill)
          ..drawCircle(const Offset(15, 13.5), 1.1, fill)
          ..drawCircle(const Offset(12, 15.5), 0.7, fill)
          ..drawLine(const Offset(4, 14.5), const Offset(1, 14), ink)
          ..drawLine(const Offset(4, 16.5), const Offset(1, 17.5), ink)
          ..drawLine(const Offset(20, 14.5), const Offset(23, 14), ink)
          ..drawLine(const Offset(20, 16.5), const Offset(23, 17.5), ink);
      case 2: // Puppy with floppy ears.
        canvas
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(8, 8, 8, 10),
              const Radius.circular(3.5),
            ),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(8, 9)
              ..cubicTo(4, 10, 4, 16, 7, 15)
              ..lineTo(8, 12),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(16, 9)
              ..cubicTo(20, 10, 20, 16, 17, 15)
              ..lineTo(16, 12),
            ink,
          )
          ..drawCircle(const Offset(10, 11.5), 1, fill)
          ..drawCircle(const Offset(14, 11.5), 1, fill)
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(12, 15),
              width: 3,
              height: 2,
            ),
            fill,
          );
      case 3: // Butterfly.
        canvas
          ..drawLine(const Offset(12, 7), const Offset(12, 18), ink)
          ..drawCircle(const Offset(12, 6), 1.1, fill)
          ..drawPath(
            Path()
              ..moveTo(12, 6)
              ..quadraticBezierTo(10, 3, 8, 4),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(12, 6)
              ..quadraticBezierTo(14, 3, 16, 4),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(12, 8)
              ..cubicTo(4, 3, 2, 11, 12, 13)
              ..cubicTo(5, 15, 6, 19, 12, 17),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(12, 8)
              ..cubicTo(20, 3, 22, 11, 12, 13)
              ..cubicTo(19, 15, 18, 19, 12, 17),
            ink,
          );
      case 4: // Teddy bear.
        canvas
          ..drawCircle(const Offset(12, 13), 6.5, ink)
          ..drawCircle(const Offset(7, 7.5), 2.5, ink)
          ..drawCircle(const Offset(17, 7.5), 2.5, ink)
          ..drawCircle(const Offset(7, 7.5), 1, fill)
          ..drawCircle(const Offset(17, 7.5), 1, fill)
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(12, 14.5),
              width: 5.5,
              height: 4,
            ),
            ink,
          )
          ..drawCircle(const Offset(12, 13.8), 1.1, fill);
      case 5: // Little bird.
        canvas
          ..drawPath(
            Path()
              ..moveTo(6, 17)
              ..cubicTo(4, 11, 10, 7, 16, 8)
              ..lineTo(20, 11)
              ..lineTo(16, 12)
              ..cubicTo(17, 17, 12, 19, 6, 17)
              ..lineTo(3, 20)
              ..lineTo(5, 16)
              ..close(),
            ink,
          )
          ..drawCircle(const Offset(14, 10), 1, fill)
          ..drawPath(
            Path()
              ..moveTo(9, 13)
              ..quadraticBezierTo(12, 16, 15, 13),
            ink,
          );
      case 6: // Turtle.
        canvas
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(12, 12),
              width: 11,
              height: 13,
            ),
            ink,
          )
          ..drawPath(
            Path()
              ..moveTo(12, 8)
              ..lineTo(14.5, 12)
              ..lineTo(12, 16)
              ..lineTo(9.5, 12)
              ..close(),
            ink,
          )
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(12, 4.5),
              width: 3.5,
              height: 3.8,
            ),
            ink,
          )
          ..drawLine(const Offset(6.5, 8), const Offset(3.5, 6), ink)
          ..drawLine(const Offset(17.5, 8), const Offset(20.5, 6), ink)
          ..drawLine(const Offset(6.5, 16), const Offset(4, 18), ink)
          ..drawLine(const Offset(17.5, 16), const Offset(20, 18), ink);
    }
  }
}
