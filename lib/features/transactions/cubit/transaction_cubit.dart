import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_transactions/data/repositories/salary_repository.dart';
import 'package:sms_transactions/data/services/sms_parser.dart';
import 'package:sms_transactions/data/services/sms_service.dart';
import 'package:sms_transactions/domain/models/transaction.dart';
import 'package:sms_transactions/features/transactions/cubit/transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final SmsService _smsService;
  final SalaryRepository _salaryRepo;

  TransactionCubit(this._smsService, this._salaryRepo)
    : super(const TransactionState());

  Future<void> loadTransactions() async {
    emit(state.copyWith(status: TransactionStatus.loading, clearError: true));

    try {
      final salaryMarkedIds = await _salaryRepo.getMarks();

      final granted = await _smsService.requestPermission();
      if (!granted) {
        emit(
          state.copyWith(
            status: TransactionStatus.error,
            error: 'SMS permission denied',
          ),
        );
        return;
      }

      final messages = await _smsService.getFinancialSms();

      final transactions = messages
          .map((sms) => SmsParser.parse(sms))
          .whereType<Transaction>()
          .toList();

      for (final t in transactions) {
        if (salaryMarkedIds.contains(t.id)) {
          t.isMarkedAsSalary = true;
        }
      }

      emit(
        state.copyWith(
          status: TransactionStatus.ready,
          transactions: transactions,
          salaryMarkedIds: salaryMarkedIds,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: TransactionStatus.error, error: e.toString()),
      );
    }
  }

  void toggleSalaryMark(String transactionId) {
    final t = state.transactions
        .where((t) => t.id == transactionId)
        .firstOrNull;
    if (t == null || t.type != TransactionType.income) return;

    t.isMarkedAsSalary = !t.isMarkedAsSalary;

    final ids = Set<String>.from(state.salaryMarkedIds);
    if (t.isMarkedAsSalary) {
      ids.add(transactionId);
      _salaryRepo.insertMark(transactionId);
    } else {
      ids.remove(transactionId);
      _salaryRepo.deleteMark(transactionId);
    }

    emit(
      state.copyWith(
        transactions: List.of(state.transactions),
        salaryMarkedIds: ids,
      ),
    );
  }
}
