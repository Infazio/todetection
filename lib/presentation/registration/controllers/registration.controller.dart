import 'dart:io';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationController extends GetxController {
  final imagePicker = ImagePicker();
  late final FaceDetector faceDetector;

  // Reactive variables
  var imageFile = Rxn<File>();
  var faces = <Face>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var captureStatus = 'Pilih sumber gambar'.obs;
  var faceDetails = <String>[].obs;
  var decodedImage = Rxn<ui.Image>();

  @override
  void onInit() {
    super.onInit();
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
    );
    faceDetector = FaceDetector(options: options);
  }

  Future<void> imgFromCamera() async {
    try {
      isLoading(true);
      errorMessage('');
      captureStatus('Mengambil gambar dari kamera...');

      XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        captureStatus('Memproses gambar...');
        imageFile.value = File(pickedFile.path);
        await doFaceDetection();
      } else {
        captureStatus('Pembatalan pengambilan gambar');
      }
    } catch (e) {
      errorMessage('Error kamera: ${e.toString()}');
      captureStatus('Error: Gagal mengambil gambar');
    } finally {
      isLoading(false);
    }
  }

  Future<void> imgFromGallery() async {
    try {
      isLoading(true);
      errorMessage('');
      captureStatus('Memilih gambar dari galeri...');

      XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        captureStatus('Memproses gambar...');
        imageFile.value = File(pickedFile.path);
        await doFaceDetection();
      } else {
        captureStatus('Pembatalan pemilihan gambar');
      }
    } catch (e) {
      errorMessage('Error galeri: ${e.toString()}');
      captureStatus('Error: Gagal memilih gambar');
    } finally {
      isLoading(false);
    }
  }

  Future<void> doFaceDetection() async {
    try {
      isLoading(true);
      captureStatus('Mendeteksi wajah...');
      faceDetails.clear();

      final correctedImage = await removeRotation(imageFile.value!);
      imageFile.value = correctedImage;

      // TAMBAHKAN BARIS INI - decode image untuk painter
      await drawRectangleAroundFaces();

      final inputImage = InputImage.fromFile(correctedImage);
      final detectedFaces = await faceDetector.processImage(inputImage);

      faces.assignAll(detectedFaces);

      if (detectedFaces.isEmpty) {
        captureStatus('Tidak ada wajah terdeteksi');
      } else {
        captureStatus('${detectedFaces.length} wajah terdeteksi');

        for (final face in detectedFaces) {
          await processSingleFace(face);
          analyzeLandmarks(face);
          inspectFaceDetails(face);
        }
      }

      update();
    } catch (e) {
      errorMessage('Error deteksi wajah: ${e.toString()}');
      captureStatus('Gagal mendeteksi wajah');
    } finally {
      isLoading(false);
    }
  }

  Future<void> processSingleFace(Face face) async {
    try {
      final faceRect = face.boundingBox;

      // Validasi boundaries
      num left = faceRect.left < 0 ? 0 : faceRect.left;
      num top = faceRect.top < 0 ? 0 : faceRect.top;
      num right =
          faceRect.right > (imageFile.value != null ? _getImageWidth() : 1000)
          ? _getImageWidth() - 1
          : faceRect.right;
      num bottom =
          faceRect.bottom > (imageFile.value != null ? _getImageHeight() : 1000)
          ? _getImageHeight() - 1
          : faceRect.bottom;

      num width = right - left;
      num height = bottom - top;

      // Tambahkan detail wajah ke list
      faceDetails.add(
        'Wajah terdeteksi: ${width.toInt()}x${height.toInt()} px',
      );
      faceDetails.add('Posisi: (${left.toInt()}, ${top.toInt()})');
    } catch (e) {
      print('Error processing face: $e');
      faceDetails.add('Error processing wajah');
    }
  }

  Future<void> drawRectangleAroundFaces() async {
    print("=== Starting drawRectangleAroundFaces ===");

    if (imageFile.value != null) {
      try {
        print("Reading image bytes...");
        final bytes = await imageFile.value!.readAsBytes();
        print("Image bytes length: ${bytes.length}");

        print("Decoding image...");
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();

        decodedImage.value = frame.image;
        print(
          "SUCCESS - Image dimensions: ${frame.image.width} x ${frame.image.height}",
        );
        print("decodedImage.value is null: ${decodedImage.value == null}");
      } catch (e) {
        print('ERROR decoding image: $e');
        decodedImage.value = null;
      }
    } else {
      print("ERROR - imageFile.value is null");
    }
    print("=== End drawRectangleAroundFaces ===");
  }

  void analyzeLandmarks(Face face) {
    final landmarks = face.landmarks;

    faceDetails.add('--- Landmarks Terdeteksi ---');

    landmarks.forEach((landmarkType, landmark) {
      if (landmark != null) {
        final landmarkInfo =
            '${_getLandmarkName(landmarkType)}: '
            '(${landmark.position.x.toInt()}, ${landmark.position.y.toInt()})';
        faceDetails.add(landmarkInfo);
      }
    });
  }

  String _analyzeFacialExpression(Face face) {
    final expressions = <String>[];

    // Analisis senyum
    if (face.smilingProbability != null) {
      final smileProb = face.smilingProbability!;
      if (smileProb > 0.7) {
        expressions.add('😊 Senyum lebar');
      } else if (smileProb > 0.4) {
        expressions.add('🙂 Sedikit tersenyum');
      } else if (smileProb > 0.2) {
        expressions.add('😐 Ekspresi netral');
      } else {
        expressions.add('😶 Ekspresi serius');
      }
    }

    // Analisis mata
    if (face.leftEyeOpenProbability != null &&
        face.rightEyeOpenProbability != null) {
      final leftEyeOpen = face.leftEyeOpenProbability!;
      final rightEyeOpen = face.rightEyeOpenProbability!;

      if (leftEyeOpen < 0.3 && rightEyeOpen < 0.3) {
        expressions.add('😑 Mata tertutup');
      } else if (leftEyeOpen < 0.3 || rightEyeOpen < 0.3) {
        expressions.add('😉 Satu mata tertutup');
      } else {
        expressions.add('👀 Mata terbuka');
      }
    }

    // Analisis rotasi kepala
    if (face.headEulerAngleY != null) {
      final headY = face.headEulerAngleY!;
      if (headY > 15) {
        expressions.add('↪️ Menengok kanan');
      } else if (headY < -15) {
        expressions.add('↩️ Menengok kiri');
      }
    }

    if (face.headEulerAngleZ != null) {
      final headZ = face.headEulerAngleZ!;
      if (headZ.abs() > 10) {
        expressions.add('🤨 Kepala miring');
      }
    }

    return expressions.isNotEmpty ? expressions.join(' • ') : 'Ekspresi netral';
  }

  String _getLandmarkName(FaceLandmarkType type) {
    switch (type) {
      case FaceLandmarkType.leftEye:
        return 'Mata Kiri';
      case FaceLandmarkType.rightEye:
        return 'Mata Kanan';
      case FaceLandmarkType.noseBase:
        return 'Pangkal Hidung';
      case FaceLandmarkType.leftCheek:
        return 'Pipi Kiri';
      case FaceLandmarkType.rightCheek:
        return 'Pipi Kanan';
      case FaceLandmarkType.leftMouth:
        return 'Mulut Kiri';
      case FaceLandmarkType.rightMouth:
        return 'Mulut Kanan';
      case FaceLandmarkType.leftEar:
        return 'Telinga Kiri';
      case FaceLandmarkType.rightEar:
        return 'Telinga Kanan';

      default:
        return type.name;
    }
  }

  void inspectFaceDetails(Face face) {
    final expression = _analyzeFacialExpression(face);
    faceDetails.add('🎭 Ekspresi: $expression');

    // Tetap pertahankan detail teknis yang sudah ada
    if (face.smilingProbability != null) {
      final smilePercent = (face.smilingProbability! * 100).toInt();
      faceDetails.add('😊 Senyum: $smilePercent%');
    }
    faceDetails.add('--- Analisis Wajah ---');

    // Smile probability
    if (face.smilingProbability != null) {
      final smilePercent = (face.smilingProbability! * 100).toInt();
      faceDetails.add('Probabilitas Senyum: $smilePercent%');
    }

    // Eye open probabilities
    if (face.leftEyeOpenProbability != null) {
      final leftEyeOpen = (face.leftEyeOpenProbability! * 100).toInt();
      faceDetails.add('Mata Kiri Terbuka: $leftEyeOpen%');
    }

    if (face.rightEyeOpenProbability != null) {
      final rightEyeOpen = (face.rightEyeOpenProbability! * 100).toInt();
      faceDetails.add('Mata Kanan Terbuka: $rightEyeOpen%');
    }

    // Head rotation
    if (face.headEulerAngleY != null) {
      faceDetails.add(
        'Rotasi Kepala Y: ${face.headEulerAngleY!.toStringAsFixed(1)}°',
      );
    }
    if (face.headEulerAngleZ != null) {
      faceDetails.add(
        'Rotasi Kepala Z: ${face.headEulerAngleZ!.toStringAsFixed(1)}°',
      );
    }

    // Tracking ID (jika enableTracking true)
    if (face.trackingId != null) {
      faceDetails.add('Tracking ID: ${face.trackingId}');
    }
  }

  Future<File> removeRotation(File inputImage) async {
    try {
      final bytes = await inputImage.readAsBytes();
      final capturedImage = img.decodeImage(bytes);

      if (capturedImage == null) {
        throw Exception('Gagal decode image');
      }

      final orientedImage = img.bakeOrientation(capturedImage);

      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/corrected_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await tempFile.writeAsBytes(img.encodeJpg(orientedImage));
      return tempFile;
    } catch (e) {
      print('Rotation removal error: $e');
      return inputImage; // Return original jika error
    }
  }

  int _getImageWidth() {
    return imageFile.value != null
        ? img.decodeImage(imageFile.value!.readAsBytesSync())?.width ?? 1000
        : 1000;
  }

  int _getImageHeight() {
    return imageFile.value != null
        ? img.decodeImage(imageFile.value!.readAsBytesSync())?.height ?? 1000
        : 1000;
  }

  void resetDetection() {
    imageFile.value = null;
    faces.clear();
    faceDetails.clear();
    errorMessage('');
    captureStatus('Pilih sumber gambar');
    decodedImage.value = null; // TAMBAHKAN BARIS INI
  }

  @override
  void onClose() {
    faceDetector.close();
    super.onClose();
  }
}
