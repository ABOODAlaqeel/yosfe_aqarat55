import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية - لوحة ألوان عصرية وفاخرة
  static const Color primary = Color(0xFF0F2B46); // كحلي غامق فاخر
  static const Color primaryLight = Color(0xFF1A4A73); // كحلي فاتح
  static const Color secondary = Color(0xFFE8A838); // ذهبي دافئ
  static const Color secondaryLight = Color(0xFFF5CE6E); // ذهبي فاتح
  static const Color accent = Color(0xFF3B82F6); // أزرق ساطع

  // خلفيات
  static const Color background = Color(0xFFF0F4F8); // رمادي مزرق ناعم
  static const Color cardColor = Colors.white;
  static const Color surfaceDark = Color(0xFF1A1F36); // سطح داكن

  // نصوص
  static const Color textPrimary = Color(0xFF0F172A); // كحلي غامق جداً
  static const Color textSecondary = Color(0xFF64748B); // رمادي مزرق
  static const Color textLight = Color(0xFF94A3B8); // رمادي فاتح

  // حالات
  static const Color success = Color(0xFF22C55E); // أخضر نابض
  static const Color error = Color(0xFFEF4444); // أحمر واضح
  static const Color warning = Color(0xFFF59E0B); // برتقالي
  static const Color info = Color(0xFF06B6D4); // تركوازي

  // تدرجات لونية (Gradients)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F2B46), Color(0xFF1A4A73)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE8A838), Color(0xFFF5CE6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
