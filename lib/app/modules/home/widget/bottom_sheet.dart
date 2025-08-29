import 'package:flutter/material.dart';

import '../../../../res/colors/app_color.dart';

class ReportOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  ReportOption({required this.icon, required this.label, required this.onTap});
}

class ReportBottomSheet extends StatelessWidget {
  final bool showTwoOptions;
  final ReportOption firstOption;
  final ReportOption? secondOption;

  const ReportBottomSheet({
    super.key,
    required this.showTwoOptions,
    required this.firstOption,
    this.secondOption,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    // Calculate max height as 40% of screen height minus bottom inset (keyboard or nav bar)
    final maxHeight = (screenHeight * 0.4) - mediaQuery.viewInsets.bottom;

    return SafeArea(
      top: false,
      bottom: true, // Make sure to respect bottom inset here!
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight > 0 ? maxHeight : screenHeight * 0.4,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Container(
                width: 80,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.grey400Color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 24),

              // Options row centered
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOption(firstOption),
                    if (showTwoOptions && secondOption != null)
                      const SizedBox(width: 40),
                    if (showTwoOptions && secondOption != null)
                      _buildOption(secondOption!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(ReportOption option) {
    return GestureDetector(
      onTap: option.onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColor.white2Color,
              shape: BoxShape.circle,
            ),
            child: Icon(option.icon, size: 30, color: AppColor.greyTone),
          ),
          const SizedBox(height: 10),
          Text(
            option.label,
            style: TextStyle(
              fontSize: 16,
              color: AppColor.grey700Color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
