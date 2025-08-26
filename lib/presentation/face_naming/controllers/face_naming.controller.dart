// File: lib/presentation/face_naming/controllers/face_naming.controller.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';

class FaceNamingController extends GetxController {
  // Data yang diterima dari screen sebelumnya
  int faceCount = 0;
  Map<int, String> initialNames = {};
  Function(Map<int, String>)? onSaveCallback;
  List<Uint8List> croppedFaceImages = []; // TAMBAH ini untuk thumbnails

  // Text controllers untuk setiap input field
  List<TextEditingController> textControllers = [];

  // Current face names
  Map<int, String> faceNames = {};

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

    print('FaceNamingController initialized:');
    print('- Face count: $faceCount');
    print('- Cropped images: ${croppedFaceImages.length}');
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
    print("=== _performSave called ===");
    print("onSaveCallback is null: ${onSaveCallback == null}");
    print("faceNames to save: $faceNames");

    // Panggil callback untuk update parent controller
    if (onSaveCallback != null) {
      print("Calling onSaveCallback with: $faceNames");
      onSaveCallback!(Map<int, String>.from(faceNames));
      print("onSaveCallback completed");
    } else {
      print("ERROR: onSaveCallback is null!");
    }

    print("Calling Get.back()");
    // Kembali ke Registration Screen
    Get.offNamed(Routes.REGISTRATION);
    print("Get.back() completed");
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
