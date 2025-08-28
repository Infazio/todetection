// File: lib/presentation/home/home.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todetection/infrastructure/navigation/routes.dart';
import '../../theme/app_theme.dart';
import 'controllers/home.controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Logo Section
                _buildLogoSection(),

                SizedBox(height: 30),

                // Main Actions
                _buildMainActions(),

                SizedBox(height: 20),

                // Registered Persons Preview
                _buildRegisteredPersonsPreview(),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          // Logo Infazio
          Container(
            height: 60,
            child: Image.asset(
              "assets/images/infazio-logo.png",
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 12),
          // Tagline
          Text(
            "AI Face Recognition",
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.darkTertiary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          // Version indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "v1.0 Beta",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActions() {
    return Column(
      children: [
        // Registration Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.mediumShadow,
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_alt_1,
                  size: 32,
                  color: AppTheme.primaryPurple,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Register New Face",
                style: AppTheme.titleMedium.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                "Add new person to recognition database",
                style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AppTheme.gradientButton(
                  text: "Start Registration",
                  icon: Icons.camera_alt,
                  onPressed: () {
                    Get.toNamed(Routes.REGISTRATION);
                  },
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Recognition Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.mediumShadow,
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.face_retouching_natural,
                  size: 32,
                  color: AppTheme.secondaryBlue,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Live Recognition",
                style: AppTheme.titleMedium.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                "Real-time face detection and recognition",
                style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AppTheme.gradientButton(
                  text: "Start Recognition",
                  icon: Icons.video_camera_front,
                  isSecondary: true,
                  onPressed: () {
                    Get.toNamed(Routes.RECOGNITION);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisteredPersonsPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightSecondary, width: 1.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_outline,
                  size: 24,
                  color: AppTheme.accentCyan,
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Registered Persons",
                    style: AppTheme.bodyLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Manage your database",
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.darkTertiary,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Soon",
                  style: TextStyle(
                    color: AppTheme.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Stats Preview
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Total",
                  "0", // This will be dynamic later
                  Icons.person,
                  AppTheme.primaryPurple,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  "Active",
                  "0", // This will be dynamic later
                  Icons.face,
                  AppTheme.success,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  "Recent",
                  "0", // This will be dynamic later
                  Icons.access_time,
                  AppTheme.accentCyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: AppTheme.darkTertiary),
          ),
        ],
      ),
    );
  }
}
