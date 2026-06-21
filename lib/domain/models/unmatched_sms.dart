/// An inbox SMS from a candidate sender that no learned pattern matched.
/// Persisted by [smsId]; the [body] is transient (in-memory only, never stored)
/// — populated from the scan for display (Constitution I).
///
/// State transitions (spec §Key Entities):
///  Unmatched → Matched   (record removed on pattern save / match)
///  Unmatched → Dismissed  (record removed, SuppressedSender created)
///  Matched   → Unmatched  (pattern deleted → sender's SMS re-queued)
///  Dismissed → Unmatched  (suppression removed → historical SMS re-queued)
class UnmatchedSms {
  final String smsId;
  final String senderId;
  final DateTime receivedAt;
  final bool dismissed;

  /// Transient — NOT a DB column. Populated from the in-memory scan for display.
  final String? body;

  const UnmatchedSms({
    required this.smsId,
    required this.senderId,
    required this.receivedAt,
    this.dismissed = false,
    this.body,
  });

  UnmatchedSms copyWith({
    String? smsId,
    String? senderId,
    DateTime? receivedAt,
    bool? dismissed,
    String? body,
  }) {
    return UnmatchedSms(
      smsId: smsId ?? this.smsId,
      senderId: senderId ?? this.senderId,
      receivedAt: receivedAt ?? this.receivedAt,
      dismissed: dismissed ?? this.dismissed,
      body: body ?? this.body,
    );
  }

  @override
  String toString() => 'UnmatchedSms($senderId, $smsId)';
}

/// A sender the user marked as non-financial. Suppresses current and future
/// SMS from [senderId] from the unmatched queue (FR-017). Exact case-sensitive
/// match on [senderId].
class SuppressedSender {
  final String senderId;
  final DateTime suppressedAt;

  const SuppressedSender({required this.senderId, required this.suppressedAt});

  @override
  String toString() => 'SuppressedSender($senderId)';
}
