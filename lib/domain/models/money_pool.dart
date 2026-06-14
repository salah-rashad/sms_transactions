class PoolContribution {
  final String id;
  final DateTime date;
  final double amount;

  const PoolContribution({
    required this.id,
    required this.date,
    required this.amount,
  });
}

class PoolPayout {
  final DateTime date;
  final double amount;
  bool isReceived;

  PoolPayout({
    required this.date,
    required this.amount,
    this.isReceived = false,
  });
}

class MoneyPool {
  final List<PoolContribution> contributions;
  final List<PoolPayout> payouts;

  MoneyPool({
    List<PoolContribution>? contributions,
    List<PoolPayout>? payouts,
  })  : contributions = contributions ?? [],
        payouts = payouts ?? [
          PoolPayout(date: DateTime(2026, 9, 1), amount: 100000),
          PoolPayout(date: DateTime(2027, 4, 1), amount: 100000),
          PoolPayout(date: DateTime(2028, 5, 1), amount: 100000),
          PoolPayout(date: DateTime(2028, 12, 1), amount: 100000),
        ];

  double get totalContributed =>
      contributions.fold(0.0, (sum, c) => sum + c.amount);

  double get totalExpectedPayout =>
      payouts.fold(0.0, (sum, p) => sum + p.amount);

  double get totalReceived =>
      payouts.where((p) => p.isReceived).fold(0.0, (sum, p) => sum + p.amount);

  double get netPosition => totalExpectedPayout - totalContributed;

  PoolPayout? get nextPayout {
    final upcoming = payouts.where((p) => !p.isReceived).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  int get monthsUntilNextPayout {
    final next = nextPayout;
    if (next == null) return 0;
    final now = DateTime.now();
    int months = (next.date.year - now.year) * 12 + next.date.month - now.month;
    return months < 0 ? 0 : months;
  }

  int get contributionCount => contributions.length;
}
