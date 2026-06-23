import 'package:sms_transactions/domain/models/transaction.dart';

/// Direction of a parsed SMS, mapped 1:1 to the existing [TransactionType].
/// See specs/001-sms-pattern-authoring/data-model.md.
enum SmsDirection {
  income,
  expense,
  balanceCheck,
  ignore;

  /// Maps to a [TransactionType] for ledger entry. [ignore] has no mapping —
  /// callers must filter ignore-direction matches before reaching this.
  TransactionType toTransactionType() {
    switch (this) {
      case SmsDirection.income:
        return TransactionType.income;
      case SmsDirection.expense:
        return TransactionType.expense;
      case SmsDirection.balanceCheck:
        return TransactionType.balanceCheck;
      case SmsDirection.ignore:
        throw StateError(
          'SmsDirection.ignore has no TransactionType — filter before mapping',
        );
    }
  }

  static SmsDirection fromTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return SmsDirection.income;
      case TransactionType.expense:
        return SmsDirection.expense;
      case TransactionType.balanceCheck:
        return SmsDirection.balanceCheck;
    }
  }
}

/// A field locator = the whitespace-delimited words immediately surrounding a
/// selected value. At least one of [beforeAnchor]/[afterAnchor] MUST be
/// non-empty (FR-032). Anchors are plain text; the matcher derives a regex at
/// match time (FR-016 forbids storing indices).
class FieldLocator {
  final String beforeAnchor;
  final String afterAnchor;

  const FieldLocator({required this.beforeAnchor, required this.afterAnchor});

  bool get isValid => beforeAnchor.isNotEmpty || afterAnchor.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldLocator &&
          beforeAnchor == other.beforeAnchor &&
          afterAnchor == other.afterAnchor;

  @override
  int get hashCode => Object.hash(beforeAnchor, afterAnchor);

  @override
  String toString() => 'FieldLocator(before="$beforeAnchor", after="$afterAnchor")';
}

/// A user-taught parsing rule for a single sender's SMS format.
class SmsPattern {
  final String id;
  final String senderId;

  /// Required for [SmsDirection.income] / [expense]; null allowed for
  /// [balanceCheck] (balanceLocator is the gate) and [ignore]
  /// (counterpartyLocator is the gate).
  final FieldLocator? amountLocator;
  final FieldLocator? balanceLocator;
  final FieldLocator? counterpartyLocator;
  final SmsDirection direction;

  /// The teaching SMS body. The one on-device place a body is persisted —
  /// required to re-enter the edit flow (FR-021).
  final String exampleBody;
  final DateTime createdAt;
  final DateTime? lastMatchedAt;
  final int totalAttempts;
  final int successfulMatches;

  const SmsPattern({
    required this.id,
    required this.senderId,
    this.amountLocator,
    this.balanceLocator,
    this.counterpartyLocator,
    required this.direction,
    required this.exampleBody,
    required this.createdAt,
    this.lastMatchedAt,
    this.totalAttempts = 0,
    this.successfulMatches = 0,
  });

  /// Derived confidence in [0.0, 1.0]. A brand-new pattern is 100% (FR-020).
  double get confidence {
    if (totalAttempts == 0) return 1.0;
    return successfulMatches / totalAttempts;
  }

  SmsPattern copyWith({
    String? id,
    String? senderId,
    FieldLocator? amountLocator,
    FieldLocator? balanceLocator,
    FieldLocator? counterpartyLocator,
    SmsDirection? direction,
    String? exampleBody,
    DateTime? createdAt,
    DateTime? lastMatchedAt,
    int? totalAttempts,
    int? successfulMatches,
    bool clearAmount = false,
    bool clearBalance = false,
    bool clearCounterparty = false,
  }) {
    return SmsPattern(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      amountLocator:
          clearAmount ? null : (amountLocator ?? this.amountLocator),
      balanceLocator:
          clearBalance ? null : (balanceLocator ?? this.balanceLocator),
      counterpartyLocator: clearCounterparty
          ? null
          : (counterpartyLocator ?? this.counterpartyLocator),
      direction: direction ?? this.direction,
      exampleBody: exampleBody ?? this.exampleBody,
      createdAt: createdAt ?? this.createdAt,
      lastMatchedAt: lastMatchedAt ?? this.lastMatchedAt,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      successfulMatches: successfulMatches ?? this.successfulMatches,
    );
  }

  @override
  String toString() =>
      'SmsPattern($senderId, dir=$direction, attempts=$totalAttempts, '
      'ok=$successfulMatches)';
}
