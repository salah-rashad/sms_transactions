import 'package:sms_transactions/data/database/app_database.dart';

/// Exact case-sensitive suppression set (FR-017). A suppressed sender's SMS
/// never enter the unmatched queue. See `contracts/repositories.contract.md`.
class SuppressedSenderRepository {
  final AppDatabase _db;

  SuppressedSenderRepository(this._db);

  /// The full suppression set (exact-match strings).
  Future<Set<String>> getAll() async {
    final rows = await _db.select(_db.suppressedSenders).get();
    return rows.map((r) => r.senderId).toSet();
  }

  /// Dismiss (US3): add the sender to the suppression set.
  Future<void> suppress(String senderId) async {
    await _db.into(_db.suppressedSenders).insertOnConflictUpdate(
          SuppressedSendersCompanion.insert(
            senderId: senderId,
            suppressedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  /// Re-activate (FR-018): historical SMS re-enter the queue on next scan.
  Future<void> unsuppress(String senderId) async {
    await (_db.delete(_db.suppressedSenders)
          ..where((t) => t.senderId.equals(senderId)))
        .go();
  }
}
