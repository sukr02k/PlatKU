import 'package:flutter/material.dart';

/// PlatKU brand emblem — a vehicle license-plate motif.
/// A graphite license plate with a red racing stripe and bold "KU" monogram,
/// finished with metallic corner bolts for a tactile, automotive feel.
class PlatkuLogo extends StatelessWidget {
  final double size;
  final bool showContainer;

  const PlatkuLogo({
    super.key,
    this.size = 72,
    this.showContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final badge = CustomPaint(
      size: Size.square(showContainer ? size * 0.82 : size),
      painter: _PlatkuEmblemPainter(),
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
            Color(0xFF14171B),
            Color(0xFF2A2E34),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: const Color(0xFFDC2626).withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14171B).withValues(alpha: 0.32),
            blurRadius: size * 0.22,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(child: badge),
    );
  }
}

class _PlatkuEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // License plate: a wide rounded rectangle.
    final plateW = w * 0.86;
    final plateH = h * 0.56;
    final plateRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: plateW, height: plateH),
      Radius.circular(w * 0.09),
    );

    // Metallic plate body (graphite) with subtle vertical sheen.
    final plateFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2A2E34),
          Color(0xFF14171B),
        ],
      ).createShader(plateRect.outerRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(plateRect, plateFill);

    // Red racing outer border.
    final redBorder = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045;
    canvas.drawRRect(plateRect, redBorder);

    // Inner white hairline for registration-plate depth.
    final innerBorder = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018;
    canvas.drawRRect(
      plateRect.deflate(w * 0.055),
      innerBorder,
    );

    // Racing stripe accent on the left edge of the plate.
    final stripeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        plateRect.left + w * 0.10,
        plateRect.top + plateH * 0.16,
        w * 0.055,
        plateH * 0.68,
      ),
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(
      stripeRect,
      Paint()..color = const Color(0xFFDC2626),
    );

    // Bold "KU" monogram in white, right of the stripe.
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'KU',
        style: TextStyle(
          color: Colors.white,
          fontSize: h * 0.30,
          fontWeight: FontWeight.w800,
          letterSpacing: -h * 0.02,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        cx - textPainter.width / 2 + w * 0.035,
        cy - textPainter.height / 2,
      ),
    );

    // Four metallic corner bolts.
    final bolt = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF9AA3AF), Color(0xFF3F4650)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: w * 0.05))
      ..style = PaintingStyle.fill;
    final boltRadius = w * 0.035;
    for (final corner in [
      Offset(plateRect.left + w * 0.055, plateRect.top + plateH * 0.14),
      Offset(plateRect.right - w * 0.055, plateRect.top + plateH * 0.14),
      Offset(plateRect.left + w * 0.055, plateRect.bottom - plateH * 0.14),
      Offset(plateRect.right - w * 0.055, plateRect.bottom - plateH * 0.14),
    ]) {
      canvas.drawCircle(corner, boltRadius, bolt);
      canvas.drawCircle(
        corner,
        boltRadius * 0.42,
        Paint()..color = const Color(0xFF14171B),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}