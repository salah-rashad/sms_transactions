import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color income;
  final Color expense;
  final Color balance;
  final Color savings;
  final Color contribution;
  final Color warning;
  final Color success;
  final Color successContainer;

  const AppColors({
    required this.income,
    required this.expense,
    required this.balance,
    required this.savings,
    required this.contribution,
    required this.warning,
    required this.success,
    required this.successContainer,
  });

  static const light = AppColors(
    income: Color(0xFF2E7D32),
    expense: Color(0xFFC62828),
    balance: Color(0xFF1565C0),
    savings: Color(0xFF00695C),
    contribution: Color(0xFFE65100),
    warning: Color(0xFFEF6C00),
    success: Color(0xFF2E7D32),
    successContainer: Color(0xFFC8E6C9),
  );

  static const dark = AppColors(
    income: Color(0xFF66BB6A),
    expense: Color(0xFFEF5350),
    balance: Color(0xFF42A5F5),
    savings: Color(0xFF4DB6AC),
    contribution: Color(0xFFFFA726),
    warning: Color(0xFFFFA726),
    success: Color(0xFF81C784),
    successContainer: Color(0xFF1B5E20),
  );

  @override
  AppColors copyWith({
    Color? income,
    Color? expense,
    Color? balance,
    Color? savings,
    Color? contribution,
    Color? warning,
    Color? success,
    Color? successContainer,
  }) {
    return AppColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      balance: balance ?? this.balance,
      savings: savings ?? this.savings,
      contribution: contribution ?? this.contribution,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      balance: Color.lerp(balance, other.balance, t)!,
      savings: Color.lerp(savings, other.savings, t)!,
      contribution: Color.lerp(contribution, other.contribution, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
    );
  }
}
