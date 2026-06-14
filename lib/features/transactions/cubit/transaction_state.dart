import 'package:sms_transactions/domain/analytics/account_calculator.dart';
import 'package:sms_transactions/domain/models/account.dart';
import 'package:sms_transactions/domain/models/transaction.dart';

enum TransactionStatus { initial, loading, ready, error }

class TransactionState {
  final TransactionStatus status;
  final List<Transaction> transactions;
  final Set<String> salaryMarkedIds;
  final String? error;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.salaryMarkedIds = const {},
    this.error,
  });

  bool get isLoading => status == TransactionStatus.loading;
  bool get isReady => status == TransactionStatus.ready;
  bool get hasError => status == TransactionStatus.error;

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get rawExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get currentBalance => totalIncome - rawExpense;

  List<Account> get accounts => AccountCalculator.compute(transactions);

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? transactions,
    Set<String>? salaryMarkedIds,
    String? error,
    bool clearError = false,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      salaryMarkedIds: salaryMarkedIds ?? this.salaryMarkedIds,
      error: clearError ? null : error ?? this.error,
    );
  }
}
