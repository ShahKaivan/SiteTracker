import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_styles.dart';

/// Loading indicator widget for async operations
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool overlay;

  const LoadingIndicator({
    super.key,
    this.message,
    this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppStyles.bodyText,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    if (overlay) {
      return Container(
        color: Colors.black.withOpacity(0.3),
        child: content,
      );
    }

    return content;
  }
}
