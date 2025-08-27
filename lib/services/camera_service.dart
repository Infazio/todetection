import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isInitialized = false;

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized =>
      _isInitialized && _controller?.value.isInitialized == true;
  List<CameraDescription> get cameras => _cameras;
  int get currentCameraIndex => _currentCameraIndex;
  CameraDescription? get currentCamera =>
      _cameras.isNotEmpty ? _cameras[_currentCameraIndex] : null;

  // Initialize camera service
  Future<bool> initialize() async {
    try {
      print("🎥 Initializing camera service...");

      // Request camera permission
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        print("❌ Camera permission denied");
        return false;
      }

      // Get available cameras
      _cameras = await availableCameras();
      print("📷 Found ${_cameras.length} cameras");

      if (_cameras.isEmpty) {
        print("❌ No cameras found");
        return false;
      }

      // Find back camera first (default)
      _currentCameraIndex = _cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      // If no back camera, use first available
      if (_currentCameraIndex == -1) {
        _currentCameraIndex = 0;
      }

      // Initialize camera controller
      await _initializeController();

      _isInitialized = true;
      print("✅ Camera service initialized successfully");
      return true;
    } catch (e) {
      print("❌ Error initializing camera: $e");
      return false;
    }
  }

  // Initialize camera controller
  Future<void> _initializeController() async {
    if (_cameras.isEmpty) return;

    try {
      await _controller?.dispose();

      _controller = CameraController(
        _cameras[_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // Good for ML processing
      );

      await _controller!.initialize();

      final size = _controller!.value.previewSize;
      final aspectRatio = _controller!.value.aspectRatio;
      print("📷 Camera initialized:");
      print("   Size: ${size?.width}x${size?.height}");
      print("   Aspect Ratio: ${aspectRatio.toStringAsFixed(2)}");
      print(
        "   Expected ratios: 4:3=${(4 / 3).toStringAsFixed(2)}, 16:9=${(16 / 9).toStringAsFixed(2)}",
      );

      print("✅ Camera controller initialized: ${currentCamera?.name}");
    } catch (e) {
      print("❌ Error initializing camera controller: $e");
      rethrow;
    }
  }

  //Set specific resolution
  Future<bool> setResolution(ResolutionPreset preset) async {
    try {
      print("🔧 Setting resolution to: $preset");

      // Store current preset
      final currentPreset = preset;

      // Reinitialize with new preset
      await _controller?.dispose();

      _controller = CameraController(
        _cameras[_currentCameraIndex],
        currentPreset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      final size = _controller!.value.previewSize;
      print("✅ New resolution: ${size?.width}x${size?.height}");
      return true;
    } catch (e) {
      print("❌ Error setting resolution: $e");
      return false;
    }
  }

  // Switch between front and back camera
  Future<bool> switchCamera() async {
    print("========== DEBUG_CAMERA_SWITCH START ==========");
    print("DEBUG_CAMERA_SWITCH: Method called!");

    if (_cameras.length < 2) {
      print("DEBUG_CAMERA_SWITCH: Only ${_cameras.length} camera(s)");
      return false;
    }

    try {
      print("DEBUG_CAMERA_SWITCH: Current index: $_currentCameraIndex");
      print("DEBUG_CAMERA_SWITCH: Current camera: ${currentCamera?.name}");

      // Simple switch logic
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

      print("DEBUG_CAMERA_SWITCH: New index: $_currentCameraIndex");
      print("DEBUG_CAMERA_SWITCH: New camera: ${currentCamera?.name}");

      await _initializeController();
      print("DEBUG_CAMERA_SWITCH: SUCCESS!");
      return true;
    } catch (e) {
      print("DEBUG_CAMERA_SWITCH: ERROR - $e");
      return false;
    }
  }

  // Request camera permission
  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      print("❌ Error requesting camera permission: $e");
      return false;
    }
  }

  // Get camera info text
  String getCameraInfo() {
    if (!isInitialized) return "Camera not initialized";

    final camera = currentCamera;
    if (camera == null) return "No camera";

    final direction = camera.lensDirection == CameraLensDirection.front
        ? "Front"
        : "Back";
    return "$direction Camera";
  }

  // Check if front camera available
  bool get hasFrontCamera => _cameras.any(
    (camera) => camera.lensDirection == CameraLensDirection.front,
  );

  // Check if back camera available
  bool get hasBackCamera => _cameras.any(
    (camera) => camera.lensDirection == CameraLensDirection.back,
  );

  // Dispose camera service
  Future<void> dispose() async {
    try {
      await _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      print("🗑️ Camera service disposed");
    } catch (e) {
      print("❌ Error disposing camera service: $e");
    }
  }
}
