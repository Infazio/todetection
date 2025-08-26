import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../widget/facepainter.dart';
import 'controllers/registration.controller.dart';

class RegistrationScreen extends GetView<RegistrationController> {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrasi Wajah'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.resetDetection,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Panel
            Obx(() => _buildStatusPanel()),

            SizedBox(height: 16),

            // Fixed Size Image Container - UKURAN TETAP
            _buildFixedSizeImageContainer(),

            SizedBox(height: 16),

            // Face Details Panel
            Obx(() => _buildFaceDetailsPanel()),

            SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(),

            // Extra spacing untuk scroll
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPanel() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(controller.captureStatus.value),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            controller.captureStatus.value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          if (controller.faces.isNotEmpty) ...[
            if (controller.faces.first.smilingProbability != null)
              Text(
                'Ekspresi: ${_getExpressionSummary(controller.faces.first)}',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildFixedSizeImageContainer() {
    // Dapatkan ukuran layar
    final screenSize = MediaQuery.of(Get.context!).size;
    final imageHeight = screenSize.height * 0.5; // 50% dari tinggi layar
    final imageWidth = screenSize.width - 32; // Full width minus padding

    return Obx(() {
      if (controller.imageFile.value == null) {
        return Container(
          width: imageWidth,
          height: imageHeight,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera, size: 50, color: Colors.grey[400]),
                SizedBox(height: 10),
                Text(
                  'Belum ada gambar',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Pilih dari kamera atau galeri',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        width: imageWidth,
        height: imageHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildImageWithPainter(imageWidth, imageHeight),
        ),
      );
    });
  }

  Widget _buildImageWithPainter(double containerWidth, double containerHeight) {
    return Obx(() {
      print("Building painter widget...");
      print(
        "decodedImage.value is null: ${controller.decodedImage.value == null}",
      );
      print("faces count: ${controller.faces.length}");

      if (controller.decodedImage.value == null) {
        print("Showing loading indicator");
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.blue[800]),
              ),
              SizedBox(height: 10),
              Text("Memproses gambar...", style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      }

      final image = controller.decodedImage.value!;
      print("Image ready - dimensions: ${image.width} x ${image.height}");

      return FittedBox(
        child: SizedBox(
          width: image.width.toDouble(),
          height: image.height.toDouble(),
          child: CustomPaint(
            painter: FacePainter(
              facesList: controller.faces,
              imageFile: image,
              faceNames: controller.faceNames,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFaceDetailsPanel() {
    if (controller.faceDetails.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: 200, // Batasi tinggi maksimal
      ),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[800]),
              SizedBox(width: 4),
              Text(
                'Detail Deteksi:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: controller.faceDetails
                    .take(15) // Batasi jumlah detail
                    .map(
                      (detail) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                detail,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.imgFromCamera,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8),
                      Text('Ambil dari Kamera'),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.imgFromGallery,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.grey[800],
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library),
                SizedBox(width: 8),
                Text('Pilih dari Galeri'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('Error') || status.contains('Gagal')) {
      return Colors.red;
    } else if (status.contains('deteksi') || status.contains('terdeteksi')) {
      return Colors.green;
    } else if (status.contains('Memproses') || status.contains('Mendeteksi')) {
      return Colors.orange;
    }
    return Colors.blue;
  }
}

String _getExpressionSummary(Face face) {
  if (face.smilingProbability != null) {
    if (face.smilingProbability! > 0.6) return 'Tersenyum';
    if (face.smilingProbability! > 0.3) return 'Sedikit senyum';
  }
  return 'Netral';
}
