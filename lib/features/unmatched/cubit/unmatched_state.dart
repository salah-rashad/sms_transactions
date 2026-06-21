import 'package:sms_transactions/domain/models/unmatched_sms.dart';

enum UnmatchedStatus { initial, scanning, ready, error }

/// Immutable state for [UnmatchedCubit] (R7). [count] drives the dashboard card
/// visibility (card visible iff count > 0, FR-001/003/004). See
/// `contracts/cubits.contract.md`.
class UnmatchedState {
  final List<UnmatchedSms> items;
  final int count;
  final UnmatchedStatus status;
  final String? error;

  const UnmatchedState({
    this.items = const [],
    this.count = 0,
    this.status = UnmatchedStatus.initial,
    this.error,
  });

  bool get isScanning => status == UnmatchedStatus.scanning;
  bool get hasError => status == UnmatchedStatus.error;

  /// Active unmatched records grouped by sender (FR-005), each group sorted
  /// newest-first; senders ordered by their most-recent message.
  Map<String, List<UnmatchedSms>> get groupedBySender {
    final map = <String, List<UnmatchedSms>>{};
    for (final item in items) {
      map.putIfAbsent(item.senderId, () => []).add(item);
    }
    for (final list in map.values) {
      list.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    }
    final sortedKeys = map.keys.toList()
      ..sort(
        (a, b) => map[b]!.first.receivedAt.compareTo(map[a]!.first.receivedAt),
      );
    return {for (final k in sortedKeys) k: map[k]!};
  }

  UnmatchedState copyWith({
    List<UnmatchedSms>? items,
    int? count,
    UnmatchedStatus? status,
    String? error,
    bool clearError = false,
  }) {
    return UnmatchedState(
      items: items ?? this.items,
      count: count ?? this.count,
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
    );
  }
}
