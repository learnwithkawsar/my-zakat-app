import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ButtonType { primary, secondary, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Widget buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getForegroundColor(),
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    final ButtonStyle buttonStyle = _getButtonStyle();

    return SizedBox(
      width: width,
      height: height,
      child: type == ButtonType.outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: buttonChild,
            )
          : type == ButtonType.text
              ? TextButton(
                  onPressed: isLoading ? null : onPressed,
                  style: buttonStyle,
                  child: buttonChild,
                )
              : ElevatedButton(
                  onPressed: isLoading ? null : onPressed,
                  style: buttonStyle,
                  child: buttonChild,
                ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Get.theme.colorScheme.primary,
          foregroundColor: foregroundColor ?? Get.theme.colorScheme.onPrimary,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? Get.theme.colorScheme.secondaryContainer,
          foregroundColor:
              foregroundColor ?? Get.theme.colorScheme.onSecondaryContainer,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ButtonType.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? Get.theme.colorScheme.primary,
          side: BorderSide(
            color: backgroundColor ?? Get.theme.colorScheme.primary,
          ),
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: foregroundColor ?? Get.theme.colorScheme.primary,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
    }
  }

  Color _getForegroundColor() {
    return foregroundColor ??
        (type == ButtonType.primary
            ? Get.theme.colorScheme.onPrimary
            : Get.theme.colorScheme.primary);
  }
}

