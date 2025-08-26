import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  List<Face> facesList;
  dynamic imageFile; // Ini akan menjadi ui.Image
  Map<int, String> faceNames;

  FacePainter({
    required this.facesList,
    required this.imageFile,
    required this.faceNames,
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

    // Paint untuk kotak wajah
    Paint p = Paint();
    p.color = Colors.green;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;

    // Paint untuk label
    final labelPaint = Paint()..color = Colors.green.withOpacity(0.8);

    // Gambar rectangle dan label untuk setiap wajah
    for (int i = 0; i < facesList.length; i++) {
      Face face = facesList[i];
      print("Drawing face $i at ${face.boundingBox}");

      // Gambar kotak wajah
      canvas.drawRect(face.boundingBox, p);

      // Gunakan nama custom atau default
      String faceLabel = faceNames[i] ?? 'Face ${i + 1}';
      print("Face $i label: '$faceLabel'");

      // HITUNG font size berdasarkan ukuran wajah
      double faceWidth = face.boundingBox.width;
      double fontSize = (faceWidth / 7).clamp(18.0, 30.0); // Min 14, Max 24

      final textSpan = TextSpan(
        text: faceLabel,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize, // DYNAMIC font size
          fontWeight: FontWeight.bold,
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
      double labelHeight = fontSize + 8;
      final labelRect = Rect.fromLTWH(
        face.boundingBox.left,
        face.boundingBox.top - labelHeight - 5,
        textPainter.width + 16,
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
          face.boundingBox.left + 8,
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
