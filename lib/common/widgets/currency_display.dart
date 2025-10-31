import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/currency_formatter.dart';

class CurrencyDisplay extends StatelessWidget {
  final double amount;
  final String currency;
  final TextStyle? style;
  final bool showSymbol;
  final int decimalPlaces;
  final bool useCompact;

  const CurrencyDisplay({
    super.key,
    required this.amount,
    required this.currency,
    this.style,
    this.showSymbol = true,
    this.decimalPlaces = 2,
    this.useCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = useCompact
        ? CurrencyFormatter.formatCompact(
            amount: amount,
            currency: currency,
          )
        : CurrencyFormatter.format(
            amount: amount,
            currency: currency,
            decimalPlaces: decimalPlaces,
          );

    return Text(
      formattedAmount,
      style: style ?? Get.theme.textTheme.bodyLarge,
    );
  }
}

