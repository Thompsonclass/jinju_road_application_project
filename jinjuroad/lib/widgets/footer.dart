import 'package:flutter/material.dart';
import '../theme/colors.dart';

class Footer extends StatelessWidget {
  // getUIText('appName') 대신 앱 이름을 직접 받습니다.
  final String appName;

  const Footer({
    Key? key,
    required this.appName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TSX: <footer className="bg-gray-50 mt-12 py-8 border-t border-gray-200">
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 48.0), // mt-12
      padding: const EdgeInsets.symmetric(vertical: 32.0), // py-8
      decoration: const BoxDecoration(
        color: AppColors.gray50, // bg-gray-50
        border: Border(
          top: BorderSide(
            color: AppColors.gray200, // border-t border-gray-200
            width: 1.0,
          ),
        ),
      ),
      // TSX: <div className="... text-center text-brand-text-secondary">
      child: Center(
        child: Text(
          "© 2025 $appName",
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}