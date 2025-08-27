import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../../data/repositories/person_repositories.dart';
import '../../../services/camera_service.dart';
import '../../../services/face_recognition_service.dart';

class RecognitionController extends GetxController {
  // Services
  final CameraService _cameraService = CameraService();
  final PersonRepository _personRepository = PersonRepository();
  final FaceRecognitionService _faceRecognitionService =
      FaceRecognitionService();
  late final FaceDetector _faceDetector;

  // Reactive variables
  var isInitialized = false.obs;
  var isDetecting = false.obs;
  var faces = <Face>[].obs;
  var faceNames = <int, String>{}.obs;
  var faceConfidences = <int, double>{}.obs; // NEW: Store confidence values
  var isRecognized = <int, bool>{}.obs; // NEW: Track which faces are recognized
  var errorMessage = ''.obs;
  var detectionStats = ''.obs;

  // Camera info
  var cameraInfo = ''.obs;
  var isBackCamera = true.obs;

  // Face recognition control
  var isRecognitionEnabled = true.obs;
  var existingPersons = <Map<String, dynamic>>[].obs;
  var recognitionStats = ''.obs;

  // Detection control
  Timer? _detectionTimer;
  Timer? _recognitionTimer;
  bool _isProcessingFrame = false;
  bool _isProcessingRecognition = false;
  static const int detectionIntervalMs = 100; // Detect every 100ms
  static const int recognitionIntervalMs = 1000; // Recognize every 1 second
  static const double confidenceThreshold = 0.7; // 70% threshold

  @override
  void onInit() {
    super.onInit();
    _initializeFaceDetector();
    _loadExistingPersons();
    _initializeFaceRecognitionService();
    _initializeCamera();
  }

  // Initialize face detector
  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableContours: false,
      enableLandmarks: false,
      enableClassification: false,
      enableTracking: true,
    );
    _faceDetector = FaceDetector(options: options);
    print("✅ Face detector initialized");
  }

  // Load existing persons from database
  Future<void> _loadExistingPersons() async {
    try {
      print("🔍 Loading existing persons from database...");
      final persons = await _personRepository.getAllPersonsWithEmbeddings();
      existingPersons.assignAll(persons);
      print("✅ Loaded ${persons.length} persons from database");

      for (final person in persons) {
        print("   - ${person['name']} (ID: ${person['id']})");
      }
    } catch (e) {
      print("❌ Error loading existing persons: $e");
    }
  }

  // Initialize face recognition service
  Future<void> _initializeFaceRecognitionService() async {
    try {
      print("🤖 Loading face recognition model...");
      final success = await _faceRecognitionService.loadModel();

      if (success) {
        print("✅ Face recognition model loaded successfully");
      } else {
        print("⚠️ Face recognition model failed to load - will use fallback");
      }
    } catch (e) {
      print("❌ Error loading face recognition model: $e");
    }
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

    // Start face detection timer
    _detectionTimer = Timer.periodic(
      Duration(milliseconds: detectionIntervalMs),
      (_) => _processFrame(),
    );

    // Start face recognition timer
    if (isRecognitionEnabled.value) {
      _recognitionTimer = Timer.periodic(
        Duration(milliseconds: recognitionIntervalMs),
        (_) => _processRecognition(),
      );
    }

    print("🔍 Face detection and recognition started");
  }

  // Stop face detection
  void _stopDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = null;

    _recognitionTimer?.cancel();
    _recognitionTimer = null;

    isDetecting(false);
    faces.clear();
    faceNames.clear();
    faceConfidences.clear();
    isRecognized.clear();
    print("⏹️ Face detection stopped");
  }

  // Process camera frame for face detection (UNCHANGED - just detection)
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

      // Update detection stats
      _updateDetectionStats(detectedFaces.length);

      // Clean up temp file
      final tempFile = File(imageFile.path);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      print("⚠️ Frame processing error: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  // NEW: Process face recognition (separate from detection)
  Future<void> _processRecognition() async {
    if (_isProcessingRecognition || !isInitialized.value) return;
    if (_cameraService.controller == null || faces.isEmpty) return;
    if (!_faceRecognitionService.isModelLoaded || existingPersons.isEmpty)
      return;

    try {
      _isProcessingRecognition = true;
      print("🤖 Starting face recognition for ${faces.length} faces...");

      // Capture image for recognition
      final XFile imageFile = await _cameraService.controller!.takePicture();
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) return;

      // Process each detected face
      for (int i = 0; i < faces.length; i++) {
        await _recognizeSingleFace(i, faces[i], originalImage);
      }

      // Update recognition stats
      final recognizedCount = isRecognized.values
          .where((recognized) => recognized)
          .length;
      recognitionStats('${recognizedCount}/${faces.length} faces recognized');

      // Clean up temp file
      final tempFile = File(imageFile.path);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      print("❌ Face recognition error: $e");
    } finally {
      _isProcessingRecognition = false;
    }
  }

  // NEW: Recognize single face
  Future<void> _recognizeSingleFace(
    int faceIndex,
    Face face,
    img.Image originalImage,
  ) async {
    try {
      // Crop face from image
      final boundingBox = face.boundingBox;
      final left = boundingBox.left.toInt().clamp(0, originalImage.width - 1);
      final top = boundingBox.top.toInt().clamp(0, originalImage.height - 1);
      final width = (boundingBox.width.toInt()).clamp(
        1,
        originalImage.width - left,
      );
      final height = (boundingBox.height.toInt()).clamp(
        1,
        originalImage.height - top,
      );

      final croppedFace = img.copyCrop(
        originalImage,
        x: left,
        y: top,
        width: width,
        height: height,
      );
      final resizedFace = img.copyResize(croppedFace, width: 112, height: 112);
      final faceBytes = Uint8List.fromList(img.encodeJpg(resizedFace));

      // Generate embedding
      final embedding = await _faceRecognitionService.generateEmbedding(
        faceBytes,
      );
      if (embedding == null) {
        _setUnknownFace(faceIndex);
        return;
      }

      // Compare with existing persons
      double bestSimilarity = 0.0;
      String bestMatchName = '';

      for (final person in existingPersons) {
        final storedEmbedding = person['embedding'] as List<double>;

        if (storedEmbedding.isNotEmpty) {
          final similarity = _faceRecognitionService.calculateSimilarity(
            embedding,
            storedEmbedding,
          );

          if (similarity > bestSimilarity) {
            bestSimilarity = similarity;
            bestMatchName = person['name'];
          }
        }
      }

      // Convert similarity to percentage
      final confidencePercentage = _faceRecognitionService
          .similarityToPercentage(bestSimilarity);

      // Check if match is above threshold
      if (confidencePercentage >= (confidenceThreshold * 100)) {
        // Recognized face
        faceNames[faceIndex] = bestMatchName;
        faceConfidences[faceIndex] = confidencePercentage;
        isRecognized[faceIndex] = true;

        print(
          "✅ Face $faceIndex recognized: $bestMatchName (${confidencePercentage.toStringAsFixed(1)}%)",
        );
      } else {
        // Unknown face
        _setUnknownFace(faceIndex);
      }
    } catch (e) {
      print("❌ Error recognizing face $faceIndex: $e");
      _setUnknownFace(faceIndex);
    }
  }

  // NEW: Set face as unknown
  void _setUnknownFace(int faceIndex) {
    faceNames[faceIndex] = 'Face ${faceIndex + 1}';
    faceConfidences[faceIndex] = 0.0;
    isRecognized[faceIndex] = false;
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

  // Switch camera (front/back) - ENHANCED with recognition restart
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

  // Toggle recognition on/off
  void toggleRecognition() {
    isRecognitionEnabled(!isRecognitionEnabled.value);

    if (isDetecting.value) {
      // Restart detection with new recognition settings
      _stopDetection();
      _startDetection();
    }

    Get.snackbar(
      'Recognition',
      isRecognitionEnabled.value
          ? 'Face recognition enabled'
          : 'Face recognition disabled',
      duration: Duration(seconds: 1),
      snackPosition: SnackPosition.TOP,
    );
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
    _faceRecognitionService.dispose();
    _cameraService.dispose();
    super.onClose();
  }
}
