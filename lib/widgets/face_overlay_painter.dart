import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceOverlayPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final Size previewSize;
  final Map<int, String> faceNames;
  final Map<int, double> faceConfidences; // NEW: Confidence values
  final Map<int, bool> isRecognized; // NEW: Recognition status
  final bool isBackCamera;

  FaceOverlayPainter({
    required this.faces,
    required this.imageSize,
    required this.previewSize,
    required this.faceNames,
    required this.faceConfidences,
    required this.isRecognized,
    this.isBackCamera = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    // Calculate scale factors for coordinate transformation
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (int i = 0; i < faces.length; i++) {
      final face = faces[i];
      final recognized = isRecognized[i] ?? false;

      // Choose colors based on recognition status
      final Color rectColor = recognized ? Colors.green : Colors.orange;
      final Color labelColor = recognized ? Colors.green : Colors.orange;

      // Paint for face rectangles
      final Paint facePaint = Paint()
        ..color = rectColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // Paint for labels background
      final Paint labelPaint = Paint()..color = labelColor.withOpacity(0.8);

      // Transform face bounding box to preview coordinates
      final transformedRect = _transformRect(
        face.boundingBox,
        scaleX,
        scaleY,
        size.width,
      );

      // Draw face rectangle
      canvas.drawRect(transformedRect, facePaint);

      // Get face label with confidence
      String label;
      if (recognized) {
        final name = faceNames[i] ?? 'Unknown';
        final confidence = faceConfidences[i] ?? 0.0;
        label = '$name (${confidence.toStringAsFixed(0)}%)';
      } else {
        label = faceNames[i] ?? 'Face ${i + 1}';
      }

      // Draw label
      _drawLabel(canvas, label, transformedRect, labelPaint, recognized);
    }
  }

  // Transform ML Kit coordinates to preview coordinates
  Rect _transformRect(
    Rect rect,
    double scaleX,
    double scaleY,
    double previewWidth,
  ) {
    double left, top, right, bottom;

    if (isBackCamera) {
      // Back camera - no horizontal flip needed
      left = rect.left * scaleX;
      right = rect.right * scaleX;
    } else {
      // Front camera - flip horizontally (mirror effect)
      left = previewWidth - (rect.right * scaleX);
      right = previewWidth - (rect.left * scaleX);
    }

    top = rect.top * scaleY;
    bottom = rect.bottom * scaleY;

    return Rect.fromLTRB(left, top, right, bottom);
  }

  // Draw label with background - ENHANCED with recognition styling
  void _drawLabel(
    Canvas canvas,
    String label,
    Rect faceRect,
    Paint labelPaint,
    bool recognized,
  ) {
    // Calculate font size based on face size
    final faceWidth = faceRect.width;
    final fontSize = (faceWidth / 8).clamp(14.0, 24.0);

    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: recognized
            ? FontWeight.bold
            : FontWeight.w500, // Bold for recognized
        shadows: [
          Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1, 1)),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Label background rectangle
    final labelHeight = fontSize + 8;
    final labelWidth = textPainter.width + 16;

    final labelRect = Rect.fromLTWH(
      faceRect.left,
      faceRect.top - labelHeight - 4,
      labelWidth,
      labelHeight,
    );

    // Draw label background with rounded corners
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, Radius.circular(8)),
      labelPaint,
    );

    // Draw text
    textPainter.paint(
      canvas,
      Offset(faceRect.left + 8, faceRect.top - labelHeight + 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for live updates
  }
}
