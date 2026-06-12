import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/monthly_summary_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.loadTransactions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadTransactions,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Balance',
                          value:
                              '${provider.currentBalance.toStringAsFixed(2)} EGP',
                          color: Colors.blue,
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
                          value:
                              '${provider.totalIncome.toStringAsFixed(2)} EGP',
                          color: Colors.green,
                          icon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Expense',
                          value:
                              '${provider.totalExpense.toStringAsFixed(2)} EGP',
                          color: Colors.red,
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
                          value:
                              '${provider.totalSavings.toStringAsFixed(2)} EGP',
                          color: Colors.indigo,
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
                const SizedBox(height: 8),
                    ...provider.monthlyBreakdown.entries.map((entry) {
                  final parts = entry.key.split('-');
                  final date = DateTime(
                      int.parse(parts[0]), int.parse(parts[1]));
                  final label = DateFormat.yMMMM().format(date);
                  return MonthlySummaryTile(
                    monthLabel: label,
                    income: entry.value.income,
                    expense: entry.value.expense,
                    salary: entry.value.salary,
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
