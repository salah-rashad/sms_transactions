import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/domain/analytics/monthly_breakdown.dart';
import 'package:sms_transactions/domain/analytics/salary_cycle_breakdown.dart';
import 'package:sms_transactions/features/dashboard/widgets/monthly_summary_tile.dart';
import 'package:sms_transactions/features/dashboard/widgets/salary_summary_tile.dart';
import 'package:sms_transactions/features/dashboard/widgets/stats_card.dart';
import 'package:sms_transactions/features/money_pool/cubit/money_pool_cubit.dart';
import 'package:sms_transactions/features/money_pool/cubit/money_pool_state.dart';
import 'package:sms_transactions/features/transactions/cubit/transaction_cubit.dart';
import 'package:sms_transactions/features/transactions/cubit/transaction_state.dart';
import 'package:sms_transactions/router/app_router.dart';
import 'package:sms_transactions/shared/widgets/currency_text.dart';

enum _SummaryView { overview, salary }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _SummaryView _summaryView = _SummaryView.overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: BlocBuilder<MoneyPoolCubit, MoneyPoolState>(
        builder: (context, poolState) {
          final pool = poolState.moneyPool;
          return BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, txState) {
              if (txState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (txState.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: context.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          txState.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colorScheme.error),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<TransactionCubit>()
                              .loadTransactions(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final totalSavings = pool.totalContributed;
              final totalExpense = txState.rawExpense - totalSavings;
              final monthlyBreakdown = MonthlyBreakdown.compute(
                txState.transactions,
                pool.contributions,
              );
              final salaryBreakdown = SalaryCycleBreakdown.compute(
                txState.transactions,
                pool.contributions,
              );

              return RefreshIndicator(
                onRefresh: () =>
                    context.read<TransactionCubit>().loadTransactions(),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'Balance',
                              value: CurrencyText(
                                amount: txState.currentBalance,
                                color: colors.balance,
                              ),
                              color: colors.balance,
                              icon: Icons.account_balance_wallet,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'Income',
                              value: CurrencyText(
                                amount: txState.totalIncome,
                                color: colors.income,
                              ),
                              color: colors.income,
                              icon: Icons.trending_up,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatsCard(
                              title: 'Expense',
                              value: CurrencyText(
                                amount: totalExpense,
                                color: colors.expense,
                              ),
                              color: colors.expense,
                              icon: Icons.trending_down,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'Savings (Pool)',
                              value: CurrencyText(
                                amount: totalSavings,
                                color: context.colorScheme.primary,
                              ),
                              color: context.colorScheme.primary,
                              icon: Icons.savings,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Monthly Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SegmentedButton<_SummaryView>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: _SummaryView.overview,
                            label: Text('Overview'),
                            icon: Icon(Icons.bar_chart),
                          ),
                          ButtonSegment(
                            value: _SummaryView.salary,
                            label: Text('Salary'),
                            icon: Icon(Icons.payments),
                          ),
                        ],
                        selected: {_summaryView},
                        onSelectionChanged: (s) =>
                            setState(() => _summaryView = s.first),
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_summaryView == _SummaryView.overview)
                      ...monthlyBreakdown.entries.map((entry) {
                        final parts = entry.key.split('-');
                        final year = int.parse(parts[0]);
                        final month = int.parse(parts[1]);
                        final date = DateTime(year, month);
                        final label = DateFormat.yMMMM().format(date);
                        return MonthlySummaryTile(
                          monthLabel: label,
                          income: entry.value.income,
                          expense: entry.value.expense,
                          savings: entry.value.savings,
                          onTap: () => context.push(
                            AppRouter.transactionsRangePath(
                              start: DateTime(year, month),
                              end: DateTime(year, month + 1),
                              label: label,
                            ),
                          ),
                        );
                      })
                    else
                      ...salaryBreakdown.entries.map((entry) {
                        final v = entry.value;
                        return SalarySummaryTile(
                          salary: v.salary,
                          otherIncome: v.otherIncome,
                          expense: v.expense,
                          savings: v.savings,
                          remaining: v.remaining,
                          cycleStart: v.cycleStart,
                          cycleEnd: v.cycleEnd,
                          onTap: () => context.push(
                            AppRouter.transactionsRangePath(
                              start: v.cycleStart,
                              end: v.cycleEnd,
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
