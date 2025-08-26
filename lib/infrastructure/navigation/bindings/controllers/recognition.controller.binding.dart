import 'package:get/get.dart';

import '../../../../presentation/recognition/controllers/recognition.controller.dart';

class RecognitionControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecognitionController>(
      () => RecognitionController(),
    );
  }
}
