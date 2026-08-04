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
  final Color healthyStock;
  final Color healthyStockContainer;
  final Color exhaustedStock;
  final Color exhaustedStockContainer;

  const AppColors({
    required this.printing,
    required this.printingContainer,
    required this.success,
    required this.successContainer,
    required this.failed,
    required this.failedContainer,
    required this.lowStock,
    required this.lowStockContainer,
    required this.healthyStock,
    required this.healthyStockContainer,
    required this.exhaustedStock,
    required this.exhaustedStockContainer,
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
    Color? healthyStock,
    Color? healthyStockContainer,
    Color? exhaustedStock,
    Color? exhaustedStockContainer,
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
      healthyStock: healthyStock ?? this.healthyStock,
      healthyStockContainer:
          healthyStockContainer ?? this.healthyStockContainer,
      exhaustedStock: exhaustedStock ?? this.exhaustedStock,
      exhaustedStockContainer:
          exhaustedStockContainer ?? this.exhaustedStockContainer,
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
        healthyStock: Color.lerp(healthyStock, other.healthyStock, t)!,
        healthyStockContainer: Color.lerp(
          healthyStockContainer,
          other.healthyStockContainer,
          t,
        )!,
        exhaustedStock: Color.lerp(exhaustedStock, other.exhaustedStock, t)!,
        exhaustedStockContainer: Color.lerp(
          exhaustedStockContainer,
          other.exhaustedStockContainer,
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
    healthyStock: Color(0xFF34D399),
    healthyStockContainer: Color(0xFF173128),
    exhaustedStock: Color(0xFFFB7185),
    exhaustedStockContainer: Color(0xFF372124),
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
    healthyStock: Color(0xFF0F766E),
    healthyStockContainer: Color(0xFFCCFBF1),
    exhaustedStock: Color(0xFFBE123C),
    exhaustedStockContainer: Color(0xFFFFE4E6),
  );
}
