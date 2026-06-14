import 'package:sms_transactions/data/database/app_database.dart';

class SalaryRepository {
  final AppDatabase _db;

  SalaryRepository(this._db);

  Future<Set<String>> getMarks() async {
    final rows = await _db.getSalaryMarks();
    return rows.map((r) => r.transactionId).toSet();
  }

  Future<void> insertMark(String transactionId) =>
      _db.insertSalaryMark(transactionId);

  Future<void> deleteMark(String transactionId) =>
      _db.deleteSalaryMark(transactionId);
}
