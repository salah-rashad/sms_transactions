import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/money_pool.dart';
import '../widgets/currency_text.dart';

class MoneyPoolScreen extends StatelessWidget {
  const MoneyPoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Money Pool (جمعية)')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final pool = provider.moneyPool;

          return ListView(
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContributionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, MoneyPool pool) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.groups, size: 28, color: Theme.of(context).primaryColor),
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
                    'Contributed',
                    CurrencyText(amount: pool.totalContributed, color: Colors.orange, decimals: 0),
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Expected Return',
                    CurrencyText(amount: pool.totalExpectedPayout, color: Colors.green, decimals: 0),
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Received',
                    CurrencyText(amount: pool.totalReceived, color: Colors.blue, decimals: 0),
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Net Position',
                    CurrencyText(amount: pool.netPosition, color: pool.netPosition >= 0 ? Colors.green : Colors.red, decimals: 0),
                    pool.netPosition >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, Widget value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
    final next = pool.nextPayout;
    if (next == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[400]),
              const SizedBox(width: 12),
              const Text('All payouts received!'),
            ],
          ),
        ),
      );
    }

    final monthsLeft = pool.monthsUntilNextPayout;

    return Card(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.event, color: Theme.of(context).primaryColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Payout',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  color: Theme.of(context).primaryColor,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  decimals: 0,
                ),
                const SizedBox(height: 2),
                Text(
                  monthsLeft == 0
                      ? 'This month!'
                      : '$monthsLeft month${monthsLeft > 1 ? 's' : ''} left',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                  'No contributions yet.\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
          )
        else
          ...pool.contributions.map((c) => Dismissible(
                key: ValueKey(c.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) =>
                    provider.removePoolContribution(c.id),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.savings, color: Colors.white, size: 20),
                    ),
                    title: Text(DateFormat.yMMMM().format(c.date)),
                    trailing: CurrencyText(
                      amount: c.amount,
                      color: Colors.orange,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decimals: 0,
                    ),
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildPayoutScheduleSection(
      BuildContext context, TransactionProvider provider, MoneyPool pool) {
    final sortedPayouts = List<PoolPayout>.from(pool.payouts)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payout Schedule',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...sortedPayouts.asMap().entries.map((entry) {
          final index = entry.key;
          final payout = entry.value;
          final isNext = pool.nextPayout == payout;

          return Card(
            margin: const EdgeInsets.only(bottom: 4),
            color: payout.isReceived
                ? Colors.green.shade50
                : isNext
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                    : null,
            child: ListTile(
              leading: Icon(
                payout.isReceived ? Icons.check_circle : Icons.schedule,
                color: payout.isReceived ? Colors.green : Colors.grey,
              ),
              title: Text(DateFormat.yMMMMd().format(payout.date)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CurrencyText(
                    amount: payout.amount,
                    color: payout.isReceived ? Colors.green : Colors.black87,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: payout.isReceived ? Colors.green : null,
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
                      color: payout.isReceived ? Colors.grey : Colors.green,
                      onPressed: () =>
                          provider.togglePayoutReceived(index),
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
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _months[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
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
