import 'package:sms_transactions/domain/models/sms_pattern.dart';

/// A successful learned-pattern parse of one SMS — the sole ledger source
/// (research R1/R8 pass 3). One [PatternMatch] ↔ one ledger [Transaction]
/// (FR-015). [smsId] PK prevents duplicates (FR-039/040).
///
/// On pattern delete the row is retained with [patternId] nulled — the
/// transaction survives (FR-022). [senderId] is denormalized so the match
/// survives pattern deletion.
///
/// The `→ Transaction` mapper lives with the T036/T038 refactor (Phase 5),
/// once `Transaction.source` becomes a sender string.
class PatternMatch {
  final String smsId;
  final String? patternId;
  final String senderId;

  /// Required for income/expense matches. Null is valid for [balanceCheck]
  /// (the balance is the value of interest) and never persisted for
  /// [SmsDirection.ignore] (those don't create PatternMatch rows at all).
  final double? amount;
  final double? balance;
  final String? counterparty;
  final SmsDirection direction;

  /// = transaction date (FR-015). Passed in at match time; the matcher never
  /// reads the clock.
  final DateTime receivedAt;
  final DateTime matchedAt;

  const PatternMatch({
    required this.smsId,
    this.patternId,
    required this.senderId,
    required this.amount,
    this.balance,
    this.counterparty,
    required this.direction,
    required this.receivedAt,
    required this.matchedAt,
  });

  PatternMatch copyWith({
    String? smsId,
    String? patternId,
    String? senderId,
    double? amount,
    double? balance,
    String? counterparty,
    SmsDirection? direction,
    DateTime? receivedAt,
    DateTime? matchedAt,
    bool clearPatternId = false,
    bool clearAmount = false,
    bool clearBalance = false,
    bool clearCounterparty = false,
  }) {
    return PatternMatch(
      smsId: smsId ?? this.smsId,
      patternId: clearPatternId ? null : (patternId ?? this.patternId),
      senderId: senderId ?? this.senderId,
      amount: clearAmount ? null : (amount ?? this.amount),
      balance: clearBalance ? null : (balance ?? this.balance),
      counterparty:
          clearCounterparty ? null : (counterparty ?? this.counterparty),
      direction: direction ?? this.direction,
      receivedAt: receivedAt ?? this.receivedAt,
      matchedAt: matchedAt ?? this.matchedAt,
    );
  }

  @override
  String toString() =>
      'PatternMatch($senderId, $smsId, amount=$amount, dir=$direction)';
}
