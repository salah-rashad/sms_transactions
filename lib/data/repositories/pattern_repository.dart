import 'package:drift/drift.dart';
import 'package:sms_transactions/data/database/app_database.dart';
import 'package:sms_transactions/domain/models/pattern_match.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';

/// Maps Drift rows ↔ plain domain models (mirrors the existing
/// `Transaction` ↔ `PoolContributionRow` convention). Registered in DI as a
/// lazy singleton. See `contracts/repositories.contract.md`.

class PatternRepository {
  final AppDatabase _db;

  PatternRepository(this._db);

  Future<List<SmsPattern>> getAll() async {
    final rows = await _db.select(_db.smsPatterns).get();
    return rows.map(_toDomain).toList();
  }

  /// Patterns for [senderId], createdAt-ascending (FR-034 ordering).
  Future<List<SmsPattern>> getForSender(String senderId) async {
    final query = _db.select(_db.smsPatterns)
      ..where((t) => t.senderId.equals(senderId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  /// Upsert; edit preserves totalAttempts/successfulMatches (FR-020).
  Future<void> upsert(SmsPattern pattern) async {
    await _db.into(_db.smsPatterns).insertOnConflictUpdate(
          SmsPatternsCompanion(
            id: Value(pattern.id),
            senderId: Value(pattern.senderId),
            amountBefore: Value(pattern.amountLocator?.beforeAnchor),
            amountAfter: Value(pattern.amountLocator?.afterAnchor),
            balanceBefore: Value(pattern.balanceLocator?.beforeAnchor),
            balanceAfter: Value(pattern.balanceLocator?.afterAnchor),
            counterpartyBefore: Value(pattern.counterpartyLocator?.beforeAnchor),
            counterpartyAfter: Value(pattern.counterpartyLocator?.afterAnchor),
            direction: Value(pattern.direction.index),
            exampleBody: Value(pattern.exampleBody),
            createdAt: Value(pattern.createdAt.millisecondsSinceEpoch),
            lastMatchedAt: Value(pattern.lastMatchedAt?.millisecondsSinceEpoch),
            totalAttempts: Value(pattern.totalAttempts),
            successfulMatches: Value(pattern.successfulMatches),
          ),
        );
  }

  /// Delete the pattern; matches/transactions are retained (FR-022).
  Future<void> delete(String patternId) async {
    await (_db.delete(_db.smsPatterns)
          ..where((t) => t.id.equals(patternId)))
        .go();
  }

  /// Updates the pattern's attempt/success counters and last-matched time.
  Future<void> recordAttempt(
    String patternId, {
    required bool success,
    DateTime? matchedAt,
  }) async {
    final existing = await (_db.select(_db.smsPatterns)
          ..where((t) => t.id.equals(patternId)))
        .getSingleOrNull();
    if (existing == null) return;
    await (_db.update(_db.smsPatterns)
          ..where((t) => t.id.equals(patternId)))
        .write(
          SmsPatternsCompanion(
            totalAttempts: Value(existing.totalAttempts + 1),
            successfulMatches:
                Value(existing.successfulMatches + (success ? 1 : 0)),
            lastMatchedAt:
                Value((matchedAt ?? DateTime.now()).millisecondsSinceEpoch),
          ),
        );
  }

  SmsPattern _toDomain(SmsPatternRow row) {
    return SmsPattern(
      id: row.id,
      senderId: row.senderId,
      amountLocator: (row.amountBefore == null && row.amountAfter == null)
          ? null
          : FieldLocator(
              beforeAnchor: row.amountBefore ?? '',
              afterAnchor: row.amountAfter ?? '',
            ),
      balanceLocator: (row.balanceBefore == null && row.balanceAfter == null)
          ? null
          : FieldLocator(
              beforeAnchor: row.balanceBefore ?? '',
              afterAnchor: row.balanceAfter ?? '',
            ),
      counterpartyLocator:
          (row.counterpartyBefore == null && row.counterpartyAfter == null)
          ? null
          : FieldLocator(
              beforeAnchor: row.counterpartyBefore ?? '',
              afterAnchor: row.counterpartyAfter ?? '',
            ),
      direction: SmsDirection.values[row.direction],
      exampleBody: row.exampleBody,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      lastMatchedAt: row.lastMatchedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.lastMatchedAt!),
      totalAttempts: row.totalAttempts,
      successfulMatches: row.successfulMatches,
    );
  }
}

/// The sole ledger source (research R1/R8 pass 3). `smsId` PK makes upserts
/// idempotent (FR-039/040). On pattern delete the rows are retained with
/// `patternId` nulled (FR-022).
class PatternMatchRepository {
  final AppDatabase _db;

  PatternMatchRepository(this._db);

  /// All matches — merged into the ledger at load (R1).
  Future<List<PatternMatch>> getAll() async {
    final rows = await _db.select(_db.patternMatches).get();
    return rows.map(_toDomain).toList();
  }

  /// Duplicate check for a smsId (FR-039/040).
  Future<PatternMatch?> getBySmsId(String smsId) async {
    final row = await (_db.select(_db.patternMatches)
          ..where((t) => t.smsId.equals(smsId)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// Upsert; `smsId` PK ⇒ idempotent.
  Future<void> upsert(PatternMatch match) async {
    await _db.into(_db.patternMatches).insertOnConflictUpdate(
          PatternMatchesCompanion(
            smsId: Value(match.smsId),
            patternId: Value(match.patternId),
            senderId: Value(match.senderId),
            amount: Value(match.amount),
            balance: Value(match.balance),
            counterparty: Value(match.counterparty),
            direction: Value(match.direction.index),
            receivedAt: Value(match.receivedAt.millisecondsSinceEpoch),
            matchedAt: Value(match.matchedAt.millisecondsSinceEpoch),
          ),
        );
  }

  /// Affected-count on delete (FR-022).
  Future<int> countForSender(String senderId) async {
    final count = await (_db.selectOnly(_db.patternMatches)
          ..addColumns([_db.patternMatches.smsId.count()])
          ..where(_db.patternMatches.senderId.equals(senderId)))
        .getSingle();
    return count.read(_db.patternMatches.smsId.count()) ?? 0;
  }

  /// On pattern delete: keep the rows but null their patternId (FR-022).
  Future<void> nullifyPatternRef(String patternId) async {
    await (_db.update(_db.patternMatches)
          ..where((t) => t.patternId.equals(patternId)))
        .write(const PatternMatchesCompanion(patternId: Value(null)));
  }

  PatternMatch _toDomain(PatternMatchRow row) {
    return PatternMatch(
      smsId: row.smsId,
      patternId: row.patternId,
      senderId: row.senderId,
      amount: row.amount,
      balance: row.balance,
      counterparty: row.counterparty,
      direction: SmsDirection.values[row.direction],
      receivedAt: DateTime.fromMillisecondsSinceEpoch(row.receivedAt),
      matchedAt: DateTime.fromMillisecondsSinceEpoch(row.matchedAt),
    );
  }
}
