import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/monthly_summary_tile.dart';
import '../widgets/salary_summary_tile.dart';
import '../widgets/currency_text.dart';
import 'salary_cycle_screen.dart';

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
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Dashboard'),
        ),
        const Divider(),
      ],
      child: Consumer<TransactionProvider>(
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
                    const Gap(16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                    ).muted,
                    const Gap(16),
                    PrimaryButton(
                      onPressed: provider.loadTransactions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshTrigger(
            onRefresh: () async {
              await provider.loadTransactions();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Balance',
                            value: CurrencyText(amount: provider.currentBalance, color: Colors.blue),
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
                            value: CurrencyText(amount: provider.totalIncome, color: Colors.green),
                            color: Colors.green,
                            icon: Icons.trending_up,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: StatsCard(
                            title: 'Expense',
                            value: CurrencyText(amount: provider.totalExpense, color: Colors.red),
                            color: Colors.red,
                            icon: Icons.trending_down,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Savings (Pool)',
                            value: CurrencyText(amount: provider.totalSavings, color: Colors.teal),
                            color: Colors.teal,
                            icon: Icons.savings,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text('Monthly Summary').semiBold.large,
                  ),
                  const Gap(12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Tabs(
                      index: _summaryView.index,
                      onChanged: (i) => setState(() => _summaryView = _SummaryView.values[i]),
                      children: const [
                        TabItem(child: Text('Overview')),
                        TabItem(child: Text('Salary')),
                      ],
                    ),
                  ),
                  const Gap(8),
                  if (_summaryView == _SummaryView.overview)
                    ...provider.monthlyBreakdown.entries.map((entry) {
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SalaryCycleScreen(
                              cycleStart: DateTime(year, month),
                              cycleEnd: DateTime(year, month + 1),
                              title: label,
                            ),
                          ),
                        ),
                      );
                    })
                  else
                    ...provider.salaryBasedBreakdown.entries.map((entry) {
                      final v = entry.value;
                      return SalarySummaryTile(
                        salary: v.salary,
                        otherIncome: v.otherIncome,
                        expense: v.expense,
                        savings: v.savings,
                        remaining: v.remaining,
                        cycleStart: v.cycleStart,
                        cycleEnd: v.cycleEnd,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SalaryCycleScreen(
                              cycleStart: v.cycleStart,
                              cycleEnd: v.cycleEnd,
                            ),
                          ),
                        ),
                      );
                    }),
                  const Gap(80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
