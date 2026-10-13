import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Clean, mathematically symmetrical geometric vector emblem for MotoVault.
/// Combines a hexagonal vault shield, precision speedometer arc, and bold MV monogram.
class MotoVaultLogo extends StatelessWidget {
  final double size;
  final bool showContainer;

  const MotoVaultLogo({
    super.key,
    this.size = 72,
    this.showContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final badge = CustomPaint(
      size: Size.square(showContainer ? size * 0.72 : size),
      painter: _MotoVaultEmblemPainter(),
    );

    if (!showContainer) {
      return SizedBox.square(dimension: size, child: Center(child: badge));
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E3A8A),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.38),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.28),
            blurRadius: size * 0.22,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(child: badge),
    );
  }
}

class _MotoVaultEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = math.min(w, h) / 2;

    // 1. Subtle outer hexagonal vault shield
    final shieldPath = Path();
    final pts = <Offset>[
      Offset(cx, cy - r * 0.95), // Top peak
      Offset(cx + r * 0.84, cy - r * 0.48), // Top right
      Offset(cx + r * 0.76, cy + r * 0.36), // Bottom right
      Offset(cx, cy + r * 0.95), // Bottom point
      Offset(cx - r * 0.76, cy + r * 0.36), // Bottom left
      Offset(cx - r * 0.84, cy - r * 0.48), // Top left
    ];

    shieldPath.addPolygon(pts, true);

    final shieldFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E293B),
          Color(0xFF0F172A),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, shieldFill);

    final shieldBorder = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF38BDF8),
          Color(0xFF2563EB),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.075
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(shieldPath, shieldBorder);

    // 2. Symmetrical upper precision gauge arc
    final arcRadius = r * 0.60;
    final arcCenter = Offset(cx, cy - r * 0.04);
    final arcRect = Rect.fromCircle(center: arcCenter, radius: arcRadius);

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      arcRect,
      math.pi * 1.12,
      math.pi * 0.76,
      false,
      trackPaint,
    );

    final activeArcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF06B6D4)],
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.075
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      arcRect,
      math.pi * 1.25,
      math.pi * 0.50,
      false,
      activeArcPaint,
    );

    // 3. Bold symmetrical 'M' + 'V' geometric monogram
    final mvPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.145
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final mPath = Path()
      ..moveTo(cx - r * 0.44, cy + r * 0.24)
      ..lineTo(cx - r * 0.30, cy - r * 0.20)
      ..lineTo(cx, cy + r * 0.12)
      ..lineTo(cx + r * 0.30, cy - r * 0.20)
      ..lineTo(cx + r * 0.44, cy + r * 0.24);
    canvas.drawPath(mPath, mvPaint);

    // Lower 'V' vault chevron in Electric Cyan
    final vPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFF06B6D4)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy + r * 0.4), radius: r * 0.4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.125
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final vPath = Path()
      ..moveTo(cx - r * 0.26, cy + r * 0.36)
      ..lineTo(cx, cy + r * 0.64)
      ..lineTo(cx + r * 0.26, cy + r * 0.36);
    canvas.drawPath(vPath, vPaint);

    // Top apex precision dot
    final dotPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - r * 0.38), r * 0.065, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
