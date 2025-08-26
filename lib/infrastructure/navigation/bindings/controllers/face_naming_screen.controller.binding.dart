import 'package:get/get.dart';

import '../../../../presentation/face_naming/controllers/face_naming.controller.dart';

class FaceNamingControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FaceNamingController>(() => FaceNamingController());
  }
}
