import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CurrencyFormatter {
  static String formatCurrency(double value, {Locale? locale}) {
    final currentLocale = locale ?? Locale('pt', 'BR');

    String currencySymbol;

    switch (currentLocale.countryCode) {
      case 'BR':
        currencySymbol = 'R\$';
        break;
      case 'US':
        currencySymbol = '\$';
        break;
      default:
        currencySymbol = '\$';
    }

    final formatter = NumberFormat.currency(
      locale: currentLocale.toString(),
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    return formatter.format(value);
  }

  static String formatCurrencyForCurrentLocale(
    double value, {
    required String countryCode,
  }) {
    return formatCurrency(value);
  }

  static String formatCurrencyCompact(
    double value, {
    required String countryCode,
  }) {
    String currencySymbol;
    switch (countryCode) {
      case 'BR':
        currencySymbol = 'R\$';
        break;
      case 'US':
        currencySymbol = '\$';
        break;
      default:
        currencySymbol = '\$';
    }

    final formatter = NumberFormat.compactCurrency(
      locale: countryCode,
      symbol: currencySymbol,
    );

    return formatter.format(value);
  }
}
