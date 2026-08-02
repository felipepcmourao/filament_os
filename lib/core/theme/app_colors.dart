import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color printing;
  final Color printingContainer;
  final Color success;
  final Color successContainer;
  final Color failed;
  final Color failedContainer;
  final Color lowStock;
  final Color lowStockContainer;

  const AppColors({
    required this.printing,
    required this.printingContainer,
    required this.success,
    required this.successContainer,
    required this.failed,
    required this.failedContainer,
    required this.lowStock,
    required this.lowStockContainer,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? printing,
    Color? printingContainer,
    Color? success,
    Color? successContainer,
    Color? failed,
    Color? failedContainer,
    Color? lowStock,
    Color? lowStockContainer,
  }) {
    return AppColors(
      printing: printing ?? this.printing,
      printingContainer: printingContainer ?? this.printingContainer,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      failed: failed ?? this.failed,
      failedContainer: failedContainer ?? this.failedContainer,
      lowStock: lowStock ?? this.lowStock,
      lowStockContainer: lowStockContainer ?? this.lowStockContainer,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is AppColors) {
      return AppColors(
        printing: Color.lerp(printing, other.printing, t)!,
        printingContainer: Color.lerp(
          printingContainer,
          other.printingContainer,
          t,
        )!,
        success: Color.lerp(success, other.success, t)!,
        successContainer: Color.lerp(
          successContainer,
          other.successContainer,
          t,
        )!,
        failed: Color.lerp(failed, other.failed, t)!,
        failedContainer: Color.lerp(failedContainer, other.failedContainer, t)!,
        lowStock: Color.lerp(lowStock, other.lowStock, t)!,
        lowStockContainer: Color.lerp(
          lowStockContainer,
          other.lowStockContainer,
          t,
        )!,
      );
    }
    return this;
  }

  static const dark = AppColors(
    printing: Color(0xFF60A5FA),
    printingContainer: Color(0xFF1E2A37),
    success: Color(0xFF4ADE80),
    successContainer: Color(0xFF1B3324),
    failed: Color(0xFFF87171),
    failedContainer: Color(0xFF372121),
    lowStock: Color(0xFFFBBF24),
    lowStockContainer: Color(0xFF372E15),
  );

  static const light = AppColors(
    printing: Color(0xFF2563EB),
    printingContainer: Color(0xFFDCEAFE),
    success: Color(0xFF16A34A),
    successContainer: Color(0xFFDCFCE7),
    failed: Color(0xFFDC2626),
    failedContainer: Color(0xFFFEE2E2),
    lowStock: Color(0xFFB45309),
    lowStockContainer: Color(0xFFFEF3C7),
  );
}
