import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/money_pool.dart';
import '../theme/app_colors.dart';
import '../widgets/currency_text.dart';
import '../widgets/theme_mode_button.dart';

class MoneyPoolScreen extends StatefulWidget {
  const MoneyPoolScreen({super.key});

  @override
  State<MoneyPoolScreen> createState() => _MoneyPoolScreenState();
}

class _MoneyPoolScreenState extends State<MoneyPoolScreen> {
  bool _isLocked = true;

  void _toggleLock() {
    setState(() => _isLocked = !_isLocked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Pool (جمعية)'),
        actions: [
          const ThemeModeButton(),
          IconButton(
            onPressed: _toggleLock,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                _isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
                key: ValueKey(_isLocked),
              ),
            ),
            tooltip: _isLocked ? 'Unlock to edit' : 'Lock screen',
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final pool = provider.moneyPool;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _buildOverviewCard(context, pool),
                  const SizedBox(height: 16),
                  _buildNextPayoutCard(context, pool),
                  const SizedBox(height: 16),
                  _buildContributionsSection(context, provider, pool),
                  const SizedBox(height: 16),
                  _buildPayoutScheduleSection(context, provider, pool),
                  const SizedBox(height: 80),
                ],
              ),
              if (_isLocked)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildLockedBanner(context),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _isLocked
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddContributionDialog(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildLockedBanner(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.surfaceContainerHighest,
            scheme.surfaceContainerHighest.withValues(alpha: 0.95),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 14,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Screen is locked',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Tap',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.lock_outline,
              size: 12,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'in toolbar to unlock',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, MoneyPool pool) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.groups, size: 28, color: scheme.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pool Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Contributed',
                    CurrencyText(amount: pool.totalContributed, color: colors.contribution, decimals: 0),
                    colors.contribution,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Expected Return',
                    CurrencyText(amount: pool.totalExpectedPayout, color: colors.income, decimals: 0),
                    colors.income,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Received',
                    CurrencyText(amount: pool.totalReceived, color: colors.balance, decimals: 0),
                    colors.balance,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Net Position',
                    CurrencyText(amount: pool.netPosition, color: pool.netPosition >= 0 ? colors.income : colors.expense, decimals: 0),
                    pool.netPosition >= 0 ? colors.income : colors.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, Widget value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        DefaultTextStyle(
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          child: value,
        ),
      ],
    );
  }

  Widget _buildNextPayoutCard(BuildContext context, MoneyPool pool) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final next = pool.nextPayout;
    if (next == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: colors.income),
              const SizedBox(width: 12),
              const Text('All payouts received!'),
            ],
          ),
        ),
      );
    }

    final monthsLeft = pool.monthsUntilNextPayout;

    return Card(
      color: scheme.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.event, color: scheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Payout',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.yMMMMd().format(next.date),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CurrencyText(
                  amount: next.amount,
                  color: scheme.primary,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: scheme.primary,
                  ),
                  decimals: 0,
                ),
                const SizedBox(height: 2),
                Text(
                  monthsLeft == 0
                      ? 'This month!'
                      : '$monthsLeft month${monthsLeft > 1 ? 's' : ''} left',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionsSection(
      BuildContext context, TransactionProvider provider, MoneyPool pool) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Contributions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${pool.contributionCount} entries',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (pool.contributions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  _isLocked
                      ? 'No contributions yet.'
                      : 'No contributions yet.\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          )
        else
          ...pool.contributions.map((c) {
            final child = Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.contribution.withValues(alpha: 0.15),
                  child: Icon(Icons.savings, color: colors.contribution, size: 20),
                ),
                title: Text(DateFormat.yMMMM().format(c.date)),
                trailing: CurrencyText(
                  amount: c.amount,
                  color: colors.contribution,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decimals: 0,
                ),
              ),
            );

            if (_isLocked) return child;

            return Dismissible(
              key: ValueKey(c.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: scheme.error,
                child: Icon(Icons.delete, color: scheme.onError),
              ),
              onDismissed: (_) =>
                  provider.removePoolContribution(c.id),
              child: child,
            );
          }),
      ],
    );
  }

  Widget _buildPayoutScheduleSection(
      BuildContext context, TransactionProvider provider, MoneyPool pool) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final sortedPayouts = pool.payouts
        .asMap()
        .entries
        .toList()
      ..sort((a, b) => a.value.date.compareTo(b.value.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payout Schedule',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...sortedPayouts.map((entry) {
          final index = entry.key;
          final payout = entry.value;
          final isNext = pool.nextPayout == payout;

          return Card(
            margin: const EdgeInsets.only(bottom: 4),
            color: payout.isReceived
                ? colors.income.withValues(alpha: 0.08)
                : isNext
                    ? scheme.primary.withValues(alpha: 0.05)
                    : null,
            child: ListTile(
              leading: Icon(
                payout.isReceived ? Icons.check_circle : Icons.schedule,
                color: payout.isReceived ? colors.income : scheme.onSurfaceVariant,
              ),
              title: Text(DateFormat.yMMMMd().format(payout.date)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CurrencyText(
                    amount: payout.amount,
                    color: payout.isReceived ? colors.income : scheme.onSurface,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: payout.isReceived ? colors.income : null,
                    ),
                    decimals: 0,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        payout.isReceived
                            ? Icons.undo
                            : Icons.check,
                        size: 20,
                      ),
                      color: _isLocked
                          ? scheme.outline
                          : payout.isReceived
                              ? scheme.onSurfaceVariant
                              : colors.income,
                      onPressed: _isLocked
                          ? null
                          : () => provider.togglePayoutReceived(index),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showAddContributionDialog(BuildContext context) {
    final amountController = TextEditingController(text: '10000');
    DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Add Contribution'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (EGP)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(DateFormat.yMMMM().format(selectedDate)),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final picked = await showMonthPicker(
                        context: ctx,
                        initialDate: selectedDate,
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) return;
                    context.read<TransactionProvider>().addPoolContribution(
                          amount,
                          selectedDate,
                        );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<DateTime?> showMonthPicker({
    required BuildContext context,
    required DateTime initialDate,
  }) {
    DateTime tempDate = initialDate;

    return showDialog<DateTime>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Month'),
          content: SizedBox(
            width: 300,
            height: 250,
            child: YearMonthPicker(
              initialDate: initialDate,
              onChanged: (date) => tempDate = date,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, tempDate),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class YearMonthPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onChanged;

  const YearMonthPicker({
    super.key,
    required this.initialDate,
    required this.onChanged,
  });

  @override
  State<YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<YearMonthPicker> {
  late int _selectedYear;
  late int _selectedMonth;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _selectedYear--),
            ),
            Text(
              '$_selectedYear',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _selectedYear++),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 12,
            itemBuilder: (ctx, index) {
              final month = index + 1;
              final isSelected = month == _selectedMonth;
              return InkWell(
                onTap: () {
                  setState(() => _selectedMonth = month);
                  widget.onChanged(DateTime(_selectedYear, month));
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? scheme.primary : null,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? scheme.primary : scheme.outlineVariant,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _months[index],
                      style: TextStyle(
                        color: isSelected ? scheme.onPrimary : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
