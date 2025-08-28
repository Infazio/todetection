// File: lib/widgets/breadcrumb_indicator.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BreadcrumbIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const BreadcrumbIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.lightPrimary,
        border: Border(
          bottom: BorderSide(color: AppTheme.lightSecondary, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(totalSteps, (index) {
                final isActive = index < currentStep;
                final isCurrent = index == currentStep - 1;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: isActive || isCurrent
                                ? AppTheme.primaryGradient
                                : null,
                            color: isActive || isCurrent
                                ? null
                                : AppTheme.lightSecondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (index < totalSteps - 1) SizedBox(width: 8),
                    ],
                  ),
                );
              }),
            ),
          ),
          SizedBox(width: 16),
          Text(
            '$currentStep of $totalSteps',
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget untuk step labels
class StepLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const StepLabel({
    super.key,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: isActive ? AppTheme.primaryGradient : null,
        color: isCompleted
            ? AppTheme.success
            : isActive
            ? null
            : AppTheme.lightSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive || isCompleted ? Colors.white : AppTheme.darkTertiary,
        ),
      ),
    );
  }
}
