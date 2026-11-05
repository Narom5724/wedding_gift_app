import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:wedding_gift_app/constants/app_colors.dart';

class WeddingCoupleIllustration extends StatelessWidget {
  const WeddingCoupleIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WeddingCouplePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _WeddingCouplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 360, size.height / 320);

    final blush = Paint()..color = const Color(0xFFFFE9E9);
    canvas.drawOval(const Rect.fromLTWH(30, 26, 300, 270), blush);

    final goldStroke = Paint()
      ..color = AppColors.champagneGold.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final arch = Path()
      ..moveTo(48, 285)
      ..cubicTo(42, 112, 84, 28, 180, 28)
      ..cubicTo(276, 28, 318, 112, 312, 285);
    canvas.drawPath(arch, goldStroke);

    _drawLeaves(canvas, const Offset(62, 210), -1);
    _drawLeaves(canvas, const Offset(298, 210), 1);
    _drawFlowers(canvas, const Offset(72, 122));
    _drawFlowers(canvas, const Offset(288, 122));

    final groundPaint = Paint()..color = const Color(0xFFE7D5C6);
    canvas.drawOval(const Rect.fromLTWH(62, 267, 236, 22), groundPaint);

    _drawGroom(canvas);
    _drawBride(canvas);

    final heartPaint = Paint()..color = AppColors.rosePink;
    canvas.drawCircle(const Offset(180, 101), 7, heartPaint);
    canvas.drawCircle(const Offset(188, 101), 7, heartPaint);
    final heart = Path()
      ..moveTo(174, 104)
      ..lineTo(184, 116)
      ..lineTo(194, 104)
      ..close();
    canvas.drawPath(heart, heartPaint);

    canvas.restore();
  }

  void _drawGroom(Canvas canvas) {
    final skin = Paint()..color = const Color(0xFFD69B78);
    final hair = Paint()..color = const Color(0xFF3C2A28);
    final suit = Paint()..color = const Color(0xFF394650);
    final shirt = Paint()..color = const Color(0xFFFFFCF8);

    canvas.drawCircle(const Offset(139, 119), 29, hair);
    canvas.drawOval(const Rect.fromLTWH(116, 98, 46, 57), skin);
    final hairline = Path()
      ..moveTo(112, 120)
      ..cubicTo(111, 91, 128, 86, 146, 91)
      ..cubicTo(161, 94, 169, 106, 164, 121)
      ..lineTo(153, 110)
      ..cubicTo(141, 116, 127, 112, 112, 120)
      ..close();
    canvas.drawPath(hairline, hair);
    canvas.drawRect(const Rect.fromLTWH(131, 149, 16, 20), skin);

    final jacket = Path()
      ..moveTo(115, 166)
      ..lineTo(130, 158)
      ..lineTo(149, 158)
      ..lineTo(166, 168)
      ..lineTo(180, 267)
      ..lineTo(98, 267)
      ..close();
    canvas.drawPath(jacket, suit);

    final shirtFront = Path()
      ..moveTo(130, 159)
      ..lineTo(139, 176)
      ..lineTo(149, 159)
      ..lineTo(157, 166)
      ..lineTo(146, 202)
      ..lineTo(136, 202)
      ..lineTo(122, 166)
      ..close();
    canvas.drawPath(shirtFront, shirt);

    final tie = Path()
      ..moveTo(137, 174)
      ..lineTo(145, 174)
      ..lineTo(150, 185)
      ..lineTo(143, 218)
      ..lineTo(135, 185)
      ..close();
    canvas.drawPath(tie, Paint()..color = AppColors.rosePink);

    final lapel = Paint()
      ..color = const Color(0xFF53616A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(const Offset(116, 168), const Offset(134, 199), lapel);
    canvas.drawLine(const Offset(163, 168), const Offset(147, 199), lapel);

    canvas.drawLine(const Offset(105, 181), const Offset(91, 220), Paint()
      ..color = suit.color
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round);
    canvas.drawLine(const Offset(164, 181), const Offset(182, 211), Paint()
      ..color = suit.color
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(const Offset(90, 222), 7, skin);
    canvas.drawCircle(const Offset(184, 213), 7, skin);
  }

  void _drawBride(Canvas canvas) {
    final skin = Paint()..color = const Color(0xFFF0BE9F);
    final hair = Paint()..color = const Color(0xFF5A352F);
    final veil = Paint()..color = const Color(0xFFFFFCF8).withValues(alpha: 0.72);
    final dress = Paint()..color = const Color(0xFFFFFCF8);

    canvas.drawOval(const Rect.fromLTWH(195, 83, 74, 114), veil);
    canvas.drawCircle(const Offset(232, 120), 29, hair);
    canvas.drawOval(const Rect.fromLTWH(211, 98, 43, 55), skin);
    final hairline = Path()
      ..moveTo(207, 119)
      ..cubicTo(203, 91, 222, 86, 240, 91)
      ..cubicTo(255, 94, 261, 106, 257, 121)
      ..lineTo(248, 110)
      ..cubicTo(236, 116, 220, 112, 207, 119)
      ..close();
    canvas.drawPath(hairline, hair);
    canvas.drawRect(const Rect.fromLTWH(224, 148, 17, 20), skin);

    final skirt = Path()
      ..moveTo(211, 163)
      ..lineTo(225, 157)
      ..lineTo(242, 157)
      ..lineTo(256, 165)
      ..cubicTo(266, 202, 281, 234, 296, 267)
      ..lineTo(174, 267)
      ..cubicTo(190, 232, 202, 198, 211, 163)
      ..close();
    canvas.drawPath(skirt, dress);

    final bodice = Path()
      ..moveTo(216, 162)
      ..lineTo(226, 169)
      ..lineTo(234, 180)
      ..lineTo(243, 169)
      ..lineTo(252, 163)
      ..lineTo(259, 181)
      ..lineTo(248, 203)
      ..lineTo(218, 203)
      ..lineTo(208, 181)
      ..close();
    canvas.drawPath(bodice, Paint()..color = const Color(0xFFFFF8F2));

    final dressLine = Paint()
      ..color = const Color(0xFFE8D7C9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(233, 181), const Offset(233, 250), dressLine);
    canvas.drawLine(const Offset(204, 225), const Offset(263, 225), dressLine);

    canvas.drawLine(const Offset(211, 174), const Offset(190, 205), Paint()
      ..color = skin.color
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(const Offset(188, 207), 6, skin);
    canvas.drawLine(const Offset(255, 176), const Offset(270, 204), Paint()
      ..color = skin.color
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(const Offset(272, 206), 6, skin);

    _drawFlowers(canvas, const Offset(188, 207), scale: 0.52);
  }

  void _drawLeaves(Canvas canvas, Offset origin, double direction) {
    final stem = Paint()
      ..color = const Color(0xFF7D9B7E)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final leafPaint = Paint()..color = const Color(0xFF9CB49A);

    for (var index = 0; index < 4; index++) {
      final y = origin.dy - index * 27;
      final x = origin.dx + direction * index * 3;
      canvas.drawLine(Offset(origin.dx, origin.dy + 24), Offset(x, y), stem);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(direction * (index.isEven ? -0.65 : 0.65));
      canvas.drawOval(const Rect.fromLTWH(-15, -5, 22, 10), leafPaint);
      canvas.restore();
    }
  }

  void _drawFlowers(Canvas canvas, Offset center, {double scale = 1}) {
    final petal = Paint()..color = const Color(0xFFFFFCF8);
    final centerPaint = Paint()..color = AppColors.champagneGold;
    for (var index = 0; index < 5; index++) {
      final angle = index * 1.2566;
      final offset = Offset(
        center.dx + 7 * scale * math.cos(angle),
        center.dy + 7 * scale * math.sin(angle),
      );
      canvas.drawCircle(offset, 5 * scale, petal);
    }
    canvas.drawCircle(center, 3.5 * scale, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
