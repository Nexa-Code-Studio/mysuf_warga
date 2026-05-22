import 'package:flutter/material.dart';

class CameraOverlayPainter extends CustomPainter {
  final Rect cutoutRect;
  final bool isOval;

  CameraOverlayPainter({
    required this.cutoutRect,
    this.isOval = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Draw background
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw cutout
    final cutoutPath = Path();
    if (isOval) {
      cutoutPath.addOval(cutoutRect);
    } else {
      cutoutPath.addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)));
    }

    final path = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    canvas.drawPath(path, paint);
    
    // Draw Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    if (isOval) {
      canvas.drawOval(cutoutRect, borderPaint);
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)), borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
