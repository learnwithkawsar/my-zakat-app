import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/date_formatter.dart';

class DateDisplay extends StatelessWidget {
  final DateTime date;
  final DateDisplayFormat format;
  final TextStyle? style;
  final bool showRelative;

  const DateDisplay({
    super.key,
    required this.date,
    this.format = DateDisplayFormat.display,
    this.style,
    this.showRelative = false,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate;
    
    if (showRelative) {
      formattedDate = DateFormatter.formatRelative(date);
    } else {
      switch (format) {
        case DateDisplayFormat.display:
          formattedDate = DateFormatter.formatDisplay(date);
          break;
        case DateDisplayFormat.short:
          formattedDate = DateFormatter.formatShort(date);
          break;
        case DateDisplayFormat.long:
          formattedDate = DateFormatter.formatLong(date);
          break;
        case DateDisplayFormat.withTime:
          formattedDate = DateFormatter.formatWithTime(date);
          break;
        case DateDisplayFormat.iso:
          formattedDate = DateFormatter.formatISO(date);
          break;
      }
    }

    return Text(
      formattedDate,
      style: style ?? Get.theme.textTheme.bodyMedium,
    );
  }
}

enum DateDisplayFormat {
  display,
  short,
  long,
  withTime,
  iso,
}

