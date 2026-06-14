import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_transactions/data/database/app_database.dart';
import 'package:sms_transactions/data/repositories/money_pool_repository.dart';
import 'package:sms_transactions/domain/models/money_pool.dart';
import 'package:sms_transactions/features/money_pool/cubit/money_pool_state.dart';

class MoneyPoolCubit extends Cubit<MoneyPoolState> {
  final MoneyPoolRepository _repo;

  MoneyPoolCubit(this._repo)
      : super(MoneyPoolState(moneyPool: MoneyPool()));

  MoneyPool get _moneyPool => state.moneyPool;

  List<PoolContribution> get contributions => _moneyPool.contributions;

  double get totalContributed => _moneyPool.totalContributed;

  Future<void> load() async {
    final contributionRows = await _repo.getContributions();
    _moneyPool.contributions
      ..clear()
      ..addAll(
        contributionRows.map(
          (row) => PoolContribution(
            id: row.id,
            date: DateTime.fromMillisecondsSinceEpoch(row.date),
            amount: row.amount,
          ),
        ),
      )
      ..sort((a, b) => b.date.compareTo(a.date));

    final payoutStateRows = await _repo.getPayoutStates();
    for (final row in payoutStateRows) {
      if (row.payoutIndex >= 0 && row.payoutIndex < _moneyPool.payouts.length) {
        _moneyPool.payouts[row.payoutIndex].isReceived = row.isReceived;
      }
    }

    emit(state.copyWith());
  }

  void addContribution(double amount, DateTime date) {
    final id = 'pool-${date.millisecondsSinceEpoch}';
    final contribution = PoolContribution(id: id, date: date, amount: amount);
    _moneyPool.contributions.add(contribution);
    _moneyPool.contributions.sort((a, b) => b.date.compareTo(a.date));
    _repo.insertContribution(
      PoolContributionsCompanion.insert(
        id: id,
        date: date.millisecondsSinceEpoch,
        amount: amount,
      ),
    );
    emit(state.copyWith());
  }

  void removeContribution(String id) {
    _moneyPool.contributions.removeWhere((c) => c.id == id);
    _repo.deleteContribution(id);
    emit(state.copyWith());
  }

  void togglePayoutReceived(int payoutIndex) {
    if (payoutIndex >= 0 && payoutIndex < _moneyPool.payouts.length) {
      _moneyPool.payouts[payoutIndex].isReceived =
          !_moneyPool.payouts[payoutIndex].isReceived;
      _repo.setPayoutReceived(
        payoutIndex,
        _moneyPool.payouts[payoutIndex].isReceived,
      );
      emit(state.copyWith());
    }
  }
}
