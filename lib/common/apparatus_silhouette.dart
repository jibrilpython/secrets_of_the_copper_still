import 'package:flutter/material.dart';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';
import 'package:secrets_of_the_copper_still/utils/const.dart';

class ApparatusSilhouette extends StatelessWidget {
  final ApparatusClassification type;
  final PreservationSoundness preservation;
  final double size;

  const ApparatusSilhouette({
    super.key,
    required this.type,
    required this.preservation,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOperational(preservation) ? kAccent : kSecondaryAccent;
    return CustomPaint(
      size: Size(size, size),
      painter: _ApparatusSilhouettePainter(type: type, color: color),
    );
  }
}

class _ApparatusSilhouettePainter extends CustomPainter {
  final ApparatusClassification type;
  final Color color;

  _ApparatusSilhouettePainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    switch (type) {
      case ApparatusClassification.gooseneckAlembic:
        _drawAlembic(canvas, size, paint, fill);
      case ApparatusClassification.glassRetort:
        _drawRetort(canvas, size, paint, fill);
      case ApparatusClassification.separationFunnel:
        _drawFunnel(canvas, size, paint, fill);
      case ApparatusClassification.fractionalColumn:
        _drawColumn(canvas, size, paint, fill);
      case ApparatusClassification.wormCondenser:
        _drawWorm(canvas, size, paint);
      case ApparatusClassification.steamJacketedPot:
        _drawPot(canvas, size, paint, fill);
      case ApparatusClassification.brassHydrometer:
        _drawHydrometer(canvas, size, paint);
      case ApparatusClassification.other:
        _drawGeneric(canvas, size, paint);
    }
  }

  void _drawAlembic(Canvas c, Size s, Paint p, Paint f) {
    final w = s.width;
    final h = s.height;
    final body = Path()
      ..moveTo(w * 0.35, h * 0.85)
      ..quadraticBezierTo(w * 0.2, h * 0.55, w * 0.5, h * 0.35)
      ..quadraticBezierTo(w * 0.8, h * 0.55, w * 0.65, h * 0.85)
      ..close();
    c.drawPath(body, f);
    c.drawPath(body, p);
    c.drawLine(Offset(w * 0.5, h * 0.35), Offset(w * 0.72, h * 0.12), p);
    c.drawLine(Offset(w * 0.72, h * 0.12), Offset(w * 0.85, h * 0.18), p);
  }

  void _drawRetort(Canvas c, Size s, Paint p, Paint f) {
    final w = s.width;
    final h = s.height;
    c.drawCircle(Offset(w * 0.45, h * 0.62), w * 0.22, f);
    c.drawCircle(Offset(w * 0.45, h * 0.62), w * 0.22, p);
    c.drawLine(Offset(w * 0.58, h * 0.48), Offset(w * 0.78, h * 0.15), p);
  }

  void _drawFunnel(Canvas c, Size s, Paint p, Paint f) {
    final w = s.width;
    final h = s.height;
    final cone = Path()
      ..moveTo(w * 0.25, h * 0.2)
      ..lineTo(w * 0.75, h * 0.2)
      ..lineTo(w * 0.52, h * 0.72)
      ..close();
    c.drawPath(cone, f);
    c.drawPath(cone, p);
    c.drawLine(Offset(w * 0.52, h * 0.72), Offset(w * 0.52, h * 0.85), p);
    c.drawCircle(Offset(w * 0.52, h * 0.88), 2, p..style = PaintingStyle.fill);
  }

  void _drawColumn(Canvas c, Size s, Paint p, Paint f) {
    final w = s.width;
    final h = s.height;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.38, h * 0.1, w * 0.24, h * 0.78),
      const Radius.circular(2),
    );
    c.drawRRect(rect, f);
    c.drawRRect(rect, p);
    for (var i = 1; i <= 4; i++) {
      final y = h * 0.1 + (h * 0.78 / 5) * i;
      c.drawLine(Offset(w * 0.38, y), Offset(w * 0.62, y), p);
    }
  }

  void _drawWorm(Canvas c, Size s, Paint p) {
    final w = s.width;
    final h = s.height;
    final path = Path()..moveTo(w * 0.15, h * 0.5);
    for (var i = 0; i < 4; i++) {
      path.cubicTo(
        w * (0.25 + i * 0.15),
        h * 0.15,
        w * (0.35 + i * 0.15),
        h * 0.85,
        w * (0.45 + i * 0.15),
        h * 0.5,
      );
    }
    c.drawPath(path, p);
  }

  void _drawPot(Canvas c, Size s, Paint p, Paint f) {
    final w = s.width;
    final h = s.height;
    final pot = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.35, w * 0.56, h * 0.5),
      Radius.circular(w * 0.08),
    );
    c.drawRRect(pot, f);
    c.drawRRect(pot, p);
    c.drawOval(
      Rect.fromLTWH(w * 0.18, h * 0.28, w * 0.64, h * 0.12),
      p,
    );
  }

  void _drawHydrometer(Canvas c, Size s, Paint p) {
    final w = s.width;
    final h = s.height;
    c.drawLine(Offset(w * 0.5, h * 0.12), Offset(w * 0.5, h * 0.82), p);
    c.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.82),
        width: w * 0.18,
        height: h * 0.12,
      ),
      p,
    );
    for (var i = 0; i < 3; i++) {
      c.drawLine(
        Offset(w * 0.42, h * (0.35 + i * 0.15)),
        Offset(w * 0.58, h * (0.35 + i * 0.15)),
        p,
      );
    }
  }

  void _drawGeneric(Canvas c, Size s, Paint p) {
    final w = s.width;
    final h = s.height;
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.25, h * 0.25, w * 0.5, h * 0.5),
        Radius.circular(w * 0.06),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _ApparatusSilhouettePainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}
