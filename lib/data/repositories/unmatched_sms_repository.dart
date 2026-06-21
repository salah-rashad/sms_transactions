import 'package:drift/drift.dart';
import 'package:sms_transactions/data/database/app_database.dart';
import 'package:sms_transactions/domain/models/unmatched_sms.dart';

/// Reads/writes the unmatched-SMS queue. The [UnmatchedSms.body] field is
/// transient (never persisted — privacy I); persistence keys on [smsId].
/// See `contracts/repositories.contract.md`.
class UnmatchedSmsRepository {
  final AppDatabase _db;

  UnmatchedSmsRepository(this._db);

  /// Active (not dismissed) records, newest first (FR-005). Callers group by
  /// sender in the presentation layer.
  Future<List<UnmatchedSms>> getActive() async {
    final query = _db.select(_db.unmatchedSmsRecords)
      ..where((t) => t.dismissed.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]);
    final rows = await query.get();
    return rows
        .map((r) => UnmatchedSms(
              smsId: r.smsId,
              senderId: r.senderId,
              receivedAt:
                  DateTime.fromMillisecondsSinceEpoch(r.receivedAt),
            ))
        .toList();
  }

  /// Fast persisted count for the dashboard card's instant render (R9, SC-005).
  Future<int> activeCount() async {
    final count = await (_db.selectOnly(_db.unmatchedSmsRecords)
          ..addColumns([_db.unmatchedSmsRecords.smsId.count()])
          ..where(_db.unmatchedSmsRecords.dismissed.equals(false)))
        .getSingle();
    return count.read(_db.unmatchedSmsRecords.smsId.count()) ?? 0;
  }

  /// Idempotent bulk insert from a scan.
  Future<void> upsertAll(List<UnmatchedSms> records) async {
    await _db.batch((b) {
      for (final r in records) {
        b.insert(
          _db.unmatchedSmsRecords,
          UnmatchedSmsRecordsCompanion.insert(
            smsId: r.smsId,
            senderId: r.senderId,
            receivedAt: r.receivedAt.millisecondsSinceEpoch,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  /// On match: remove the record from the queue (FR-035).
  Future<void> removeBySmsId(String smsId) async {
    await (_db.delete(_db.unmatchedSmsRecords)
          ..where((t) => t.smsId.equals(smsId)))
        .go();
  }

  /// On suppress: remove all of this sender's records (US3).
  Future<void> removeBySender(String senderId) async {
    await (_db.delete(_db.unmatchedSmsRecords)
          ..where((t) => t.senderId.equals(senderId)))
        .go();
  }

  /// Orphan prune: delete records whose smsId is absent from the current inbox
  /// scan (FR-042). PatternMatch/Transaction rows are retained.
  Future<void> pruneMissing(Set<String> presentSmsIds) async {
    final query = _db.delete(_db.unmatchedSmsRecords);
    if (presentSmsIds.isEmpty) {
      await query.go();
      return;
    }
    await (query
          ..where((t) => t.smsId.isNotIn(presentSmsIds)))
        .go();
  }
}
