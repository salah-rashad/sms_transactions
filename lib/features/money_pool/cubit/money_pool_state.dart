import 'package:sms_transactions/domain/models/money_pool.dart';

class MoneyPoolState {
  final MoneyPool moneyPool;

  const MoneyPoolState({required this.moneyPool});

  MoneyPoolState copyWith({MoneyPool? moneyPool}) =>
      MoneyPoolState(moneyPool: moneyPool ?? this.moneyPool);
}
