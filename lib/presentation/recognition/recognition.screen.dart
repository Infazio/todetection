import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import '../../widgets/face_overlay_painter.dart';
import 'controllers/recognition.controller.dart';

class RecognitionScreen extends GetView<RecognitionController> {
  const RecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Live Face Recognition'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Simple detection toggle
          IconButton(
            icon: Icon(Icons.pause),
            onPressed: () {
              if (controller.isInitialized.value) {
                controller.toggleDetection();
              }
            },
            tooltip: 'Toggle Detection',
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return _buildLoadingView();
        }

        if (controller.errorMessage.isNotEmpty) {
          return _buildErrorView();
        }

        return _buildCameraView();
      }),
    );
  }

  // Loading view while initializing camera
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.blue),
          ),
          SizedBox(height: 20),
          Text(
            'Initializing Camera...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            'Please allow camera permission',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Error view
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Camera Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              controller.errorMessage.value,
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: controller.onInit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Main camera view with overlay - SIMPLE VERSION
  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera preview
        _buildCameraPreview(),

        // Face detection overlay
        _buildFaceOverlay(),

        // Simple switch button - TOP RIGHT
        Positioned(right: 16, top: 16, child: _buildSimpleSwitchButton()),

        // Info overlay
        _buildInfoOverlay(),
      ],
    );
  }

  // Simple switch button - NO OBX WRAPPER
  Widget _buildSimpleSwitchButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        icon: Icon(
          Icons.flip_camera_ios, // Universal camera flip icon
          color: Colors.white,
          size: 24,
        ),
        onPressed: () {
          if (controller.isInitialized.value) {
            controller.switchCamera();
          }
        },
        tooltip: 'Switch Camera',
      ),
    );
  }

  // Camera preview widget - SIMPLE VERSION
  Widget _buildCameraPreview() {
    return Obx(() {
      final controller = this.controller.cameraController;

      // Check initialization state
      if (!this.controller.isInitialized.value ||
          controller == null ||
          !controller.value.isInitialized) {
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Initializing Camera...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }

      // Add key to force widget rebuild when camera changes
      return Container(
        key: ValueKey('camera_${this.controller.isBackCamera.value}'),
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: _buildProperCameraPreview(controller),
      );
    });
  }

  Widget _buildProperCameraPreview(CameraController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen dimensions
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final screenAspectRatio = screenWidth / screenHeight;

        // Get camera aspect ratio
        var cameraAspectRatio = 9 / 16;

        // 🎯 CUSTOM ASPECT RATIO OVERRIDE (uncomment yang diinginkan):
        // cameraAspectRatio = 4 / 3;      // Force 4:3 (classic camera)
        // cameraAspectRatio = 16 / 9;     // Force 16:9 (widescreen)
        // cameraAspectRatio = 3 / 4;      // Portrait 3:4
        // cameraAspectRatio = 1;          // Square 1:1
        // cameraAspectRatio = 18 / 9;     // Ultra-wide 18:9

        print(
          "📱 Screen: ${screenWidth.toInt()}x${screenHeight.toInt()} (ratio: ${screenAspectRatio.toStringAsFixed(2)})",
        );
        print("📷 Camera: ratio ${cameraAspectRatio.toStringAsFixed(2)}");

        // 🎛 SCALE FACTOR CONTROL (adjust untuk zoom in/out):
        final scaleFactor =
            1.0; // 1.0 = normal, 1.2 = zoom in 20%, 0.8 = zoom out 20%

        // Choose proper fit method
        Widget cameraWidget;

        if (cameraAspectRatio > screenAspectRatio) {
          // Camera is wider than screen - fit height, crop width
          cameraWidget = Center(
            child: AspectRatio(
              aspectRatio: cameraAspectRatio,
              child: Transform.scale(
                scale: scaleFactor, // 🎯 SCALE CONTROL
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: SizedBox(
                      width: screenWidth,
                      height: screenWidth / cameraAspectRatio,
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          // Camera is taller than screen - fit width, crop height
          cameraWidget = Center(
            child: AspectRatio(
              aspectRatio: cameraAspectRatio,
              child: Transform.scale(
                scale: scaleFactor, // 🎯 SCALE CONTROL
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: SizedBox(
                      width: screenHeight * cameraAspectRatio,
                      height: screenHeight,
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return cameraWidget;
      },
    );
  }

  // Face detection overlay
  Widget _buildFaceOverlay() {
    return Positioned.fill(
      child: Obx(() {
        if (controller.faces.isEmpty) {
          return SizedBox.shrink();
        }

        return CustomPaint(
          painter: FaceOverlayPainter(
            faces: controller.faces,
            imageSize: controller.imageSize,
            previewSize: controller.previewSize,
            faceNames: controller.faceNames,
            isBackCamera: controller.isBackCamera.value,
          ),
        );
      }),
    );
  }

  // Information overlay
  Widget _buildInfoOverlay() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 100,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Detection status
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: controller.isDetecting.value
                          ? Colors.green
                          : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    controller.detectionStats.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            // Camera info
            Obx(
              () => Text(
                controller.cameraInfo.value,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
