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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PoolContributionsTable poolContributions =
      $PoolContributionsTable(this);
  late final $PayoutStatesTable payoutStates = $PayoutStatesTable(this);
  late final $SalaryMarksTable salaryMarks = $SalaryMarksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    poolContributions,
    payoutStates,
    salaryMarks,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PoolContributionsTableTableManager get poolContributions =>
      $$PoolContributionsTableTableManager(_db, _db.poolContributions);
  $$PayoutStatesTableTableManager get payoutStates =>
      $$PayoutStatesTableTableManager(_db, _db.payoutStates);
  $$SalaryMarksTableTableManager get salaryMarks =>
      $$SalaryMarksTableTableManager(_db, _db.salaryMarks);
}
