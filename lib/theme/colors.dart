import 'package:flutter/material.dart';

class JejuColors {
  // 기본값 (제주 밭 테마)
  static Color main    = const Color(0xFF386641);
  static Color sub     = const Color(0xFF6A994E);
  static Color point   = const Color(0xFFDCEDC8);
  static Color bg      = const Color(0xFFF2F7EC);
  static Color accent  = const Color(0xFFE8833A);
  static Color accent2 = const Color(0xFFD4691E);
  static Color card    = const Color(0xFFFFFFFF);

  static void updateTheme(int index) {
    switch (index) {
      case 0: // 제주 밭
        main    = const Color(0xFF386641);
        sub     = const Color(0xFF6A994E);
        point   = const Color(0xFFDCEDC8);
        bg      = const Color(0xFFF2F7EC);
        accent  = const Color(0xFFE8833A);
        accent2 = const Color(0xFFD4691E);
        card    = const Color(0xFFFFFFFF);
        break;
      case 1: // 제주 바다
        main    = const Color(0xFF1A5F7A);
        sub     = const Color(0xFF2E86AB);
        point   = const Color(0xFFB8E4F2);
        bg      = const Color(0xFFEFF6FA);
        accent  = const Color(0xFF1A5F7A);
        accent2 = const Color(0xFF134E63);
        card    = const Color(0xFFFFFFFF);
        break;
      case 2: // 한라 노을
        main    = const Color(0xFF8B3A3A);
        sub     = const Color(0xFFB05555);
        point   = const Color(0xFFF5CBA7);
        bg      = const Color(0xFFFAF0EC);
        accent  = const Color(0xFFD4A017);
        accent2 = const Color(0xFFB8860B);
        card    = const Color(0xFFFFFFFF);
        break;
    }
  }
}