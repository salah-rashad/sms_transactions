import 'package:sms_transactions/data/database/app_database.dart';

class MoneyPoolRepository {
  final AppDatabase _db;

  MoneyPoolRepository(this._db);

  Future<List<PoolContributionRow>> getContributions() =>
      _db.getAllContributions();

  Future<void> insertContribution(PoolContributionsCompanion row) =>
      _db.insertContribution(row);

  Future<void> deleteContribution(String id) =>
      _db.deleteContribution(id);

  Future<List<PayoutStateRow>> getPayoutStates() =>
      _db.getPayoutStates();

  Future<void> setPayoutReceived(int index, bool received) =>
      _db.setPayoutReceived(index, received);
}
