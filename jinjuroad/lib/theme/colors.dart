// lib/theme/colors.dart

import 'package:flutter/material.dart';

// TSX의 Tailwind/CSS 색상들을 Flutter의 Color 객체로 변환합니다.
// 색상 코드는 TSX 파일의 스타일을 기반으로 추정했습니다.
// (실제 색상 코드는 디자인 시스템에 맞게 조정하세요.)

class AppColors {
  // Brand Colors
  static const Color brandPrimary = Color(0xFFFFFFFF); // bg-brand-primary (Header)
  static const Color brandSecondary = Color(0xFFFFFFFF); // bg-brand-secondary (Card, Modal)
  static const Color brandAccent = Color(0xFF6366F1);    // bg-brand-accent (Buttons, Tags) - Indigo 500
  static const Color brandAccentHover = Color(0xFF4F46E5); // bg-brand-accent-hover (Buttons) - Indigo 600

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);   // text-brand-text-primary (Dark Gray)
  static const Color textSecondary = Color(0xFF6B7280); // text-brand-text-secondary (Medium Gray)
  static const Color textOnAccent = Color(0xFFFFFFFF);  // text-white (Accent 버튼 위)

  // Grays / Borders
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB); // border-gray-300
}