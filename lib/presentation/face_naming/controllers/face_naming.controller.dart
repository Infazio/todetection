// File: lib/presentation/face_naming/controllers/face_naming.controller.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/person_repositories.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../services/face_recognition_service.dart';
import '../../../utils/snackbar_helper.dart';
import '../../../widgets/database_info_dialog.dart';

class FaceNamingController extends GetxController {
  // Data yang diterima dari screen sebelumnya
  int faceCount = 0;
  Map<int, String> initialNames = {};
  Function(Map<int, String>)? onSaveCallback;
  List<Uint8List> croppedFaceImages = []; // TAMBAH ini untuk thumbnails
  final FaceRecognitionService _faceRecognitionService =
      FaceRecognitionService();
  var faceMatchResults = <Map<String, dynamic>>[].obs;
  var isMatchingFaces = false.obs;

  // Text controllers untuk setiap input field
  List<TextEditingController> textControllers = [];

  // Current face names
  Map<int, String> faceNames = {};

  //untuk callback
  Function(Map<int, String>)? onCancelCallback;

  //variable ini di class FaceNamingController (setelah variable yang sudah ada)
  final PersonRepository personRepository = PersonRepository();
  var isLoadingFromDatabase = false.obs;
  var existingPersons = <Map<String, dynamic>>[].obs;
  var isSavingToDatabase = false.obs;
  var isGeneratingEmbeddings = false.obs;
  var realEmbeddings = <List<double>>[].obs;
  var nameWarnings = <int, String>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // Ambil arguments dari Get.arguments
    final args = Get.arguments ?? {};
    faceCount = args['faceCount'] ?? 0;
    initialNames = args['initialNames'] ?? <int, String>{};
    onSaveCallback = args['onSaveCallback'];
    croppedFaceImages = args['croppedFaceImages'] ?? []; // TAMBAH ini

    // Initialize text controllers
    _initializeTextControllers();

    // Set initial names
    faceNames = Map<int, String>.from(initialNames);

    // TAMBAH: Load existing persons from database
    loadExistingPersons().then((_) {
      // TAMBAH: Perform face matching setelah load database
      if (croppedFaceImages.isNotEmpty &&
          _faceRecognitionService.isModelLoaded) {
        Future.delayed(Duration(milliseconds: 500), () {
          performFaceMatching();
        });
      }
    });

    print('FaceNamingController initialized:');
    print('- Face count: $faceCount');
    print('- Cropped images: ${croppedFaceImages.length}');

    // Load data dan perform matching
    _initializeFaceMatching();

    //untuk callback
    onCancelCallback = args['onCancelCallback'];
  }

  void _initializeTextControllers() {
    textControllers.clear();

    for (int i = 0; i < faceCount; i++) {
      final controller = TextEditingController();
      controller.text = initialNames[i] ?? '';
      textControllers.add(controller);
    }
  }

  TextEditingController getTextController(int index) {
    if (index < textControllers.length) {
      return textControllers[index];
    }
    return TextEditingController();
  }

  // TAMBAH method untuk get thumbnail
  Uint8List? getThumbnail(int index) {
    if (index < croppedFaceImages.length) {
      return croppedFaceImages[index];
    }
    return null;
  }

  void updateFaceName(int index, String name) {
    if (name.isNotEmpty) {
      faceNames[index] = name;

      // Warning logic - tapi kurangi noise
      if (isNameExists(name)) {
        // GANTI dari Get.snackbar jadi warning yang lebih soft:
        SnackbarHelper.showWarning('This name already exists in database');
      }
    } else {
      faceNames.remove(index);
    }
  }

  void saveNames() {
    print("=== saveNames called ===");

    // Update final names dari text controllers
    for (int i = 0; i < faceCount; i++) {
      final name = textControllers[i].text.trim();
      print("Face $i name: '$name'");

      if (name.isNotEmpty) {
        faceNames[i] = name;
      } else {
        faceNames.remove(i);
      }
    }

    print("Final faceNames: $faceNames");

    // Validasi - cek apakah ada nama yang kosong
    List<int> emptyIndices = [];

    for (int i = 0; i < faceCount; i++) {
      final name = textControllers[i].text.trim();
      if (name.isEmpty) {
        emptyIndices.add(i + 1);
      }
    }

    print("Empty indices: $emptyIndices");

    // Jika ada nama kosong, tanya user
    if (emptyIndices.isNotEmpty) {
      print("Showing empty names dialog");
      _showEmptyNamesDialog(emptyIndices);
    } else {
      print("Calling _performSave directly");
      _performSave();
    }
  }

  void _performSave() {
    if (onSaveCallback != null) {
      onSaveCallback!(Map<int, String>.from(faceNames));
    }

    // HAPUS snackbar di sini karena sudah ada di registration controller
    Get.offNamed(Routes.REGISTRATION);
  }

  void _showEmptyNamesDialog(List<int> emptyIndices) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Nama Kosong'),
          ],
        ),
        content: Text(
          'Wajah ${emptyIndices.join(', ')} belum diberi nama.\n\n'
          'Apakah Anda ingin melanjutkan tanpa nama untuk wajah tersebut?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performSave();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  Future<void> loadExistingPersons() async {
    try {
      isLoadingFromDatabase(true);
      print("=== DEBUG: Loading existing persons ===");

      final persons = await personRepository.getAllPersonsWithEmbeddings();
      existingPersons.assignAll(persons);

      print("Loaded ${persons.length} persons from database");
      for (final person in persons) {
        print("- ${person['name']} (ID: ${person['id']})");
        print("  Embedding length: ${person['embedding'].length}");
      }
    } catch (e) {
      print("ERROR loading existing persons: $e");
    } finally {
      isLoadingFromDatabase(false);
    }
  }

  // TAMBAHKAN method untuk check if name already exists
  bool isNameExists(String name) {
    return existingPersons.any(
      (person) => person['name'].toString().toLowerCase() == name.toLowerCase(),
    );
  }

  // TAMBAHKAN method untuk get suggestions
  List<String> getNameSuggestions(String partial) {
    if (partial.isEmpty) return [];

    return existingPersons
        .map<String>((person) => person['name'].toString())
        .where((name) => name.toLowerCase().contains(partial.toLowerCase()))
        .take(3)
        .toList();
  }

  //show  database statistics
  void showDatabaseStats() {
    showDialog(
      context: Get.context!,
      builder: (context) => DatabaseInfoDialog(
        existingPersons: existingPersons,
        faceMatchResults: faceMatchResults,
      ),
    );
  }

  // TAMBAHKAN method untuk face matching
  Future<void> performFaceMatching() async {
    print("=== DEBUG: performFaceMatching called ===");
    print("croppedFaceImages.length: ${croppedFaceImages.length}");
    print("existingPersons.length: ${existingPersons.length}");
    print("Model loaded: ${_faceRecognitionService.isModelLoaded}");
    if (croppedFaceImages.isEmpty) {
      print("No cropped faces to match");
      return;
    }

    try {
      isMatchingFaces(true);
      faceMatchResults.clear();

      print("Starting face matching for ${croppedFaceImages.length} faces...");

      for (int i = 0; i < croppedFaceImages.length; i++) {
        print("Matching face ${i + 1}/${croppedFaceImages.length}...");

        // Generate embedding untuk face yang dideteksi
        final currentEmbedding = await _faceRecognitionService
            .generateEmbedding(croppedFaceImages[i]);

        if (currentEmbedding == null) {
          print("Failed to generate embedding for face ${i + 1}");
          faceMatchResults.add({
            'faceIndex': i,
            'matchFound': false,
            'suggestedName': '',
            'confidence': 0.0,
          });
          continue;
        }

        // Compare dengan semua person di database
        double bestSimilarity = 0.0;
        String bestMatchName = '';
        int bestMatchId = -1;

        for (final person in existingPersons) {
          final storedEmbedding = person['embedding'] as List<double>;

          if (storedEmbedding.isNotEmpty) {
            final similarity = _faceRecognitionService.calculateSimilarity(
              currentEmbedding,
              storedEmbedding,
            );

            if (similarity > bestSimilarity) {
              bestSimilarity = similarity;
              bestMatchName = person['name'];
              bestMatchId = person['id'];
            }
          }
        }

        // Convert similarity to percentage
        final confidencePercentage = _faceRecognitionService
            .similarityToPercentage(bestSimilarity);
        final threshold = 70.0; // 70% confidence threshold

        final matchResult = {
          'faceIndex': i,
          'matchFound': confidencePercentage >= threshold,
          'suggestedName': bestMatchName,
          'confidence': confidencePercentage,
          'similarity': bestSimilarity,
          'matchId': bestMatchId,
        };

        faceMatchResults.add(matchResult);

        print("Face ${i + 1} matching result:");
        print("  Best match: $bestMatchName");
        print("  Confidence: ${confidencePercentage.toStringAsFixed(1)}%");
        print("  Match found: ${confidencePercentage >= threshold}");

        // Auto-fill jika match ditemukan
        if (confidencePercentage >= threshold && bestMatchName.isNotEmpty) {
          textControllers[i].text = bestMatchName;
          faceNames[i] = bestMatchName;
          print("  Auto-filled name: $bestMatchName");
        }
      }

      print("Face matching completed!");
      _showMatchingResults();
    } catch (e) {
      print("Error during face matching: $e");
    } finally {
      isMatchingFaces(false);
    }
  }

  // TAMBAHKAN method untuk show matching results
  void _showMatchingResults() {
    final matchedFaces = faceMatchResults
        .where((result) => result['matchFound'] == true)
        .length;
    final totalFaces = faceMatchResults.length;

    // Hanya tampilkan jika ada yang match - kurangi noise
    if (matchedFaces > 0) {
      SnackbarHelper.showSuccess(
        '$matchedFaces of $totalFaces faces recognized automatically',
        title: 'Face Recognition',
      );
    }
    // HAPUS snackbar untuk "no faces recognized" - terlalu noisy
  }

  //initial faxe matching
  Future<void> _initializeFaceMatching() async {
    try {
      print("=== _initializeFaceMatching started ===");

      // 1. Load existing persons first
      await loadExistingPersons();

      // 2. Check if model is loaded
      if (!_faceRecognitionService.isModelLoaded) {
        print("TFLite model not loaded, trying to load...");
        await _faceRecognitionService.loadModel();
      }

      print("Ready for face matching:");
      print("- Model loaded: ${_faceRecognitionService.isModelLoaded}");
      print("- Existing persons: ${existingPersons.length}");
      print("- Cropped images: ${croppedFaceImages.length}");

      // 3. Perform face matching
      if (croppedFaceImages.isNotEmpty && existingPersons.isNotEmpty) {
        print("Starting face matching...");
        await performFaceMatching();
      } else {
        print("Skip face matching - no faces or no existing persons");
      }
    } catch (e) {
      print("Error in face matching initialization: $e");
    }
  }

  //untuk callback
  void handleBackButton() {
    // Kirim current faceNames (termasuk yang hasil matching) ke parent
    if (onCancelCallback != null) {
      onCancelCallback!(Map<int, String>.from(faceNames));
    }
    Get.back();
  }

  @override
  void onClose() {
    // Dispose text controllers
    for (final controller in textControllers) {
      controller.dispose();
    }
    textControllers.clear();
    super.onClose();
  }
}
