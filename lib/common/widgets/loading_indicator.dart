import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Get.theme.colorScheme.primary,
        ),
      ),
    );

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 16),
          Text(
            message!,
            style: Get.theme.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return indicator;
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final Widget child;
  final bool isLoading;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LoadingIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(message!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

