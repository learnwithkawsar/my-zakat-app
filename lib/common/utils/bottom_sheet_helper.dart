import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomSheetHelper {
  /// Show a styled bottom sheet for selection
  static void showSelectionBottomSheet({
    required String title,
    required List<BottomSheetItem> items,
    String? selectedValue,
  }) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                title,
                style: Get.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ...items.map((item) {
              final isSelected = selectedValue != null && item.value == selectedValue;
              return ListTile(
                leading: item.icon != null
                    ? Icon(
                        item.icon,
                        color: isSelected
                            ? Get.theme.colorScheme.primary
                            : Get.theme.colorScheme.onSurface,
                      )
                    : null,
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Get.theme.colorScheme.primary
                        : Get.theme.colorScheme.onSurface,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Get.theme.colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  item.onTap();
                  Get.back();
                },
              );
            }),
            SizedBox(height: Get.mediaQuery.viewInsets.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class BottomSheetItem {
  final String label;
  final String? value;
  final IconData? icon;
  final VoidCallback onTap;

  BottomSheetItem({
    required this.label,
    this.value,
    this.icon,
    required this.onTap,
  });
}

