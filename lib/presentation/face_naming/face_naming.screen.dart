// File: lib/presentation/face_naming/face_naming.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/face_naming.controller.dart';

class FaceNamingScreen extends GetView<FaceNamingController> {
  const FaceNamingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beri Nama Wajah'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: controller.showDatabaseStats,
            tooltip: 'Database Info',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Info header
            _buildInfoHeader(),

            SizedBox(height: 20),

            // List input nama dengan thumbnail
            Expanded(child: _buildFaceNamesList()),

            // Bottom buttons
            _buildBottomButtons(),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.face_retouching_natural,
            size: 40,
            color: Colors.blue[800],
          ),
          SizedBox(height: 8),
          Text(
            '${controller.faceCount} wajah terdeteksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          Text(
            'Berikan nama untuk setiap wajah di bawah ini',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFaceNamesList() {
    return ListView.builder(
      itemCount: controller.faceCount,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Thumbnail wajah
                _buildFaceThumbnail(index),

                SizedBox(width: 16),

                // Input nama
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
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: thumbnail != null
            ? Stack(
                children: [
                  Image.memory(
                    thumbnail,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  // Overlay nomor wajah
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: Colors.grey[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.face, color: Colors.grey[400], size: 30),
                    SizedBox(height: 4),
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
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
        Text(
          'Wajah ${index + 1}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),

        // HILANGKAN Obx, buat widget biasa
        _buildSuggestionChips(index),

        TextField(
          controller: controller.getTextController(index),
          decoration: InputDecoration(
            hintText: 'Masukkan nama...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400]),
            // HILANGKAN suffixIcon Obx - buat static
          ),
          onChanged: (value) {
            controller.updateFaceName(index, value.trim());
          },
        ),
      ],
    );
  }

  // TAMBAH method helper TANPA Obx:
  Widget _buildSuggestionChips(int index) {
    final currentText = controller.getTextController(index).text;
    final suggestions = controller.getNameSuggestions(currentText);

    if (suggestions.isNotEmpty && currentText.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(bottom: 8),
        child: Wrap(
          spacing: 8,
          children: suggestions
              .map(
                (suggestion) => GestureDetector(
                  onTap: () {
                    controller.getTextController(index).text = suggestion;
                    controller.updateFaceName(index, suggestion);
                  },
                  child: Chip(
                    label: Text(suggestion, style: TextStyle(fontSize: 12)),
                    backgroundColor: Colors.blue[50],
                    side: BorderSide(color: Colors.blue[200]!),
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
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Get.back();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[400]!),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, size: 18),
                  SizedBox(width: 8),
                  Text('Batal'),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: controller.saveNames,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Simpan & Lanjutkan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
