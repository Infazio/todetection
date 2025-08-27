import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:get/get.dart';

import '../../../services/camera_service.dart';

class RecognitionController extends GetxController {
  // Services
  final CameraService _cameraService = CameraService();
  late final FaceDetector _faceDetector;

  // Reactive variables
  var isInitialized = false.obs;
  var isDetecting = false.obs;
  var faces = <Face>[].obs;
  var faceNames = <int, String>{}.obs; // Will be used later for recognition
  var errorMessage = ''.obs;
  var detectionStats = ''.obs;

  // Camera info
  var cameraInfo = ''.obs;
  var isBackCamera = true.obs;

  // Detection control
  Timer? _detectionTimer;
  bool _isProcessingFrame = false;
  static const int detectionIntervalMs = 100; // Process every 100ms

  @override
  void onInit() {
    super.onInit();
    _initializeFaceDetector();
    _initializeCamera();
  }

  // Initialize face detector
  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast, // Fast mode for real-time
      enableContours: false,
      enableLandmarks: false,
      enableClassification: false,
      enableTracking: true, // Good for live detection
    );
    _faceDetector = FaceDetector(options: options);
    print("✅ Face detector initialized");
  }

  // Initialize camera
  Future<void> _initializeCamera() async {
    try {
      errorMessage('');
      print("🎥 Starting camera initialization...");

      final success = await _cameraService.initialize();
      if (success) {
        isInitialized(true);
        _updateCameraInfo();
        _startDetection();
        print("✅ Camera initialized successfully");
      } else {
        errorMessage('Gagal menginisialisasi kamera');
        print("❌ Camera initialization failed");
      }
    } catch (e) {
      errorMessage('Error: ${e.toString()}');
      print("❌ Camera initialization error: $e");
    }
  }

  // Update camera info
  void _updateCameraInfo() {
    cameraInfo(_cameraService.getCameraInfo());
    isBackCamera(
      _cameraService.currentCamera?.lensDirection == CameraLensDirection.back,
    );
  }

  // Start face detection
  void _startDetection() {
    if (!isInitialized.value) return;

    isDetecting(true);
    _detectionTimer = Timer.periodic(
      Duration(milliseconds: detectionIntervalMs),
      (_) => _processFrame(),
    );
    print("🔍 Face detection started");
  }

  // Stop face detection
  void _stopDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = null;
    isDetecting(false);
    faces.clear();
    faceNames.clear();
    print("⏹️ Face detection stopped");
  }

  // Process camera frame for face detection
  Future<void> _processFrame() async {
    if (_isProcessingFrame || !isInitialized.value) return;
    if (_cameraService.controller == null) return;

    try {
      _isProcessingFrame = true;

      // Capture image from camera
      final XFile imageFile = await _cameraService.controller!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

      // Detect faces
      final List<Face> detectedFaces = await _faceDetector.processImage(
        inputImage,
      );

      // Update faces list
      faces.assignAll(detectedFaces);

      // Clear existing names (will be filled by recognition later)
      faceNames.clear();

      // Update stats
      _updateDetectionStats(detectedFaces.length);

      // Clean up temp file - FIX: Convert XFile to File untuk delete
      final tempFile = File(imageFile.path);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      print("⚠️ Frame processing error: $e");
      // Don't update errorMessage for frame errors (too noisy)
    } finally {
      _isProcessingFrame = false;
    }
  }

  // Update detection statistics
  void _updateDetectionStats(int faceCount) {
    if (faceCount == 0) {
      detectionStats('Tidak ada wajah terdeteksi');
    } else if (faceCount == 1) {
      detectionStats('1 wajah terdeteksi');
    } else {
      detectionStats('$faceCount wajah terdeteksi');
    }
  }

  // Switch camera (front/back)
  Future<void> switchCamera() async {
    try {
      print("🔄 RECOGNITION: switchCamera() called");

      if (!isInitialized.value) {
        print("🔄 RECOGNITION: Not initialized, skipping");
        return;
      }

      // Stop detection first
      _stopDetection();

      // Set loading state
      isInitialized(false);

      print("🔄 RECOGNITION: Calling camera service switch...");
      final success = await _cameraService.switchCamera();
      print("🔄 RECOGNITION: Switch result: $success");

      if (success) {
        // Wait for camera to be fully ready
        await Future.delayed(Duration(milliseconds: 500));

        // Update camera info
        _updateCameraInfo();

        // Set initialized back to true
        isInitialized(true);

        // Wait a bit more for UI to settle
        await Future.delayed(Duration(milliseconds: 200));

        // Restart detection
        _startDetection();

        print("🔄 RECOGNITION: Switch completed successfully");

        Get.snackbar(
          'Camera',
          'Switched to ${_cameraService.getCameraInfo()}',
          duration: Duration(seconds: 1),
          snackPosition: SnackPosition.TOP,
        );
      } else {
        print("🔄 RECOGNITION: Switch failed, reverting...");
        isInitialized(true);
        _startDetection(); // Resume with current camera

        errorMessage('Gagal mengganti kamera');
      }
    } catch (e) {
      print("🔄 RECOGNITION: Switch error: $e");
      isInitialized(true);
      _startDetection();
      errorMessage('Error switching camera: ${e.toString()}');
    }
  }

  // Toggle detection on/off
  void toggleDetection() {
    if (isDetecting.value) {
      _stopDetection();
    } else {
      _startDetection();
    }
  }

  // Get camera controller for preview
  CameraController? get cameraController => _cameraService.controller;

  // Get preview size for coordinate transformation
  Size get previewSize {
    if (!isInitialized.value) return Size.zero;
    final controller = _cameraService.controller;
    if (controller == null) return Size.zero;
    return Size(
      controller.value.previewSize?.height ?? 0,
      controller.value.previewSize?.width ?? 0,
    );
  }

  // Get image size for coordinate transformation
  Size get imageSize {
    if (!isInitialized.value) return Size.zero;
    final controller = _cameraService.controller;
    if (controller == null) return Size.zero;
    final previewSize = controller.value.previewSize;
    return Size(previewSize?.height ?? 0, previewSize?.width ?? 0);
  }

  @override
  void onClose() {
    print("🗑️ Disposing recognition controller...");
    _stopDetection();
    _faceDetector.close();
    _cameraService.dispose();
    super.onClose();
  }
}
