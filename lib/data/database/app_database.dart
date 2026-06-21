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

// --- SMS Pattern Authoring (schema v2) -------------------------------------
// See specs/001-sms-pattern-authoring/data-model.md. FieldLocator values are
// flattened into paired *Before/**After text columns. Dates are epoch-millis.
// No raw SMS body is stored except the user-taught exampleBody (privacy I).

@DataClassName('SmsPatternRow')
class SmsPatterns extends Table {
  TextColumn get id => text()();
  TextColumn get senderId => text()();
  TextColumn get amountBefore => text()();
  TextColumn get amountAfter => text()();
  TextColumn get balanceBefore => text().nullable()();
  TextColumn get balanceAfter => text().nullable()();
  TextColumn get counterpartyBefore => text().nullable()();
  TextColumn get counterpartyAfter => text().nullable()();
  IntColumn get direction => integer()();
  TextColumn get exampleBody => text()();
  IntColumn get createdAt => integer()();
  IntColumn get lastMatchedAt => integer().nullable()();
  IntColumn get totalAttempts => integer().withDefault(const Constant(0))();
  IntColumn get successfulMatches => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PatternMatchRow')
class PatternMatches extends Table {
  TextColumn get smsId => text()();
  TextColumn get patternId => text().nullable()();
  TextColumn get senderId => text()();
  RealColumn get amount => real()();
  RealColumn get balance => real().nullable()();
  TextColumn get counterparty => text().nullable()();
  IntColumn get direction => integer()();
  IntColumn get receivedAt => integer()();
  IntColumn get matchedAt => integer()();

  @override
  Set<Column> get primaryKey => {smsId};
}

@DataClassName('UnmatchedSmsRow')
class UnmatchedSmsRecords extends Table {
  TextColumn get smsId => text()();
  TextColumn get senderId => text()();
  IntColumn get receivedAt => integer()();
  BoolColumn get dismissed =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {smsId};
}

@DataClassName('SuppressedSenderRow')
class SuppressedSenders extends Table {
  TextColumn get senderId => text()();
  IntColumn get suppressedAt => integer()();

  @override
  Set<Column> get primaryKey => {senderId};
}

@DriftDatabase(
  tables: [
    PoolContributions,
    PayoutStates,
    SalaryMarks,
    SmsPatterns,
    PatternMatches,
    UnmatchedSmsRecords,
    SuppressedSenders,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Additive: create the four new tables. Existing tables untouched.
        await m.createTable(smsPatterns);
        await m.createTable(patternMatches);
        await m.createTable(unmatchedSmsRecords);
        await m.createTable(suppressedSenders);
      }
    },
  );

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
