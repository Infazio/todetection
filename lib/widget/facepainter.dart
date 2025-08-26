import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  List<Face> facesList;
  dynamic imageFile; // Ini akan menjadi ui.Image

  FacePainter({required this.facesList, required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    print("=== FacePainter paint called ===");
    print("imageFile is null: ${imageFile == null}");
    print("facesList length: ${facesList.length}");
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

      // Gambar label nomor wajah
      final textSpan = TextSpan(
        text: 'Face ${i + 1}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Background label
      final labelRect = Rect.fromLTWH(
        face.boundingBox.left,
        face.boundingBox.top - 25,
        textPainter.width + 8,
        22,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, Radius.circular(4)),
        labelPaint,
      );

      // Text label
      textPainter.paint(
        canvas,
        Offset(face.boundingBox.left + 4, face.boundingBox.top - 22),
      );
    }
    print("=== FacePainter paint finished ===");
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
