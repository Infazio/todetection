import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  List<Face> facesList;
  dynamic imageFile; // ui.Image
  Map<int, String> faceNames;
  Map<int, double>? faceConfidences; // Optional untuk registration
  Map<int, bool>? isRecognized; // Optional untuk registration

  FacePainter({
    required this.facesList,
    required this.imageFile,
    required this.faceNames,
    this.faceConfidences, // Optional
    this.isRecognized, // Optional
  });

  @override
  void paint(Canvas canvas, Size size) {
    print("=== FacePainter paint called ===");
    print("imageFile is null: ${imageFile == null}");
    print("facesList length: ${facesList.length}");
    print("faceNames: $faceNames");
    print("Canvas size: ${size.width} x ${size.height}");

    // Gambar image terlebih dahulu sebagai background
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
      print("Image drawn successfully");
    }

    // Gambar rectangle dan label untuk setiap wajah
    for (int i = 0; i < facesList.length; i++) {
      Face face = facesList[i];
      print("Drawing face $i at ${face.boundingBox}");

      // Tentukan warna berdasarkan recognition status (jika ada)
      final bool recognized = isRecognized?[i] ?? false;
      final Color rectColor = recognized
          ? Colors.green
          : (isRecognized != null ? Colors.orange : Colors.green);

      // Paint untuk kotak wajah
      Paint p = Paint();
      p.color = rectColor;
      p.style = PaintingStyle.stroke;
      p.strokeWidth = 3;

      // Paint untuk label
      final labelPaint = Paint()..color = rectColor.withOpacity(0.8);

      // Gambar kotak wajah
      canvas.drawRect(face.boundingBox, p);

      // Buat label dengan atau tanpa confidence
      String faceLabel;
      if (recognized && faceConfidences != null) {
        final name = faceNames[i] ?? 'Unknown';
        final confidence = faceConfidences![i] ?? 0.0;
        faceLabel = '$name (${confidence.toStringAsFixed(0)}%)';
      } else {
        faceLabel = faceNames[i] ?? 'Face ${i + 1}';
      }

      print("Face $i label: '$faceLabel'");

      // HITUNG font size berdasarkan ukuran wajah
      double faceWidth = face.boundingBox.width;
      double fontSize = (faceWidth / 7).clamp(18.0, 30.0);

      final textSpan = TextSpan(
        text: faceLabel,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: recognized ? FontWeight.bold : FontWeight.w500,
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

      // Background label - DYNAMIC size
      double labelHeight = fontSize + 2;
      final labelRect = Rect.fromLTWH(
        face.boundingBox.left,
        face.boundingBox.top - labelHeight - 2,
        textPainter.width + 2,
        labelHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, Radius.circular(8)),
        labelPaint,
      );

      // Text label
      textPainter.paint(
        canvas,
        Offset(
          face.boundingBox.left + 5,
          face.boundingBox.top - labelHeight + 2,
        ),
      );

      print("Face $i label '$faceLabel' painted with fontSize: $fontSize");
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
