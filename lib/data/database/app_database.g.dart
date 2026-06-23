// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PoolContributionsTable extends PoolContributions
    with TableInfo<$PoolContributionsTable, PoolContributionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PoolContributionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, amount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pool_contributions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PoolContributionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PoolContributionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PoolContributionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $PoolContributionsTable createAlias(String alias) {
    return $PoolContributionsTable(attachedDatabase, alias);
  }
}

class PoolContributionRow extends DataClass
    implements Insertable<PoolContributionRow> {
  final String id;
  final int date;
  final double amount;
  const PoolContributionRow({
    required this.id,
    required this.date,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<int>(date);
    map['amount'] = Variable<double>(amount);
    return map;
  }

  PoolContributionsCompanion toCompanion(bool nullToAbsent) {
    return PoolContributionsCompanion(
      id: Value(id),
      date: Value(date),
      amount: Value(amount),
    );
  }

  factory PoolContributionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PoolContributionRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<int>(json['date']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<int>(date),
      'amount': serializer.toJson<double>(amount),
    };
  }

  PoolContributionRow copyWith({String? id, int? date, double? amount}) =>
      PoolContributionRow(
        id: id ?? this.id,
        date: date ?? this.date,
        amount: amount ?? this.amount,
      );
  PoolContributionRow copyWithCompanion(PoolContributionsCompanion data) {
    return PoolContributionRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PoolContributionRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoolContributionRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.amount == this.amount);
}

class PoolContributionsCompanion extends UpdateCompanion<PoolContributionRow> {
  final Value<String> id;
  final Value<int> date;
  final Value<double> amount;
  final Value<int> rowid;
  const PoolContributionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PoolContributionsCompanion.insert({
    required String id,
    required int date,
    required double amount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       amount = Value(amount);
  static Insertable<PoolContributionRow> custom({
    Expression<String>? id,
    Expression<int>? date,
    Expression<double>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PoolContributionsCompanion copyWith({
    Value<String>? id,
    Value<int>? date,
    Value<double>? amount,
    Value<int>? rowid,
  }) {
    return PoolContributionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoolContributionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayoutStatesTable extends PayoutStates
    with TableInfo<$PayoutStatesTable, PayoutStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayoutStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _payoutIndexMeta = const VerificationMeta(
    'payoutIndex',
  );
  @override
  late final GeneratedColumn<int> payoutIndex = GeneratedColumn<int>(
    'payout_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isReceivedMeta = const VerificationMeta(
    'isReceived',
  );
  @override
  late final GeneratedColumn<bool> isReceived = GeneratedColumn<bool>(
    'is_received',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_received" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [payoutIndex, isReceived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payout_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayoutStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('payout_index')) {
      context.handle(
        _payoutIndexMeta,
        payoutIndex.isAcceptableOrUnknown(
          data['payout_index']!,
          _payoutIndexMeta,
        ),
      );
    }
    if (data.containsKey('is_received')) {
      context.handle(
        _isReceivedMeta,
        isReceived.isAcceptableOrUnknown(data['is_received']!, _isReceivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {payoutIndex};
  @override
  PayoutStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayoutStateRow(
      payoutIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payout_index'],
      )!,
      isReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_received'],
      )!,
    );
  }

  @override
  $PayoutStatesTable createAlias(String alias) {
    return $PayoutStatesTable(attachedDatabase, alias);
  }
}

class PayoutStateRow extends DataClass implements Insertable<PayoutStateRow> {
  final int payoutIndex;
  final bool isReceived;
  const PayoutStateRow({required this.payoutIndex, required this.isReceived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['payout_index'] = Variable<int>(payoutIndex);
    map['is_received'] = Variable<bool>(isReceived);
    return map;
  }

  PayoutStatesCompanion toCompanion(bool nullToAbsent) {
    return PayoutStatesCompanion(
      payoutIndex: Value(payoutIndex),
      isReceived: Value(isReceived),
    );
  }

  factory PayoutStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayoutStateRow(
      payoutIndex: serializer.fromJson<int>(json['payoutIndex']),
      isReceived: serializer.fromJson<bool>(json['isReceived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'payoutIndex': serializer.toJson<int>(payoutIndex),
      'isReceived': serializer.toJson<bool>(isReceived),
    };
  }

  PayoutStateRow copyWith({int? payoutIndex, bool? isReceived}) =>
      PayoutStateRow(
        payoutIndex: payoutIndex ?? this.payoutIndex,
        isReceived: isReceived ?? this.isReceived,
      );
  PayoutStateRow copyWithCompanion(PayoutStatesCompanion data) {
    return PayoutStateRow(
      payoutIndex: data.payoutIndex.present
          ? data.payoutIndex.value
          : this.payoutIndex,
      isReceived: data.isReceived.present
          ? data.isReceived.value
          : this.isReceived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayoutStateRow(')
          ..write('payoutIndex: $payoutIndex, ')
          ..write('isReceived: $isReceived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(payoutIndex, isReceived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayoutStateRow &&
          other.payoutIndex == this.payoutIndex &&
          other.isReceived == this.isReceived);
}

class PayoutStatesCompanion extends UpdateCompanion<PayoutStateRow> {
  final Value<int> payoutIndex;
  final Value<bool> isReceived;
  const PayoutStatesCompanion({
    this.payoutIndex = const Value.absent(),
    this.isReceived = const Value.absent(),
  });
  PayoutStatesCompanion.insert({
    this.payoutIndex = const Value.absent(),
    this.isReceived = const Value.absent(),
  });
  static Insertable<PayoutStateRow> custom({
    Expression<int>? payoutIndex,
    Expression<bool>? isReceived,
  }) {
    return RawValuesInsertable({
      if (payoutIndex != null) 'payout_index': payoutIndex,
      if (isReceived != null) 'is_received': isReceived,
    });
  }

  PayoutStatesCompanion copyWith({
    Value<int>? payoutIndex,
    Value<bool>? isReceived,
  }) {
    return PayoutStatesCompanion(
      payoutIndex: payoutIndex ?? this.payoutIndex,
      isReceived: isReceived ?? this.isReceived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (payoutIndex.present) {
      map['payout_index'] = Variable<int>(payoutIndex.value);
    }
    if (isReceived.present) {
      map['is_received'] = Variable<bool>(isReceived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayoutStatesCompanion(')
          ..write('payoutIndex: $payoutIndex, ')
          ..write('isReceived: $isReceived')
          ..write(')'))
        .toString();
  }
}

class $SalaryMarksTable extends SalaryMarks
    with TableInfo<$SalaryMarksTable, SalaryMarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalaryMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [transactionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'salary_marks';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalaryMarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId};
  @override
  SalaryMarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalaryMarkRow(
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
    );
  }

  @override
  $SalaryMarksTable createAlias(String alias) {
    return $SalaryMarksTable(attachedDatabase, alias);
  }
}

class SalaryMarkRow extends DataClass implements Insertable<SalaryMarkRow> {
  final String transactionId;
  const SalaryMarkRow({required this.transactionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<String>(transactionId);
    return map;
  }

  SalaryMarksCompanion toCompanion(bool nullToAbsent) {
    return SalaryMarksCompanion(transactionId: Value(transactionId));
  }

  factory SalaryMarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalaryMarkRow(
      transactionId: serializer.fromJson<String>(json['transactionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<String>(transactionId),
    };
  }

  SalaryMarkRow copyWith({String? transactionId}) =>
      SalaryMarkRow(transactionId: transactionId ?? this.transactionId);
  SalaryMarkRow copyWithCompanion(SalaryMarksCompanion data) {
    return SalaryMarkRow(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalaryMarkRow(')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => transactionId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalaryMarkRow && other.transactionId == this.transactionId);
}

class SalaryMarksCompanion extends UpdateCompanion<SalaryMarkRow> {
  final Value<String> transactionId;
  final Value<int> rowid;
  const SalaryMarksCompanion({
    this.transactionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalaryMarksCompanion.insert({
    required String transactionId,
    this.rowid = const Value.absent(),
  }) : transactionId = Value(transactionId);
  static Insertable<SalaryMarkRow> custom({
    Expression<String>? transactionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalaryMarksCompanion copyWith({
    Value<String>? transactionId,
    Value<int>? rowid,
  }) {
    return SalaryMarksCompanion(
      transactionId: transactionId ?? this.transactionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalaryMarksCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SmsPatternsTable extends SmsPatterns
    with TableInfo<$SmsPatternsTable, SmsPatternRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmsPatternsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountBeforeMeta = const VerificationMeta(
    'amountBefore',
  );
  @override
  late final GeneratedColumn<String> amountBefore = GeneratedColumn<String>(
    'amount_before',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountAfterMeta = const VerificationMeta(
    'amountAfter',
  );
  @override
  late final GeneratedColumn<String> amountAfter = GeneratedColumn<String>(
    'amount_after',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceBeforeMeta = const VerificationMeta(
    'balanceBefore',
  );
  @override
  late final GeneratedColumn<String> balanceBefore = GeneratedColumn<String>(
    'balance_before',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  @override
  late final GeneratedColumn<String> balanceAfter = GeneratedColumn<String>(
    'balance_after',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _counterpartyBeforeMeta =
      const VerificationMeta('counterpartyBefore');
  @override
  late final GeneratedColumn<String> counterpartyBefore =
      GeneratedColumn<String>(
        'counterparty_before',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _counterpartyAfterMeta = const VerificationMeta(
    'counterpartyAfter',
  );
  @override
  late final GeneratedColumn<String> counterpartyAfter =
      GeneratedColumn<String>(
        'counterparty_after',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<int> direction = GeneratedColumn<int>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exampleBodyMeta = const VerificationMeta(
    'exampleBody',
  );
  @override
  late final GeneratedColumn<String> exampleBody = GeneratedColumn<String>(
    'example_body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMatchedAtMeta = const VerificationMeta(
    'lastMatchedAt',
  );
  @override
  late final GeneratedColumn<int> lastMatchedAt = GeneratedColumn<int>(
    'last_matched_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAttemptsMeta = const VerificationMeta(
    'totalAttempts',
  );
  @override
  late final GeneratedColumn<int> totalAttempts = GeneratedColumn<int>(
    'total_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _successfulMatchesMeta = const VerificationMeta(
    'successfulMatches',
  );
  @override
  late final GeneratedColumn<int> successfulMatches = GeneratedColumn<int>(
    'successful_matches',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    senderId,
    amountBefore,
    amountAfter,
    balanceBefore,
    balanceAfter,
    counterpartyBefore,
    counterpartyAfter,
    direction,
    exampleBody,
    createdAt,
    lastMatchedAt,
    totalAttempts,
    successfulMatches,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sms_patterns';
  @override
  VerificationContext validateIntegrity(
    Insertable<SmsPatternRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('amount_before')) {
      context.handle(
        _amountBeforeMeta,
        amountBefore.isAcceptableOrUnknown(
          data['amount_before']!,
          _amountBeforeMeta,
        ),
      );
    }
    if (data.containsKey('amount_after')) {
      context.handle(
        _amountAfterMeta,
        amountAfter.isAcceptableOrUnknown(
          data['amount_after']!,
          _amountAfterMeta,
        ),
      );
    }
    if (data.containsKey('balance_before')) {
      context.handle(
        _balanceBeforeMeta,
        balanceBefore.isAcceptableOrUnknown(
          data['balance_before']!,
          _balanceBeforeMeta,
        ),
      );
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    }
    if (data.containsKey('counterparty_before')) {
      context.handle(
        _counterpartyBeforeMeta,
        counterpartyBefore.isAcceptableOrUnknown(
          data['counterparty_before']!,
          _counterpartyBeforeMeta,
        ),
      );
    }
    if (data.containsKey('counterparty_after')) {
      context.handle(
        _counterpartyAfterMeta,
        counterpartyAfter.isAcceptableOrUnknown(
          data['counterparty_after']!,
          _counterpartyAfterMeta,
        ),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('example_body')) {
      context.handle(
        _exampleBodyMeta,
        exampleBody.isAcceptableOrUnknown(
          data['example_body']!,
          _exampleBodyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exampleBodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_matched_at')) {
      context.handle(
        _lastMatchedAtMeta,
        lastMatchedAt.isAcceptableOrUnknown(
          data['last_matched_at']!,
          _lastMatchedAtMeta,
        ),
      );
    }
    if (data.containsKey('total_attempts')) {
      context.handle(
        _totalAttemptsMeta,
        totalAttempts.isAcceptableOrUnknown(
          data['total_attempts']!,
          _totalAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('successful_matches')) {
      context.handle(
        _successfulMatchesMeta,
        successfulMatches.isAcceptableOrUnknown(
          data['successful_matches']!,
          _successfulMatchesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmsPatternRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmsPatternRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      amountBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_before'],
      ),
      amountAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_after'],
      ),
      balanceBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}balance_before'],
      ),
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}balance_after'],
      ),
      counterpartyBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty_before'],
      ),
      counterpartyAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty_after'],
      ),
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}direction'],
      )!,
      exampleBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      lastMatchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_matched_at'],
      ),
      totalAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_attempts'],
      )!,
      successfulMatches: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}successful_matches'],
      )!,
    );
  }

  @override
  $SmsPatternsTable createAlias(String alias) {
    return $SmsPatternsTable(attachedDatabase, alias);
  }
}

class SmsPatternRow extends DataClass implements Insertable<SmsPatternRow> {
  final String id;
  final String senderId;
  final String? amountBefore;
  final String? amountAfter;
  final String? balanceBefore;
  final String? balanceAfter;
  final String? counterpartyBefore;
  final String? counterpartyAfter;
  final int direction;
  final String exampleBody;
  final int createdAt;
  final int? lastMatchedAt;
  final int totalAttempts;
  final int successfulMatches;
  const SmsPatternRow({
    required this.id,
    required this.senderId,
    this.amountBefore,
    this.amountAfter,
    this.balanceBefore,
    this.balanceAfter,
    this.counterpartyBefore,
    this.counterpartyAfter,
    required this.direction,
    required this.exampleBody,
    required this.createdAt,
    this.lastMatchedAt,
    required this.totalAttempts,
    required this.successfulMatches,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sender_id'] = Variable<String>(senderId);
    if (!nullToAbsent || amountBefore != null) {
      map['amount_before'] = Variable<String>(amountBefore);
    }
    if (!nullToAbsent || amountAfter != null) {
      map['amount_after'] = Variable<String>(amountAfter);
    }
    if (!nullToAbsent || balanceBefore != null) {
      map['balance_before'] = Variable<String>(balanceBefore);
    }
    if (!nullToAbsent || balanceAfter != null) {
      map['balance_after'] = Variable<String>(balanceAfter);
    }
    if (!nullToAbsent || counterpartyBefore != null) {
      map['counterparty_before'] = Variable<String>(counterpartyBefore);
    }
    if (!nullToAbsent || counterpartyAfter != null) {
      map['counterparty_after'] = Variable<String>(counterpartyAfter);
    }
    map['direction'] = Variable<int>(direction);
    map['example_body'] = Variable<String>(exampleBody);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || lastMatchedAt != null) {
      map['last_matched_at'] = Variable<int>(lastMatchedAt);
    }
    map['total_attempts'] = Variable<int>(totalAttempts);
    map['successful_matches'] = Variable<int>(successfulMatches);
    return map;
  }

  SmsPatternsCompanion toCompanion(bool nullToAbsent) {
    return SmsPatternsCompanion(
      id: Value(id),
      senderId: Value(senderId),
      amountBefore: amountBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(amountBefore),
      amountAfter: amountAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(amountAfter),
      balanceBefore: balanceBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceBefore),
      balanceAfter: balanceAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceAfter),
      counterpartyBefore: counterpartyBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(counterpartyBefore),
      counterpartyAfter: counterpartyAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(counterpartyAfter),
      direction: Value(direction),
      exampleBody: Value(exampleBody),
      createdAt: Value(createdAt),
      lastMatchedAt: lastMatchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMatchedAt),
      totalAttempts: Value(totalAttempts),
      successfulMatches: Value(successfulMatches),
    );
  }

  factory SmsPatternRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmsPatternRow(
      id: serializer.fromJson<String>(json['id']),
      senderId: serializer.fromJson<String>(json['senderId']),
      amountBefore: serializer.fromJson<String?>(json['amountBefore']),
      amountAfter: serializer.fromJson<String?>(json['amountAfter']),
      balanceBefore: serializer.fromJson<String?>(json['balanceBefore']),
      balanceAfter: serializer.fromJson<String?>(json['balanceAfter']),
      counterpartyBefore: serializer.fromJson<String?>(
        json['counterpartyBefore'],
      ),
      counterpartyAfter: serializer.fromJson<String?>(
        json['counterpartyAfter'],
      ),
      direction: serializer.fromJson<int>(json['direction']),
      exampleBody: serializer.fromJson<String>(json['exampleBody']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastMatchedAt: serializer.fromJson<int?>(json['lastMatchedAt']),
      totalAttempts: serializer.fromJson<int>(json['totalAttempts']),
      successfulMatches: serializer.fromJson<int>(json['successfulMatches']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'senderId': serializer.toJson<String>(senderId),
      'amountBefore': serializer.toJson<String?>(amountBefore),
      'amountAfter': serializer.toJson<String?>(amountAfter),
      'balanceBefore': serializer.toJson<String?>(balanceBefore),
      'balanceAfter': serializer.toJson<String?>(balanceAfter),
      'counterpartyBefore': serializer.toJson<String?>(counterpartyBefore),
      'counterpartyAfter': serializer.toJson<String?>(counterpartyAfter),
      'direction': serializer.toJson<int>(direction),
      'exampleBody': serializer.toJson<String>(exampleBody),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastMatchedAt': serializer.toJson<int?>(lastMatchedAt),
      'totalAttempts': serializer.toJson<int>(totalAttempts),
      'successfulMatches': serializer.toJson<int>(successfulMatches),
    };
  }

  SmsPatternRow copyWith({
    String? id,
    String? senderId,
    Value<String?> amountBefore = const Value.absent(),
    Value<String?> amountAfter = const Value.absent(),
    Value<String?> balanceBefore = const Value.absent(),
    Value<String?> balanceAfter = const Value.absent(),
    Value<String?> counterpartyBefore = const Value.absent(),
    Value<String?> counterpartyAfter = const Value.absent(),
    int? direction,
    String? exampleBody,
    int? createdAt,
    Value<int?> lastMatchedAt = const Value.absent(),
    int? totalAttempts,
    int? successfulMatches,
  }) => SmsPatternRow(
    id: id ?? this.id,
    senderId: senderId ?? this.senderId,
    amountBefore: amountBefore.present ? amountBefore.value : this.amountBefore,
    amountAfter: amountAfter.present ? amountAfter.value : this.amountAfter,
    balanceBefore: balanceBefore.present
        ? balanceBefore.value
        : this.balanceBefore,
    balanceAfter: balanceAfter.present ? balanceAfter.value : this.balanceAfter,
    counterpartyBefore: counterpartyBefore.present
        ? counterpartyBefore.value
        : this.counterpartyBefore,
    counterpartyAfter: counterpartyAfter.present
        ? counterpartyAfter.value
        : this.counterpartyAfter,
    direction: direction ?? this.direction,
    exampleBody: exampleBody ?? this.exampleBody,
    createdAt: createdAt ?? this.createdAt,
    lastMatchedAt: lastMatchedAt.present
        ? lastMatchedAt.value
        : this.lastMatchedAt,
    totalAttempts: totalAttempts ?? this.totalAttempts,
    successfulMatches: successfulMatches ?? this.successfulMatches,
  );
  SmsPatternRow copyWithCompanion(SmsPatternsCompanion data) {
    return SmsPatternRow(
      id: data.id.present ? data.id.value : this.id,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      amountBefore: data.amountBefore.present
          ? data.amountBefore.value
          : this.amountBefore,
      amountAfter: data.amountAfter.present
          ? data.amountAfter.value
          : this.amountAfter,
      balanceBefore: data.balanceBefore.present
          ? data.balanceBefore.value
          : this.balanceBefore,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      counterpartyBefore: data.counterpartyBefore.present
          ? data.counterpartyBefore.value
          : this.counterpartyBefore,
      counterpartyAfter: data.counterpartyAfter.present
          ? data.counterpartyAfter.value
          : this.counterpartyAfter,
      direction: data.direction.present ? data.direction.value : this.direction,
      exampleBody: data.exampleBody.present
          ? data.exampleBody.value
          : this.exampleBody,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastMatchedAt: data.lastMatchedAt.present
          ? data.lastMatchedAt.value
          : this.lastMatchedAt,
      totalAttempts: data.totalAttempts.present
          ? data.totalAttempts.value
          : this.totalAttempts,
      successfulMatches: data.successfulMatches.present
          ? data.successfulMatches.value
          : this.successfulMatches,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmsPatternRow(')
          ..write('id: $id, ')
          ..write('senderId: $senderId, ')
          ..write('amountBefore: $amountBefore, ')
          ..write('amountAfter: $amountAfter, ')
          ..write('balanceBefore: $balanceBefore, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('counterpartyBefore: $counterpartyBefore, ')
          ..write('counterpartyAfter: $counterpartyAfter, ')
          ..write('direction: $direction, ')
          ..write('exampleBody: $exampleBody, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastMatchedAt: $lastMatchedAt, ')
          ..write('totalAttempts: $totalAttempts, ')
          ..write('successfulMatches: $successfulMatches')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    senderId,
    amountBefore,
    amountAfter,
    balanceBefore,
    balanceAfter,
    counterpartyBefore,
    counterpartyAfter,
    direction,
    exampleBody,
    createdAt,
    lastMatchedAt,
    totalAttempts,
    successfulMatches,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmsPatternRow &&
          other.id == this.id &&
          other.senderId == this.senderId &&
          other.amountBefore == this.amountBefore &&
          other.amountAfter == this.amountAfter &&
          other.balanceBefore == this.balanceBefore &&
          other.balanceAfter == this.balanceAfter &&
          other.counterpartyBefore == this.counterpartyBefore &&
          other.counterpartyAfter == this.counterpartyAfter &&
          other.direction == this.direction &&
          other.exampleBody == this.exampleBody &&
          other.createdAt == this.createdAt &&
          other.lastMatchedAt == this.lastMatchedAt &&
          other.totalAttempts == this.totalAttempts &&
          other.successfulMatches == this.successfulMatches);
}

class SmsPatternsCompanion extends UpdateCompanion<SmsPatternRow> {
  final Value<String> id;
  final Value<String> senderId;
  final Value<String?> amountBefore;
  final Value<String?> amountAfter;
  final Value<String?> balanceBefore;
  final Value<String?> balanceAfter;
  final Value<String?> counterpartyBefore;
  final Value<String?> counterpartyAfter;
  final Value<int> direction;
  final Value<String> exampleBody;
  final Value<int> createdAt;
  final Value<int?> lastMatchedAt;
  final Value<int> totalAttempts;
  final Value<int> successfulMatches;
  final Value<int> rowid;
  const SmsPatternsCompanion({
    this.id = const Value.absent(),
    this.senderId = const Value.absent(),
    this.amountBefore = const Value.absent(),
    this.amountAfter = const Value.absent(),
    this.balanceBefore = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.counterpartyBefore = const Value.absent(),
    this.counterpartyAfter = const Value.absent(),
    this.direction = const Value.absent(),
    this.exampleBody = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastMatchedAt = const Value.absent(),
    this.totalAttempts = const Value.absent(),
    this.successfulMatches = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SmsPatternsCompanion.insert({
    required String id,
    required String senderId,
    this.amountBefore = const Value.absent(),
    this.amountAfter = const Value.absent(),
    this.balanceBefore = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.counterpartyBefore = const Value.absent(),
    this.counterpartyAfter = const Value.absent(),
    required int direction,
    required String exampleBody,
    required int createdAt,
    this.lastMatchedAt = const Value.absent(),
    this.totalAttempts = const Value.absent(),
    this.successfulMatches = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       senderId = Value(senderId),
       direction = Value(direction),
       exampleBody = Value(exampleBody),
       createdAt = Value(createdAt);
  static Insertable<SmsPatternRow> custom({
    Expression<String>? id,
    Expression<String>? senderId,
    Expression<String>? amountBefore,
    Expression<String>? amountAfter,
    Expression<String>? balanceBefore,
    Expression<String>? balanceAfter,
    Expression<String>? counterpartyBefore,
    Expression<String>? counterpartyAfter,
    Expression<int>? direction,
    Expression<String>? exampleBody,
    Expression<int>? createdAt,
    Expression<int>? lastMatchedAt,
    Expression<int>? totalAttempts,
    Expression<int>? successfulMatches,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (senderId != null) 'sender_id': senderId,
      if (amountBefore != null) 'amount_before': amountBefore,
      if (amountAfter != null) 'amount_after': amountAfter,
      if (balanceBefore != null) 'balance_before': balanceBefore,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (counterpartyBefore != null) 'counterparty_before': counterpartyBefore,
      if (counterpartyAfter != null) 'counterparty_after': counterpartyAfter,
      if (direction != null) 'direction': direction,
      if (exampleBody != null) 'example_body': exampleBody,
      if (createdAt != null) 'created_at': createdAt,
      if (lastMatchedAt != null) 'last_matched_at': lastMatchedAt,
      if (totalAttempts != null) 'total_attempts': totalAttempts,
      if (successfulMatches != null) 'successful_matches': successfulMatches,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SmsPatternsCompanion copyWith({
    Value<String>? id,
    Value<String>? senderId,
    Value<String?>? amountBefore,
    Value<String?>? amountAfter,
    Value<String?>? balanceBefore,
    Value<String?>? balanceAfter,
    Value<String?>? counterpartyBefore,
    Value<String?>? counterpartyAfter,
    Value<int>? direction,
    Value<String>? exampleBody,
    Value<int>? createdAt,
    Value<int?>? lastMatchedAt,
    Value<int>? totalAttempts,
    Value<int>? successfulMatches,
    Value<int>? rowid,
  }) {
    return SmsPatternsCompanion(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      amountBefore: amountBefore ?? this.amountBefore,
      amountAfter: amountAfter ?? this.amountAfter,
      balanceBefore: balanceBefore ?? this.balanceBefore,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      counterpartyBefore: counterpartyBefore ?? this.counterpartyBefore,
      counterpartyAfter: counterpartyAfter ?? this.counterpartyAfter,
      direction: direction ?? this.direction,
      exampleBody: exampleBody ?? this.exampleBody,
      createdAt: createdAt ?? this.createdAt,
      lastMatchedAt: lastMatchedAt ?? this.lastMatchedAt,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      successfulMatches: successfulMatches ?? this.successfulMatches,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (amountBefore.present) {
      map['amount_before'] = Variable<String>(amountBefore.value);
    }
    if (amountAfter.present) {
      map['amount_after'] = Variable<String>(amountAfter.value);
    }
    if (balanceBefore.present) {
      map['balance_before'] = Variable<String>(balanceBefore.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<String>(balanceAfter.value);
    }
    if (counterpartyBefore.present) {
      map['counterparty_before'] = Variable<String>(counterpartyBefore.value);
    }
    if (counterpartyAfter.present) {
      map['counterparty_after'] = Variable<String>(counterpartyAfter.value);
    }
    if (direction.present) {
      map['direction'] = Variable<int>(direction.value);
    }
    if (exampleBody.present) {
      map['example_body'] = Variable<String>(exampleBody.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastMatchedAt.present) {
      map['last_matched_at'] = Variable<int>(lastMatchedAt.value);
    }
    if (totalAttempts.present) {
      map['total_attempts'] = Variable<int>(totalAttempts.value);
    }
    if (successfulMatches.present) {
      map['successful_matches'] = Variable<int>(successfulMatches.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmsPatternsCompanion(')
          ..write('id: $id, ')
          ..write('senderId: $senderId, ')
          ..write('amountBefore: $amountBefore, ')
          ..write('amountAfter: $amountAfter, ')
          ..write('balanceBefore: $balanceBefore, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('counterpartyBefore: $counterpartyBefore, ')
          ..write('counterpartyAfter: $counterpartyAfter, ')
          ..write('direction: $direction, ')
          ..write('exampleBody: $exampleBody, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastMatchedAt: $lastMatchedAt, ')
          ..write('totalAttempts: $totalAttempts, ')
          ..write('successfulMatches: $successfulMatches, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatternMatchesTable extends PatternMatches
    with TableInfo<$PatternMatchesTable, PatternMatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatternMatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _smsIdMeta = const VerificationMeta('smsId');
  @override
  late final GeneratedColumn<String> smsId = GeneratedColumn<String>(
    'sms_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternIdMeta = const VerificationMeta(
    'patternId',
  );
  @override
  late final GeneratedColumn<String> patternId = GeneratedColumn<String>(
    'pattern_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _counterpartyMeta = const VerificationMeta(
    'counterparty',
  );
  @override
  late final GeneratedColumn<String> counterparty = GeneratedColumn<String>(
    'counterparty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<int> direction = GeneratedColumn<int>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<int> receivedAt = GeneratedColumn<int>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchedAtMeta = const VerificationMeta(
    'matchedAt',
  );
  @override
  late final GeneratedColumn<int> matchedAt = GeneratedColumn<int>(
    'matched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    smsId,
    patternId,
    senderId,
    amount,
    balance,
    counterparty,
    direction,
    receivedAt,
    matchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pattern_matches';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatternMatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sms_id')) {
      context.handle(
        _smsIdMeta,
        smsId.isAcceptableOrUnknown(data['sms_id']!, _smsIdMeta),
      );
    } else if (isInserting) {
      context.missing(_smsIdMeta);
    }
    if (data.containsKey('pattern_id')) {
      context.handle(
        _patternIdMeta,
        patternId.isAcceptableOrUnknown(data['pattern_id']!, _patternIdMeta),
      );
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('counterparty')) {
      context.handle(
        _counterpartyMeta,
        counterparty.isAcceptableOrUnknown(
          data['counterparty']!,
          _counterpartyMeta,
        ),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('matched_at')) {
      context.handle(
        _matchedAtMeta,
        matchedAt.isAcceptableOrUnknown(data['matched_at']!, _matchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_matchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {smsId};
  @override
  PatternMatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatternMatchRow(
      smsId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sms_id'],
      )!,
      patternId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern_id'],
      ),
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      ),
      counterparty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty'],
      ),
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}direction'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_at'],
      )!,
      matchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}matched_at'],
      )!,
    );
  }

  @override
  $PatternMatchesTable createAlias(String alias) {
    return $PatternMatchesTable(attachedDatabase, alias);
  }
}

class PatternMatchRow extends DataClass implements Insertable<PatternMatchRow> {
  final String smsId;
  final String? patternId;
  final String senderId;
  final double? amount;
  final double? balance;
  final String? counterparty;
  final int direction;
  final int receivedAt;
  final int matchedAt;
  const PatternMatchRow({
    required this.smsId,
    this.patternId,
    required this.senderId,
    this.amount,
    this.balance,
    this.counterparty,
    required this.direction,
    required this.receivedAt,
    required this.matchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sms_id'] = Variable<String>(smsId);
    if (!nullToAbsent || patternId != null) {
      map['pattern_id'] = Variable<String>(patternId);
    }
    map['sender_id'] = Variable<String>(senderId);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || balance != null) {
      map['balance'] = Variable<double>(balance);
    }
    if (!nullToAbsent || counterparty != null) {
      map['counterparty'] = Variable<String>(counterparty);
    }
    map['direction'] = Variable<int>(direction);
    map['received_at'] = Variable<int>(receivedAt);
    map['matched_at'] = Variable<int>(matchedAt);
    return map;
  }

  PatternMatchesCompanion toCompanion(bool nullToAbsent) {
    return PatternMatchesCompanion(
      smsId: Value(smsId),
      patternId: patternId == null && nullToAbsent
          ? const Value.absent()
          : Value(patternId),
      senderId: Value(senderId),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      balance: balance == null && nullToAbsent
          ? const Value.absent()
          : Value(balance),
      counterparty: counterparty == null && nullToAbsent
          ? const Value.absent()
          : Value(counterparty),
      direction: Value(direction),
      receivedAt: Value(receivedAt),
      matchedAt: Value(matchedAt),
    );
  }

  factory PatternMatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatternMatchRow(
      smsId: serializer.fromJson<String>(json['smsId']),
      patternId: serializer.fromJson<String?>(json['patternId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      amount: serializer.fromJson<double?>(json['amount']),
      balance: serializer.fromJson<double?>(json['balance']),
      counterparty: serializer.fromJson<String?>(json['counterparty']),
      direction: serializer.fromJson<int>(json['direction']),
      receivedAt: serializer.fromJson<int>(json['receivedAt']),
      matchedAt: serializer.fromJson<int>(json['matchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'smsId': serializer.toJson<String>(smsId),
      'patternId': serializer.toJson<String?>(patternId),
      'senderId': serializer.toJson<String>(senderId),
      'amount': serializer.toJson<double?>(amount),
      'balance': serializer.toJson<double?>(balance),
      'counterparty': serializer.toJson<String?>(counterparty),
      'direction': serializer.toJson<int>(direction),
      'receivedAt': serializer.toJson<int>(receivedAt),
      'matchedAt': serializer.toJson<int>(matchedAt),
    };
  }

  PatternMatchRow copyWith({
    String? smsId,
    Value<String?> patternId = const Value.absent(),
    String? senderId,
    Value<double?> amount = const Value.absent(),
    Value<double?> balance = const Value.absent(),
    Value<String?> counterparty = const Value.absent(),
    int? direction,
    int? receivedAt,
    int? matchedAt,
  }) => PatternMatchRow(
    smsId: smsId ?? this.smsId,
    patternId: patternId.present ? patternId.value : this.patternId,
    senderId: senderId ?? this.senderId,
    amount: amount.present ? amount.value : this.amount,
    balance: balance.present ? balance.value : this.balance,
    counterparty: counterparty.present ? counterparty.value : this.counterparty,
    direction: direction ?? this.direction,
    receivedAt: receivedAt ?? this.receivedAt,
    matchedAt: matchedAt ?? this.matchedAt,
  );
  PatternMatchRow copyWithCompanion(PatternMatchesCompanion data) {
    return PatternMatchRow(
      smsId: data.smsId.present ? data.smsId.value : this.smsId,
      patternId: data.patternId.present ? data.patternId.value : this.patternId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      amount: data.amount.present ? data.amount.value : this.amount,
      balance: data.balance.present ? data.balance.value : this.balance,
      counterparty: data.counterparty.present
          ? data.counterparty.value
          : this.counterparty,
      direction: data.direction.present ? data.direction.value : this.direction,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      matchedAt: data.matchedAt.present ? data.matchedAt.value : this.matchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatternMatchRow(')
          ..write('smsId: $smsId, ')
          ..write('patternId: $patternId, ')
          ..write('senderId: $senderId, ')
          ..write('amount: $amount, ')
          ..write('balance: $balance, ')
          ..write('counterparty: $counterparty, ')
          ..write('direction: $direction, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('matchedAt: $matchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    smsId,
    patternId,
    senderId,
    amount,
    balance,
    counterparty,
    direction,
    receivedAt,
    matchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatternMatchRow &&
          other.smsId == this.smsId &&
          other.patternId == this.patternId &&
          other.senderId == this.senderId &&
          other.amount == this.amount &&
          other.balance == this.balance &&
          other.counterparty == this.counterparty &&
          other.direction == this.direction &&
          other.receivedAt == this.receivedAt &&
          other.matchedAt == this.matchedAt);
}

class PatternMatchesCompanion extends UpdateCompanion<PatternMatchRow> {
  final Value<String> smsId;
  final Value<String?> patternId;
  final Value<String> senderId;
  final Value<double?> amount;
  final Value<double?> balance;
  final Value<String?> counterparty;
  final Value<int> direction;
  final Value<int> receivedAt;
  final Value<int> matchedAt;
  final Value<int> rowid;
  const PatternMatchesCompanion({
    this.smsId = const Value.absent(),
    this.patternId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.amount = const Value.absent(),
    this.balance = const Value.absent(),
    this.counterparty = const Value.absent(),
    this.direction = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.matchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatternMatchesCompanion.insert({
    required String smsId,
    this.patternId = const Value.absent(),
    required String senderId,
    this.amount = const Value.absent(),
    this.balance = const Value.absent(),
    this.counterparty = const Value.absent(),
    required int direction,
    required int receivedAt,
    required int matchedAt,
    this.rowid = const Value.absent(),
  }) : smsId = Value(smsId),
       senderId = Value(senderId),
       direction = Value(direction),
       receivedAt = Value(receivedAt),
       matchedAt = Value(matchedAt);
  static Insertable<PatternMatchRow> custom({
    Expression<String>? smsId,
    Expression<String>? patternId,
    Expression<String>? senderId,
    Expression<double>? amount,
    Expression<double>? balance,
    Expression<String>? counterparty,
    Expression<int>? direction,
    Expression<int>? receivedAt,
    Expression<int>? matchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (smsId != null) 'sms_id': smsId,
      if (patternId != null) 'pattern_id': patternId,
      if (senderId != null) 'sender_id': senderId,
      if (amount != null) 'amount': amount,
      if (balance != null) 'balance': balance,
      if (counterparty != null) 'counterparty': counterparty,
      if (direction != null) 'direction': direction,
      if (receivedAt != null) 'received_at': receivedAt,
      if (matchedAt != null) 'matched_at': matchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatternMatchesCompanion copyWith({
    Value<String>? smsId,
    Value<String?>? patternId,
    Value<String>? senderId,
    Value<double?>? amount,
    Value<double?>? balance,
    Value<String?>? counterparty,
    Value<int>? direction,
    Value<int>? receivedAt,
    Value<int>? matchedAt,
    Value<int>? rowid,
  }) {
    return PatternMatchesCompanion(
      smsId: smsId ?? this.smsId,
      patternId: patternId ?? this.patternId,
      senderId: senderId ?? this.senderId,
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
      counterparty: counterparty ?? this.counterparty,
      direction: direction ?? this.direction,
      receivedAt: receivedAt ?? this.receivedAt,
      matchedAt: matchedAt ?? this.matchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (smsId.present) {
      map['sms_id'] = Variable<String>(smsId.value);
    }
    if (patternId.present) {
      map['pattern_id'] = Variable<String>(patternId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (counterparty.present) {
      map['counterparty'] = Variable<String>(counterparty.value);
    }
    if (direction.present) {
      map['direction'] = Variable<int>(direction.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<int>(receivedAt.value);
    }
    if (matchedAt.present) {
      map['matched_at'] = Variable<int>(matchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatternMatchesCompanion(')
          ..write('smsId: $smsId, ')
          ..write('patternId: $patternId, ')
          ..write('senderId: $senderId, ')
          ..write('amount: $amount, ')
          ..write('balance: $balance, ')
          ..write('counterparty: $counterparty, ')
          ..write('direction: $direction, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('matchedAt: $matchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnmatchedSmsRecordsTable extends UnmatchedSmsRecords
    with TableInfo<$UnmatchedSmsRecordsTable, UnmatchedSmsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnmatchedSmsRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _smsIdMeta = const VerificationMeta('smsId');
  @override
  late final GeneratedColumn<String> smsId = GeneratedColumn<String>(
    'sms_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<int> receivedAt = GeneratedColumn<int>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dismissedMeta = const VerificationMeta(
    'dismissed',
  );
  @override
  late final GeneratedColumn<bool> dismissed = GeneratedColumn<bool>(
    'dismissed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dismissed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    smsId,
    senderId,
    receivedAt,
    dismissed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unmatched_sms_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnmatchedSmsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sms_id')) {
      context.handle(
        _smsIdMeta,
        smsId.isAcceptableOrUnknown(data['sms_id']!, _smsIdMeta),
      );
    } else if (isInserting) {
      context.missing(_smsIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('dismissed')) {
      context.handle(
        _dismissedMeta,
        dismissed.isAcceptableOrUnknown(data['dismissed']!, _dismissedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {smsId};
  @override
  UnmatchedSmsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnmatchedSmsRow(
      smsId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sms_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_at'],
      )!,
      dismissed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dismissed'],
      )!,
    );
  }

  @override
  $UnmatchedSmsRecordsTable createAlias(String alias) {
    return $UnmatchedSmsRecordsTable(attachedDatabase, alias);
  }
}

class UnmatchedSmsRow extends DataClass implements Insertable<UnmatchedSmsRow> {
  final String smsId;
  final String senderId;
  final int receivedAt;
  final bool dismissed;
  const UnmatchedSmsRow({
    required this.smsId,
    required this.senderId,
    required this.receivedAt,
    required this.dismissed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sms_id'] = Variable<String>(smsId);
    map['sender_id'] = Variable<String>(senderId);
    map['received_at'] = Variable<int>(receivedAt);
    map['dismissed'] = Variable<bool>(dismissed);
    return map;
  }

  UnmatchedSmsRecordsCompanion toCompanion(bool nullToAbsent) {
    return UnmatchedSmsRecordsCompanion(
      smsId: Value(smsId),
      senderId: Value(senderId),
      receivedAt: Value(receivedAt),
      dismissed: Value(dismissed),
    );
  }

  factory UnmatchedSmsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnmatchedSmsRow(
      smsId: serializer.fromJson<String>(json['smsId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      receivedAt: serializer.fromJson<int>(json['receivedAt']),
      dismissed: serializer.fromJson<bool>(json['dismissed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'smsId': serializer.toJson<String>(smsId),
      'senderId': serializer.toJson<String>(senderId),
      'receivedAt': serializer.toJson<int>(receivedAt),
      'dismissed': serializer.toJson<bool>(dismissed),
    };
  }

  UnmatchedSmsRow copyWith({
    String? smsId,
    String? senderId,
    int? receivedAt,
    bool? dismissed,
  }) => UnmatchedSmsRow(
    smsId: smsId ?? this.smsId,
    senderId: senderId ?? this.senderId,
    receivedAt: receivedAt ?? this.receivedAt,
    dismissed: dismissed ?? this.dismissed,
  );
  UnmatchedSmsRow copyWithCompanion(UnmatchedSmsRecordsCompanion data) {
    return UnmatchedSmsRow(
      smsId: data.smsId.present ? data.smsId.value : this.smsId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      dismissed: data.dismissed.present ? data.dismissed.value : this.dismissed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnmatchedSmsRow(')
          ..write('smsId: $smsId, ')
          ..write('senderId: $senderId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('dismissed: $dismissed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(smsId, senderId, receivedAt, dismissed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnmatchedSmsRow &&
          other.smsId == this.smsId &&
          other.senderId == this.senderId &&
          other.receivedAt == this.receivedAt &&
          other.dismissed == this.dismissed);
}

class UnmatchedSmsRecordsCompanion extends UpdateCompanion<UnmatchedSmsRow> {
  final Value<String> smsId;
  final Value<String> senderId;
  final Value<int> receivedAt;
  final Value<bool> dismissed;
  final Value<int> rowid;
  const UnmatchedSmsRecordsCompanion({
    this.smsId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.dismissed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnmatchedSmsRecordsCompanion.insert({
    required String smsId,
    required String senderId,
    required int receivedAt,
    this.dismissed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : smsId = Value(smsId),
       senderId = Value(senderId),
       receivedAt = Value(receivedAt);
  static Insertable<UnmatchedSmsRow> custom({
    Expression<String>? smsId,
    Expression<String>? senderId,
    Expression<int>? receivedAt,
    Expression<bool>? dismissed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (smsId != null) 'sms_id': smsId,
      if (senderId != null) 'sender_id': senderId,
      if (receivedAt != null) 'received_at': receivedAt,
      if (dismissed != null) 'dismissed': dismissed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnmatchedSmsRecordsCompanion copyWith({
    Value<String>? smsId,
    Value<String>? senderId,
    Value<int>? receivedAt,
    Value<bool>? dismissed,
    Value<int>? rowid,
  }) {
    return UnmatchedSmsRecordsCompanion(
      smsId: smsId ?? this.smsId,
      senderId: senderId ?? this.senderId,
      receivedAt: receivedAt ?? this.receivedAt,
      dismissed: dismissed ?? this.dismissed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (smsId.present) {
      map['sms_id'] = Variable<String>(smsId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<int>(receivedAt.value);
    }
    if (dismissed.present) {
      map['dismissed'] = Variable<bool>(dismissed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnmatchedSmsRecordsCompanion(')
          ..write('smsId: $smsId, ')
          ..write('senderId: $senderId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('dismissed: $dismissed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppressedSendersTable extends SuppressedSenders
    with TableInfo<$SuppressedSendersTable, SuppressedSenderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppressedSendersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suppressedAtMeta = const VerificationMeta(
    'suppressedAt',
  );
  @override
  late final GeneratedColumn<int> suppressedAt = GeneratedColumn<int>(
    'suppressed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [senderId, suppressedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppressed_senders';
  @override
  VerificationContext validateIntegrity(
    Insertable<SuppressedSenderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('suppressed_at')) {
      context.handle(
        _suppressedAtMeta,
        suppressedAt.isAcceptableOrUnknown(
          data['suppressed_at']!,
          _suppressedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_suppressedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {senderId};
  @override
  SuppressedSenderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SuppressedSenderRow(
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      suppressedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}suppressed_at'],
      )!,
    );
  }

  @override
  $SuppressedSendersTable createAlias(String alias) {
    return $SuppressedSendersTable(attachedDatabase, alias);
  }
}

class SuppressedSenderRow extends DataClass
    implements Insertable<SuppressedSenderRow> {
  final String senderId;
  final int suppressedAt;
  const SuppressedSenderRow({
    required this.senderId,
    required this.suppressedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sender_id'] = Variable<String>(senderId);
    map['suppressed_at'] = Variable<int>(suppressedAt);
    return map;
  }

  SuppressedSendersCompanion toCompanion(bool nullToAbsent) {
    return SuppressedSendersCompanion(
      senderId: Value(senderId),
      suppressedAt: Value(suppressedAt),
    );
  }

  factory SuppressedSenderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SuppressedSenderRow(
      senderId: serializer.fromJson<String>(json['senderId']),
      suppressedAt: serializer.fromJson<int>(json['suppressedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'senderId': serializer.toJson<String>(senderId),
      'suppressedAt': serializer.toJson<int>(suppressedAt),
    };
  }

  SuppressedSenderRow copyWith({String? senderId, int? suppressedAt}) =>
      SuppressedSenderRow(
        senderId: senderId ?? this.senderId,
        suppressedAt: suppressedAt ?? this.suppressedAt,
      );
  SuppressedSenderRow copyWithCompanion(SuppressedSendersCompanion data) {
    return SuppressedSenderRow(
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      suppressedAt: data.suppressedAt.present
          ? data.suppressedAt.value
          : this.suppressedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SuppressedSenderRow(')
          ..write('senderId: $senderId, ')
          ..write('suppressedAt: $suppressedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(senderId, suppressedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SuppressedSenderRow &&
          other.senderId == this.senderId &&
          other.suppressedAt == this.suppressedAt);
}

class SuppressedSendersCompanion extends UpdateCompanion<SuppressedSenderRow> {
  final Value<String> senderId;
  final Value<int> suppressedAt;
  final Value<int> rowid;
  const SuppressedSendersCompanion({
    this.senderId = const Value.absent(),
    this.suppressedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppressedSendersCompanion.insert({
    required String senderId,
    required int suppressedAt,
    this.rowid = const Value.absent(),
  }) : senderId = Value(senderId),
       suppressedAt = Value(suppressedAt);
  static Insertable<SuppressedSenderRow> custom({
    Expression<String>? senderId,
    Expression<int>? suppressedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (senderId != null) 'sender_id': senderId,
      if (suppressedAt != null) 'suppressed_at': suppressedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppressedSendersCompanion copyWith({
    Value<String>? senderId,
    Value<int>? suppressedAt,
    Value<int>? rowid,
  }) {
    return SuppressedSendersCompanion(
      senderId: senderId ?? this.senderId,
      suppressedAt: suppressedAt ?? this.suppressedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (suppressedAt.present) {
      map['suppressed_at'] = Variable<int>(suppressedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppressedSendersCompanion(')
          ..write('senderId: $senderId, ')
          ..write('suppressedAt: $suppressedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PoolContributionsTable poolContributions =
      $PoolContributionsTable(this);
  late final $PayoutStatesTable payoutStates = $PayoutStatesTable(this);
  late final $SalaryMarksTable salaryMarks = $SalaryMarksTable(this);
  late final $SmsPatternsTable smsPatterns = $SmsPatternsTable(this);
  late final $PatternMatchesTable patternMatches = $PatternMatchesTable(this);
  late final $UnmatchedSmsRecordsTable unmatchedSmsRecords =
      $UnmatchedSmsRecordsTable(this);
  late final $SuppressedSendersTable suppressedSenders =
      $SuppressedSendersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    poolContributions,
    payoutStates,
    salaryMarks,
    smsPatterns,
    patternMatches,
    unmatchedSmsRecords,
    suppressedSenders,
  ];
}

typedef $$PoolContributionsTableCreateCompanionBuilder =
    PoolContributionsCompanion Function({
      required String id,
      required int date,
      required double amount,
      Value<int> rowid,
    });
typedef $$PoolContributionsTableUpdateCompanionBuilder =
    PoolContributionsCompanion Function({
      Value<String> id,
      Value<int> date,
      Value<double> amount,
      Value<int> rowid,
    });

class $$PoolContributionsTableFilterComposer
    extends Composer<_$AppDatabase, $PoolContributionsTable> {
  $$PoolContributionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PoolContributionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PoolContributionsTable> {
  $$PoolContributionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PoolContributionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PoolContributionsTable> {
  $$PoolContributionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);
}

class $$PoolContributionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PoolContributionsTable,
          PoolContributionRow,
          $$PoolContributionsTableFilterComposer,
          $$PoolContributionsTableOrderingComposer,
          $$PoolContributionsTableAnnotationComposer,
          $$PoolContributionsTableCreateCompanionBuilder,
          $$PoolContributionsTableUpdateCompanionBuilder,
          (
            PoolContributionRow,
            BaseReferences<
              _$AppDatabase,
              $PoolContributionsTable,
              PoolContributionRow
            >,
          ),
          PoolContributionRow,
          PrefetchHooks Function()
        > {
  $$PoolContributionsTableTableManager(
    _$AppDatabase db,
    $PoolContributionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PoolContributionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PoolContributionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PoolContributionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> date = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PoolContributionsCompanion(
                id: id,
                date: date,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int date,
                required double amount,
                Value<int> rowid = const Value.absent(),
              }) => PoolContributionsCompanion.insert(
                id: id,
                date: date,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PoolContributionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PoolContributionsTable,
      PoolContributionRow,
      $$PoolContributionsTableFilterComposer,
      $$PoolContributionsTableOrderingComposer,
      $$PoolContributionsTableAnnotationComposer,
      $$PoolContributionsTableCreateCompanionBuilder,
      $$PoolContributionsTableUpdateCompanionBuilder,
      (
        PoolContributionRow,
        BaseReferences<
          _$AppDatabase,
          $PoolContributionsTable,
          PoolContributionRow
        >,
      ),
      PoolContributionRow,
      PrefetchHooks Function()
    >;
typedef $$PayoutStatesTableCreateCompanionBuilder =
    PayoutStatesCompanion Function({
      Value<int> payoutIndex,
      Value<bool> isReceived,
    });
typedef $$PayoutStatesTableUpdateCompanionBuilder =
    PayoutStatesCompanion Function({
      Value<int> payoutIndex,
      Value<bool> isReceived,
    });

class $$PayoutStatesTableFilterComposer
    extends Composer<_$AppDatabase, $PayoutStatesTable> {
  $$PayoutStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get payoutIndex => $composableBuilder(
    column: $table.payoutIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReceived => $composableBuilder(
    column: $table.isReceived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PayoutStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PayoutStatesTable> {
  $$PayoutStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get payoutIndex => $composableBuilder(
    column: $table.payoutIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReceived => $composableBuilder(
    column: $table.isReceived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PayoutStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayoutStatesTable> {
  $$PayoutStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get payoutIndex => $composableBuilder(
    column: $table.payoutIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isReceived => $composableBuilder(
    column: $table.isReceived,
    builder: (column) => column,
  );
}

class $$PayoutStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayoutStatesTable,
          PayoutStateRow,
          $$PayoutStatesTableFilterComposer,
          $$PayoutStatesTableOrderingComposer,
          $$PayoutStatesTableAnnotationComposer,
          $$PayoutStatesTableCreateCompanionBuilder,
          $$PayoutStatesTableUpdateCompanionBuilder,
          (
            PayoutStateRow,
            BaseReferences<_$AppDatabase, $PayoutStatesTable, PayoutStateRow>,
          ),
          PayoutStateRow,
          PrefetchHooks Function()
        > {
  $$PayoutStatesTableTableManager(_$AppDatabase db, $PayoutStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayoutStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayoutStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayoutStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> payoutIndex = const Value.absent(),
                Value<bool> isReceived = const Value.absent(),
              }) => PayoutStatesCompanion(
                payoutIndex: payoutIndex,
                isReceived: isReceived,
              ),
          createCompanionCallback:
              ({
                Value<int> payoutIndex = const Value.absent(),
                Value<bool> isReceived = const Value.absent(),
              }) => PayoutStatesCompanion.insert(
                payoutIndex: payoutIndex,
                isReceived: isReceived,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PayoutStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayoutStatesTable,
      PayoutStateRow,
      $$PayoutStatesTableFilterComposer,
      $$PayoutStatesTableOrderingComposer,
      $$PayoutStatesTableAnnotationComposer,
      $$PayoutStatesTableCreateCompanionBuilder,
      $$PayoutStatesTableUpdateCompanionBuilder,
      (
        PayoutStateRow,
        BaseReferences<_$AppDatabase, $PayoutStatesTable, PayoutStateRow>,
      ),
      PayoutStateRow,
      PrefetchHooks Function()
    >;
typedef $$SalaryMarksTableCreateCompanionBuilder =
    SalaryMarksCompanion Function({
      required String transactionId,
      Value<int> rowid,
    });
typedef $$SalaryMarksTableUpdateCompanionBuilder =
    SalaryMarksCompanion Function({
      Value<String> transactionId,
      Value<int> rowid,
    });

class $$SalaryMarksTableFilterComposer
    extends Composer<_$AppDatabase, $SalaryMarksTable> {
  $$SalaryMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalaryMarksTableOrderingComposer
    extends Composer<_$AppDatabase, $SalaryMarksTable> {
  $$SalaryMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalaryMarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalaryMarksTable> {
  $$SalaryMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );
}

class $$SalaryMarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalaryMarksTable,
          SalaryMarkRow,
          $$SalaryMarksTableFilterComposer,
          $$SalaryMarksTableOrderingComposer,
          $$SalaryMarksTableAnnotationComposer,
          $$SalaryMarksTableCreateCompanionBuilder,
          $$SalaryMarksTableUpdateCompanionBuilder,
          (
            SalaryMarkRow,
            BaseReferences<_$AppDatabase, $SalaryMarksTable, SalaryMarkRow>,
          ),
          SalaryMarkRow,
          PrefetchHooks Function()
        > {
  $$SalaryMarksTableTableManager(_$AppDatabase db, $SalaryMarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalaryMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalaryMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalaryMarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> transactionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalaryMarksCompanion(
                transactionId: transactionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String transactionId,
                Value<int> rowid = const Value.absent(),
              }) => SalaryMarksCompanion.insert(
                transactionId: transactionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalaryMarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalaryMarksTable,
      SalaryMarkRow,
      $$SalaryMarksTableFilterComposer,
      $$SalaryMarksTableOrderingComposer,
      $$SalaryMarksTableAnnotationComposer,
      $$SalaryMarksTableCreateCompanionBuilder,
      $$SalaryMarksTableUpdateCompanionBuilder,
      (
        SalaryMarkRow,
        BaseReferences<_$AppDatabase, $SalaryMarksTable, SalaryMarkRow>,
      ),
      SalaryMarkRow,
      PrefetchHooks Function()
    >;
typedef $$SmsPatternsTableCreateCompanionBuilder =
    SmsPatternsCompanion Function({
      required String id,
      required String senderId,
      Value<String?> amountBefore,
      Value<String?> amountAfter,
      Value<String?> balanceBefore,
      Value<String?> balanceAfter,
      Value<String?> counterpartyBefore,
      Value<String?> counterpartyAfter,
      required int direction,
      required String exampleBody,
      required int createdAt,
      Value<int?> lastMatchedAt,
      Value<int> totalAttempts,
      Value<int> successfulMatches,
      Value<int> rowid,
    });
typedef $$SmsPatternsTableUpdateCompanionBuilder =
    SmsPatternsCompanion Function({
      Value<String> id,
      Value<String> senderId,
      Value<String?> amountBefore,
      Value<String?> amountAfter,
      Value<String?> balanceBefore,
      Value<String?> balanceAfter,
      Value<String?> counterpartyBefore,
      Value<String?> counterpartyAfter,
      Value<int> direction,
      Value<String> exampleBody,
      Value<int> createdAt,
      Value<int?> lastMatchedAt,
      Value<int> totalAttempts,
      Value<int> successfulMatches,
      Value<int> rowid,
    });

class $$SmsPatternsTableFilterComposer
    extends Composer<_$AppDatabase, $SmsPatternsTable> {
  $$SmsPatternsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountBefore => $composableBuilder(
    column: $table.amountBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountAfter => $composableBuilder(
    column: $table.amountAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get balanceBefore => $composableBuilder(
    column: $table.balanceBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterpartyBefore => $composableBuilder(
    column: $table.counterpartyBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterpartyAfter => $composableBuilder(
    column: $table.counterpartyAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleBody => $composableBuilder(
    column: $table.exampleBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMatchedAt => $composableBuilder(
    column: $table.lastMatchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAttempts => $composableBuilder(
    column: $table.totalAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get successfulMatches => $composableBuilder(
    column: $table.successfulMatches,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SmsPatternsTableOrderingComposer
    extends Composer<_$AppDatabase, $SmsPatternsTable> {
  $$SmsPatternsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountBefore => $composableBuilder(
    column: $table.amountBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountAfter => $composableBuilder(
    column: $table.amountAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get balanceBefore => $composableBuilder(
    column: $table.balanceBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterpartyBefore => $composableBuilder(
    column: $table.counterpartyBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterpartyAfter => $composableBuilder(
    column: $table.counterpartyAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleBody => $composableBuilder(
    column: $table.exampleBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMatchedAt => $composableBuilder(
    column: $table.lastMatchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAttempts => $composableBuilder(
    column: $table.totalAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get successfulMatches => $composableBuilder(
    column: $table.successfulMatches,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SmsPatternsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SmsPatternsTable> {
  $$SmsPatternsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get amountBefore => $composableBuilder(
    column: $table.amountBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amountAfter => $composableBuilder(
    column: $table.amountAfter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get balanceBefore => $composableBuilder(
    column: $table.balanceBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get counterpartyBefore => $composableBuilder(
    column: $table.counterpartyBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get counterpartyAfter => $composableBuilder(
    column: $table.counterpartyAfter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get exampleBody => $composableBuilder(
    column: $table.exampleBody,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastMatchedAt => $composableBuilder(
    column: $table.lastMatchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalAttempts => $composableBuilder(
    column: $table.totalAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get successfulMatches => $composableBuilder(
    column: $table.successfulMatches,
    builder: (column) => column,
  );
}

class $$SmsPatternsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SmsPatternsTable,
          SmsPatternRow,
          $$SmsPatternsTableFilterComposer,
          $$SmsPatternsTableOrderingComposer,
          $$SmsPatternsTableAnnotationComposer,
          $$SmsPatternsTableCreateCompanionBuilder,
          $$SmsPatternsTableUpdateCompanionBuilder,
          (
            SmsPatternRow,
            BaseReferences<_$AppDatabase, $SmsPatternsTable, SmsPatternRow>,
          ),
          SmsPatternRow,
          PrefetchHooks Function()
        > {
  $$SmsPatternsTableTableManager(_$AppDatabase db, $SmsPatternsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmsPatternsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmsPatternsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmsPatternsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String?> amountBefore = const Value.absent(),
                Value<String?> amountAfter = const Value.absent(),
                Value<String?> balanceBefore = const Value.absent(),
                Value<String?> balanceAfter = const Value.absent(),
                Value<String?> counterpartyBefore = const Value.absent(),
                Value<String?> counterpartyAfter = const Value.absent(),
                Value<int> direction = const Value.absent(),
                Value<String> exampleBody = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> lastMatchedAt = const Value.absent(),
                Value<int> totalAttempts = const Value.absent(),
                Value<int> successfulMatches = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SmsPatternsCompanion(
                id: id,
                senderId: senderId,
                amountBefore: amountBefore,
                amountAfter: amountAfter,
                balanceBefore: balanceBefore,
                balanceAfter: balanceAfter,
                counterpartyBefore: counterpartyBefore,
                counterpartyAfter: counterpartyAfter,
                direction: direction,
                exampleBody: exampleBody,
                createdAt: createdAt,
                lastMatchedAt: lastMatchedAt,
                totalAttempts: totalAttempts,
                successfulMatches: successfulMatches,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String senderId,
                Value<String?> amountBefore = const Value.absent(),
                Value<String?> amountAfter = const Value.absent(),
                Value<String?> balanceBefore = const Value.absent(),
                Value<String?> balanceAfter = const Value.absent(),
                Value<String?> counterpartyBefore = const Value.absent(),
                Value<String?> counterpartyAfter = const Value.absent(),
                required int direction,
                required String exampleBody,
                required int createdAt,
                Value<int?> lastMatchedAt = const Value.absent(),
                Value<int> totalAttempts = const Value.absent(),
                Value<int> successfulMatches = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SmsPatternsCompanion.insert(
                id: id,
                senderId: senderId,
                amountBefore: amountBefore,
                amountAfter: amountAfter,
                balanceBefore: balanceBefore,
                balanceAfter: balanceAfter,
                counterpartyBefore: counterpartyBefore,
                counterpartyAfter: counterpartyAfter,
                direction: direction,
                exampleBody: exampleBody,
                createdAt: createdAt,
                lastMatchedAt: lastMatchedAt,
                totalAttempts: totalAttempts,
                successfulMatches: successfulMatches,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SmsPatternsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SmsPatternsTable,
      SmsPatternRow,
      $$SmsPatternsTableFilterComposer,
      $$SmsPatternsTableOrderingComposer,
      $$SmsPatternsTableAnnotationComposer,
      $$SmsPatternsTableCreateCompanionBuilder,
      $$SmsPatternsTableUpdateCompanionBuilder,
      (
        SmsPatternRow,
        BaseReferences<_$AppDatabase, $SmsPatternsTable, SmsPatternRow>,
      ),
      SmsPatternRow,
      PrefetchHooks Function()
    >;
typedef $$PatternMatchesTableCreateCompanionBuilder =
    PatternMatchesCompanion Function({
      required String smsId,
      Value<String?> patternId,
      required String senderId,
      Value<double?> amount,
      Value<double?> balance,
      Value<String?> counterparty,
      required int direction,
      required int receivedAt,
      required int matchedAt,
      Value<int> rowid,
    });
typedef $$PatternMatchesTableUpdateCompanionBuilder =
    PatternMatchesCompanion Function({
      Value<String> smsId,
      Value<String?> patternId,
      Value<String> senderId,
      Value<double?> amount,
      Value<double?> balance,
      Value<String?> counterparty,
      Value<int> direction,
      Value<int> receivedAt,
      Value<int> matchedAt,
      Value<int> rowid,
    });

class $$PatternMatchesTableFilterComposer
    extends Composer<_$AppDatabase, $PatternMatchesTable> {
  $$PatternMatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patternId => $composableBuilder(
    column: $table.patternId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get matchedAt => $composableBuilder(
    column: $table.matchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PatternMatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $PatternMatchesTable> {
  $$PatternMatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patternId => $composableBuilder(
    column: $table.patternId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get matchedAt => $composableBuilder(
    column: $table.matchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatternMatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatternMatchesTable> {
  $$PatternMatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get smsId =>
      $composableBuilder(column: $table.smsId, builder: (column) => column);

  GeneratedColumn<String> get patternId =>
      $composableBuilder(column: $table.patternId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get matchedAt =>
      $composableBuilder(column: $table.matchedAt, builder: (column) => column);
}

class $$PatternMatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatternMatchesTable,
          PatternMatchRow,
          $$PatternMatchesTableFilterComposer,
          $$PatternMatchesTableOrderingComposer,
          $$PatternMatchesTableAnnotationComposer,
          $$PatternMatchesTableCreateCompanionBuilder,
          $$PatternMatchesTableUpdateCompanionBuilder,
          (
            PatternMatchRow,
            BaseReferences<
              _$AppDatabase,
              $PatternMatchesTable,
              PatternMatchRow
            >,
          ),
          PatternMatchRow,
          PrefetchHooks Function()
        > {
  $$PatternMatchesTableTableManager(
    _$AppDatabase db,
    $PatternMatchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatternMatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatternMatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatternMatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> smsId = const Value.absent(),
                Value<String?> patternId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<double?> balance = const Value.absent(),
                Value<String?> counterparty = const Value.absent(),
                Value<int> direction = const Value.absent(),
                Value<int> receivedAt = const Value.absent(),
                Value<int> matchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatternMatchesCompanion(
                smsId: smsId,
                patternId: patternId,
                senderId: senderId,
                amount: amount,
                balance: balance,
                counterparty: counterparty,
                direction: direction,
                receivedAt: receivedAt,
                matchedAt: matchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String smsId,
                Value<String?> patternId = const Value.absent(),
                required String senderId,
                Value<double?> amount = const Value.absent(),
                Value<double?> balance = const Value.absent(),
                Value<String?> counterparty = const Value.absent(),
                required int direction,
                required int receivedAt,
                required int matchedAt,
                Value<int> rowid = const Value.absent(),
              }) => PatternMatchesCompanion.insert(
                smsId: smsId,
                patternId: patternId,
                senderId: senderId,
                amount: amount,
                balance: balance,
                counterparty: counterparty,
                direction: direction,
                receivedAt: receivedAt,
                matchedAt: matchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PatternMatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatternMatchesTable,
      PatternMatchRow,
      $$PatternMatchesTableFilterComposer,
      $$PatternMatchesTableOrderingComposer,
      $$PatternMatchesTableAnnotationComposer,
      $$PatternMatchesTableCreateCompanionBuilder,
      $$PatternMatchesTableUpdateCompanionBuilder,
      (
        PatternMatchRow,
        BaseReferences<_$AppDatabase, $PatternMatchesTable, PatternMatchRow>,
      ),
      PatternMatchRow,
      PrefetchHooks Function()
    >;
typedef $$UnmatchedSmsRecordsTableCreateCompanionBuilder =
    UnmatchedSmsRecordsCompanion Function({
      required String smsId,
      required String senderId,
      required int receivedAt,
      Value<bool> dismissed,
      Value<int> rowid,
    });
typedef $$UnmatchedSmsRecordsTableUpdateCompanionBuilder =
    UnmatchedSmsRecordsCompanion Function({
      Value<String> smsId,
      Value<String> senderId,
      Value<int> receivedAt,
      Value<bool> dismissed,
      Value<int> rowid,
    });

class $$UnmatchedSmsRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $UnmatchedSmsRecordsTable> {
  $$UnmatchedSmsRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dismissed => $composableBuilder(
    column: $table.dismissed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnmatchedSmsRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnmatchedSmsRecordsTable> {
  $$UnmatchedSmsRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dismissed => $composableBuilder(
    column: $table.dismissed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnmatchedSmsRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnmatchedSmsRecordsTable> {
  $$UnmatchedSmsRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get smsId =>
      $composableBuilder(column: $table.smsId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<int> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dismissed =>
      $composableBuilder(column: $table.dismissed, builder: (column) => column);
}

class $$UnmatchedSmsRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnmatchedSmsRecordsTable,
          UnmatchedSmsRow,
          $$UnmatchedSmsRecordsTableFilterComposer,
          $$UnmatchedSmsRecordsTableOrderingComposer,
          $$UnmatchedSmsRecordsTableAnnotationComposer,
          $$UnmatchedSmsRecordsTableCreateCompanionBuilder,
          $$UnmatchedSmsRecordsTableUpdateCompanionBuilder,
          (
            UnmatchedSmsRow,
            BaseReferences<
              _$AppDatabase,
              $UnmatchedSmsRecordsTable,
              UnmatchedSmsRow
            >,
          ),
          UnmatchedSmsRow,
          PrefetchHooks Function()
        > {
  $$UnmatchedSmsRecordsTableTableManager(
    _$AppDatabase db,
    $UnmatchedSmsRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnmatchedSmsRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnmatchedSmsRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UnmatchedSmsRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> smsId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<int> receivedAt = const Value.absent(),
                Value<bool> dismissed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnmatchedSmsRecordsCompanion(
                smsId: smsId,
                senderId: senderId,
                receivedAt: receivedAt,
                dismissed: dismissed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String smsId,
                required String senderId,
                required int receivedAt,
                Value<bool> dismissed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnmatchedSmsRecordsCompanion.insert(
                smsId: smsId,
                senderId: senderId,
                receivedAt: receivedAt,
                dismissed: dismissed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnmatchedSmsRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnmatchedSmsRecordsTable,
      UnmatchedSmsRow,
      $$UnmatchedSmsRecordsTableFilterComposer,
      $$UnmatchedSmsRecordsTableOrderingComposer,
      $$UnmatchedSmsRecordsTableAnnotationComposer,
      $$UnmatchedSmsRecordsTableCreateCompanionBuilder,
      $$UnmatchedSmsRecordsTableUpdateCompanionBuilder,
      (
        UnmatchedSmsRow,
        BaseReferences<
          _$AppDatabase,
          $UnmatchedSmsRecordsTable,
          UnmatchedSmsRow
        >,
      ),
      UnmatchedSmsRow,
      PrefetchHooks Function()
    >;
typedef $$SuppressedSendersTableCreateCompanionBuilder =
    SuppressedSendersCompanion Function({
      required String senderId,
      required int suppressedAt,
      Value<int> rowid,
    });
typedef $$SuppressedSendersTableUpdateCompanionBuilder =
    SuppressedSendersCompanion Function({
      Value<String> senderId,
      Value<int> suppressedAt,
      Value<int> rowid,
    });

class $$SuppressedSendersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppressedSendersTable> {
  $$SuppressedSendersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get suppressedAt => $composableBuilder(
    column: $table.suppressedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuppressedSendersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppressedSendersTable> {
  $$SuppressedSendersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get suppressedAt => $composableBuilder(
    column: $table.suppressedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppressedSendersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppressedSendersTable> {
  $$SuppressedSendersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<int> get suppressedAt => $composableBuilder(
    column: $table.suppressedAt,
    builder: (column) => column,
  );
}

class $$SuppressedSendersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppressedSendersTable,
          SuppressedSenderRow,
          $$SuppressedSendersTableFilterComposer,
          $$SuppressedSendersTableOrderingComposer,
          $$SuppressedSendersTableAnnotationComposer,
          $$SuppressedSendersTableCreateCompanionBuilder,
          $$SuppressedSendersTableUpdateCompanionBuilder,
          (
            SuppressedSenderRow,
            BaseReferences<
              _$AppDatabase,
              $SuppressedSendersTable,
              SuppressedSenderRow
            >,
          ),
          SuppressedSenderRow,
          PrefetchHooks Function()
        > {
  $$SuppressedSendersTableTableManager(
    _$AppDatabase db,
    $SuppressedSendersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppressedSendersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppressedSendersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppressedSendersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> senderId = const Value.absent(),
                Value<int> suppressedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppressedSendersCompanion(
                senderId: senderId,
                suppressedAt: suppressedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String senderId,
                required int suppressedAt,
                Value<int> rowid = const Value.absent(),
              }) => SuppressedSendersCompanion.insert(
                senderId: senderId,
                suppressedAt: suppressedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuppressedSendersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppressedSendersTable,
      SuppressedSenderRow,
      $$SuppressedSendersTableFilterComposer,
      $$SuppressedSendersTableOrderingComposer,
      $$SuppressedSendersTableAnnotationComposer,
      $$SuppressedSendersTableCreateCompanionBuilder,
      $$SuppressedSendersTableUpdateCompanionBuilder,
      (
        SuppressedSenderRow,
        BaseReferences<
          _$AppDatabase,
          $SuppressedSendersTable,
          SuppressedSenderRow
        >,
      ),
      SuppressedSenderRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PoolContributionsTableTableManager get poolContributions =>
      $$PoolContributionsTableTableManager(_db, _db.poolContributions);
  $$PayoutStatesTableTableManager get payoutStates =>
      $$PayoutStatesTableTableManager(_db, _db.payoutStates);
  $$SalaryMarksTableTableManager get salaryMarks =>
      $$SalaryMarksTableTableManager(_db, _db.salaryMarks);
  $$SmsPatternsTableTableManager get smsPatterns =>
      $$SmsPatternsTableTableManager(_db, _db.smsPatterns);
  $$PatternMatchesTableTableManager get patternMatches =>
      $$PatternMatchesTableTableManager(_db, _db.patternMatches);
  $$UnmatchedSmsRecordsTableTableManager get unmatchedSmsRecords =>
      $$UnmatchedSmsRecordsTableTableManager(_db, _db.unmatchedSmsRecords);
  $$SuppressedSendersTableTableManager get suppressedSenders =>
      $$SuppressedSendersTableTableManager(_db, _db.suppressedSenders);
}
