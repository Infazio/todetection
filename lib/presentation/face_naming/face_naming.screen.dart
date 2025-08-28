// File: lib/presentation/face_naming/face_naming.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../widgets/breadcrumb_indicator.dart';
import 'controllers/face_naming.controller.dart';

class FaceNamingScreen extends GetView<FaceNamingController> {
  const FaceNamingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.handleBackButton();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightPrimary,
        appBar: AppBar(
          title: Text(
            'Name the Faces',
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
            onPressed: controller.handleBackButton,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.white),
              onPressed: controller.showDatabaseStats,
              tooltip: 'Database Info',
            ),
          ],
        ),
        body: Column(
          children: [
            // Breadcrumb
            BreadcrumbIndicator(
              currentStep: 3,
              totalSteps: 3,
              stepLabels: ['Capture', 'Detect', 'Name'],
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header info
                    _buildHeaderInfo(),

                    SizedBox(height: 16),

                    // Face matching status
                    Obx(() => _buildMatchingStatus()),

                    SizedBox(height: 16),

                    // Face names list
                    Expanded(child: _buildFaceNamesList()),

                    // Bottom buttons
                    _buildBottomButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.face_retouching_natural,
            size: 32,
            color: AppTheme.primaryPurple,
          ),
          SizedBox(height: 8),
          Text(
            '${controller.faceCount} ${controller.faceCount == 1 ? 'Face' : 'Faces'} Detected',
            style: AppTheme.titleMedium.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPurple,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Assign names to each detected face',
            style: AppTheme.bodyMedium.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingStatus() {
    if (controller.isMatchingFaces.value) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.info.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppTheme.info),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Matching faces with database...',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (controller.faceMatchResults.isNotEmpty) {
      final matchedFaces = controller.faceMatchResults
          .where((result) => result['matchFound'] == true)
          .length;
      final totalFaces = controller.faceMatchResults.length;

      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: matchedFaces > 0
              ? AppTheme.success.withValues(alpha: 0.1)
              : AppTheme.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: matchedFaces > 0
                ? AppTheme.success.withValues(alpha: 0.3)
                : AppTheme.warning.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              matchedFaces > 0
                  ? Icons.face_retouching_natural
                  : Icons.face_unlock_outlined,
              color: matchedFaces > 0 ? AppTheme.success : AppTheme.warning,
              size: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                matchedFaces > 0
                    ? '$matchedFaces of $totalFaces faces recognized from database'
                    : 'All faces are new - not found in database',
                style: AppTheme.bodyMedium.copyWith(
                  color: matchedFaces > 0 ? AppTheme.success : AppTheme.warning,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildFaceNamesList() {
    return ListView.builder(
      itemCount: controller.faceCount,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: AppTheme.lightSecondary),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                // Face thumbnail
                _buildFaceThumbnail(index),

                SizedBox(width: 12),

                // Name input section
                Expanded(child: _buildNameInput(index)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaceThumbnail(int index) {
    final thumbnail = controller.getThumbnail(index);

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium - 1),
        child: thumbnail != null
            ? Stack(
                children: [
                  Image.memory(
                    thumbnail,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  // Face number badge
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Recognition status indicator
                  Obx(() {
                    if (controller.faceMatchResults.isNotEmpty &&
                        index < controller.faceMatchResults.length) {
                      final result = controller.faceMatchResults[index];
                      final isRecognized = result['matchFound'] == true;

                      return Positioned(
                        bottom: 2,
                        left: 2,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isRecognized
                                ? AppTheme.success
                                : AppTheme.warning,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            isRecognized ? Icons.check : Icons.add,
                            color: Colors.white,
                            size: 8,
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                ],
              )
            : Container(
                color: AppTheme.lightSecondary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.face, color: AppTheme.darkTertiary, size: 20),
                    SizedBox(height: 2),
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppTheme.darkTertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNameInput(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Face label with recognition status
        Row(
          children: [
            Text(
              'Face ${index + 1}',
              style: AppTheme.titleMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Obx(() {
              if (controller.faceMatchResults.isNotEmpty &&
                  index < controller.faceMatchResults.length) {
                final result = controller.faceMatchResults[index];
                final isRecognized = result['matchFound'] == true;
                final confidence = result['confidence']?.toDouble() ?? 0.0;

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isRecognized
                        ? AppTheme.success.withValues(alpha: 0.2)
                        : AppTheme.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isRecognized
                        ? '${confidence.toStringAsFixed(0)}% match'
                        : 'New',
                    style: TextStyle(
                      color: isRecognized ? AppTheme.success : AppTheme.warning,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }),
          ],
        ),

        SizedBox(height: 8),

        // Name suggestions
        _buildNameSuggestions(index),

        // Name input field
        TextField(
          controller: controller.getTextController(index),
          decoration: InputDecoration(
            hintText: 'Enter name...',
            hintStyle: TextStyle(
              color: AppTheme.darkTertiary.withValues(alpha: 0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(color: AppTheme.lightSecondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide(color: AppTheme.lightSecondary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            prefixIcon: Icon(
              Icons.person_outline,
              color: AppTheme.darkTertiary.withValues(alpha: 0.6),
              size: 18,
            ),
          ),
          style: AppTheme.bodyMedium.copyWith(fontSize: 13),
          onChanged: (value) {
            controller.updateFaceName(index, value.trim());
          },
        ),
        SizedBox(height: 4),
        Obx(() {
          final warning = controller.nameWarnings[index];
          if (warning != null && warning.isNotEmpty) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.warning,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      warning,
                      style: TextStyle(
                        color: AppTheme.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildNameSuggestions(int index) {
    final currentText = controller.getTextController(index).text;
    final suggestions = controller.getNameSuggestions(currentText);

    if (suggestions.isNotEmpty && currentText.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(bottom: 8),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: suggestions
              .map(
                (suggestion) => GestureDetector(
                  onTap: () {
                    controller.getTextController(index).text = suggestion;
                    controller.updateFaceName(index, suggestion);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentCyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightSecondary,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.darkTertiary.withValues(alpha: 0.3),
                ),
              ),
              child: ElevatedButton(
                onPressed: controller.handleBackButton,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppTheme.darkTertiary,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: 12),

          // Save & Continue button
          Expanded(
            flex: 2,
            child: Obx(
              () => AppTheme.gradientButton(
                text: controller.isSavingToDatabase.value
                    ? 'Saving...'
                    : 'Save & Continue',
                icon: controller.isSavingToDatabase.value
                    ? null
                    : Icons.check_circle_outline,
                onPressed: controller.isSavingToDatabase.value
                    ? () {}
                    : controller.saveNames,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
