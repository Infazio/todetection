import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/recognition.controller.dart';

class RecognitionScreen extends GetView<RecognitionController> {
  const RecognitionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RecognitionScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'RecognitionScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
