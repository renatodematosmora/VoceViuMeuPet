import 'package:flutter/material.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';

// ── BuildContext Extensions ──────────────────────────────────
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}

// ── String Extensions ────────────────────────────────────────
extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  bool get isValidEmail =>
      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  bool get isValidPassword => length >= 8;
}

// ── Nullable String Extensions ───────────────────────────────
extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  String get orEmpty => this ?? '';
}

// ── DateTime Extensions ──────────────────────────────────────
extension DateTimeExtensions on DateTime {
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return 'há ${diff.inDays} dias';
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays < 30) return 'há ${diff.inDays} dias';
    if (diff.inDays < 365) return 'há ${(diff.inDays / 30).floor()} meses';
    return 'há ${(diff.inDays / 365).floor()} anos';
  }

  int get daysAgo => DateTime.now().difference(this).inDays;
}

// ── Int Extensions ───────────────────────────────────────────
extension IntExtensions on int {
  String get daysLostLabel {
    if (this == 0) return 'Desapareceu hoje';
    if (this == 1) return 'Desapareceu há 1 dia';
    return 'Desaparecido há $this dias';
  }
}

// ── List Extensions ──────────────────────────────────────────
extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
