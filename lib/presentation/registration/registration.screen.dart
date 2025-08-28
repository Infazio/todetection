// File: lib/presentation/registration/registration.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../theme/app_theme.dart';
import '../../widgets/breadcrumb_indicator.dart';
import '../../widgets/facepainter.dart';
import 'controllers/registration.controller.dart';

class RegistrationScreen extends GetView<RegistrationController> {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightPrimary,
      appBar: AppBar(
        title: Text(
          'Face Registration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.resetDetection,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb
          Obx(
            () => BreadcrumbIndicator(
              currentStep: _getCurrentStep(),
              totalSteps: 3,
              stepLabels: ['Capture', 'Detect', 'Name'],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Status Panel
                  Obx(() => _buildStatusPanel()),

                  SizedBox(height: 16),

                  // Image Container
                  _buildImageContainer(),

                  SizedBox(height: 16),

                  // Face Details (collapsed by default)
                  Obx(() => _buildFaceDetailsPanel()),

                  SizedBox(height: 16),

                  // Action Buttons
                  _buildActionButtons(),

                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCurrentStep() {
    if (controller.imageFile.value == null) return 1;
    if (controller.faces.isEmpty) return 2;
    return 3;
  }

  Widget _buildStatusPanel() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _getStatusGradient(controller.captureStatus.value),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(controller.captureStatus.value),
            color: Colors.white,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            controller.captureStatus.value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (controller.faces.isNotEmpty &&
              controller.faces.first.smilingProbability != null)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Expression: ${_getExpressionSummary(controller.faces.first)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  LinearGradient _getStatusGradient(String status) {
    if (status.contains('Error') || status.contains('Gagal')) {
      return LinearGradient(colors: [AppTheme.error, Colors.red.shade600]);
    } else if (status.contains('deteksi') || status.contains('terdeteksi')) {
      return AppTheme.primaryGradient;
    } else if (status.contains('Memproses') || status.contains('Mendeteksi')) {
      return LinearGradient(colors: [AppTheme.warning, Colors.orange.shade600]);
    }
    return AppTheme.accentGradient;
  }

  IconData _getStatusIcon(String status) {
    if (status.contains('Error') || status.contains('Gagal')) {
      return Icons.error_outline;
    } else if (status.contains('deteksi') || status.contains('terdeteksi')) {
      return Icons.face_retouching_natural;
    } else if (status.contains('Memproses') || status.contains('Mendeteksi')) {
      return Icons.hourglass_bottom;
    }
    return Icons.photo_camera;
  }

  Widget _buildImageContainer() {
    final screenSize = MediaQuery.of(Get.context!).size;
    final imageHeight = screenSize.height * 0.45;
    final imageWidth = screenSize.width - 32;

    return Container(
      width: imageWidth,
      height: imageHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Obx(() => _buildImageContent(imageWidth, imageHeight)),
      ),
    );
  }

  Widget _buildImageContent(double containerWidth, double containerHeight) {
    if (controller.imageFile.value == null) {
      return Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_camera_outlined,
                size: 64,
                color: AppTheme.darkTertiary,
              ),
              SizedBox(height: 16),
              Text(
                'No Image Selected',
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.darkTertiary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Choose camera or gallery to start',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (controller.decodedImage.value == null) {
      return Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryPurple),
              ),
              SizedBox(height: 16),
              Text("Processing image...", style: AppTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    final image = controller.decodedImage.value!;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: image.width.toDouble(),
        height: image.height.toDouble(),
        child: CustomPaint(
          key: ValueKey(
            '${controller.faceNames.length}_${controller.faceNames.hashCode}',
          ),
          painter: FacePainter(
            facesList: controller.faces,
            imageFile: image,
            faceNames: Map<int, String>.from(controller.faceNames),
          ),
        ),
      ),
    );
  }

  Widget _buildFaceDetailsPanel() {
    if (controller.faceDetails.isEmpty) return SizedBox.shrink();

    return ExpansionTile(
      initiallyExpanded: false,
      backgroundColor: AppTheme.lightPrimary,
      collapsedBackgroundColor: AppTheme.lightPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(color: AppTheme.lightSecondary),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(color: AppTheme.lightSecondary),
      ),
      leading: Icon(Icons.analytics_outlined, color: AppTheme.primaryPurple),
      title: Text(
        'Detection Details',
        style: AppTheme.titleMedium.copyWith(
          fontSize: 14,
          color: AppTheme.primaryPurple,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: 150),
          padding: EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: controller.faceDetails
                  .take(10)
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
                              color: AppTheme.primaryPurple,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              detail,
                              style: AppTheme.bodyMedium.copyWith(fontSize: 11),
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
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action - Camera
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => AppTheme.gradientButton(
              text: controller.isLoading.value ? 'Processing...' : 'Take Photo',
              icon: controller.isLoading.value ? null : Icons.camera_alt,
              onPressed: controller.isLoading.value
                  ? () {}
                  : controller.imgFromCamera,
            ),
          ),
        ),

        SizedBox(height: 12),

        // Secondary action - Gallery
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.lightSecondary,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.primaryPurple.withValues(alpha: 0.3),
              ),
            ),
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.imgFromGallery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppTheme.primaryPurple,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Choose from Gallery',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Next step indicator
        if (controller.faces.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppTheme.success),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Great! ${controller.faces.length} face(s) detected. Names will be assigned next.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _getExpressionSummary(Face face) {
    if (face.smilingProbability != null) {
      if (face.smilingProbability! > 0.6) return 'Smiling';
      if (face.smilingProbability! > 0.3) return 'Slight smile';
    }
    return 'Neutral';
  }
}
