import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('PoolContributionRow')
class PoolContributions extends Table {
  TextColumn get id => text()();
  IntColumn get date => integer()();
  RealColumn get amount => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PayoutStateRow')
class PayoutStates extends Table {
  IntColumn get payoutIndex => integer()();
  BoolColumn get isReceived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {payoutIndex};
}

@DataClassName('SalaryMarkRow')
class SalaryMarks extends Table {
  TextColumn get transactionId => text()();

  @override
  Set<Column> get primaryKey => {transactionId};
}

@DriftDatabase(tables: [PoolContributions, PayoutStates, SalaryMarks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<PoolContributionRow>> getAllContributions() =>
      select(poolContributions).get();

  Future<void> insertContribution(PoolContributionsCompanion row) =>
      into(poolContributions).insertOnConflictUpdate(row);

  Future<void> deleteContribution(String id) =>
      (delete(poolContributions)..where((t) => t.id.equals(id))).go();

  Future<List<PayoutStateRow>> getPayoutStates() => select(payoutStates).get();

  Future<void> setPayoutReceived(int index, bool received) =>
      into(payoutStates).insertOnConflictUpdate(
        PayoutStatesCompanion(
          payoutIndex: Value(index),
          isReceived: Value(received),
        ),
      );

  Future<List<SalaryMarkRow>> getSalaryMarks() => select(salaryMarks).get();

  Future<void> insertSalaryMark(String transactionId) =>
      into(salaryMarks).insertOnConflictUpdate(
        SalaryMarksCompanion(transactionId: Value(transactionId)),
      );

  Future<void> deleteSalaryMark(String transactionId) => (delete(
    salaryMarks,
  )..where((t) => t.transactionId.equals(transactionId))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
