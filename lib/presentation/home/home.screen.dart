import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:todetection/infrastructure/navigation/routes.dart';

import 'controllers/home.controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(top: 80),
            child: Text(
              "INFAZIO AI",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.blueAccent,
                fontSize: 24,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: Image.asset(
              "assets/images/icon-face.png",
              width: screenWidth - 40,
              height: screenWidth - 40,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(Routes.REGISTRATION);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth - 30, 50),
                  ),
                  child: const Text("Register"),
                ),
                Container(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(Routes.RECOGNITION);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth - 30, 50),
                  ),
                  child: const Text("Recognize"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
