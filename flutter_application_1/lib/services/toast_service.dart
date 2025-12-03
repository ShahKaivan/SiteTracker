import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_spacing.dart';

/// Toast notification service for showing success/error/warning/info messages
class ToastService {
  ToastService._(); // Private constructor to prevent instantiation

  /// Show success toast
  static void showSuccess(BuildContext context, String message) {
    _showToast(
      context,
      message,
      AppColors.success,
      Icons.check_circle,
    );
  }

  /// Show error toast
  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      message,
      AppColors.error,
      Icons.error,
    );
  }

  /// Show warning toast
  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message,
      AppColors.warning,
      Icons.warning,
    );
  }

  /// Show info toast
  static void showInfo(BuildContext context, String message) {
    _showToast(
      context,
      message,
      AppColors.info,
      Icons.info,
    );
  }

  /// Internal method to show toast
  static void _showToast(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: AppSpacing.iconMD,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        margin: AppSpacing.paddingMD,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
