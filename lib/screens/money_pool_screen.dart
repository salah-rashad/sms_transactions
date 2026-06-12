import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/money_pool.dart';
import '../widgets/currency_text.dart';

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
      headers: [
        AppBar(
          title: const Text('Money Pool (جمعية)'),
          trailing: [
            IconButton.ghost(
              onPressed: _toggleLock,
              density: ButtonDensity.icon,
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
            ),
          ],
        ),
        const Divider(),
      ],
      child: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final pool = provider.moneyPool;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(context, pool),
                    const Gap(16),
                    _buildNextPayoutCard(context, pool),
                    const Gap(16),
                    _buildContributionsSection(context, provider, pool),
                    const Gap(16),
                    _buildPayoutScheduleSection(context, provider, pool),
                    const Gap(80),
                  ],
                ),
              ),
              if (_isLocked)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildLockedBanner(context),
                ),
              if (!_isLocked)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: PrimaryButton(
                    onPressed: () => _showAddContributionDialog(context),
                    density: ButtonDensity.icon,
                    child: const Icon(Icons.add),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLockedBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.muted,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.border,
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
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
            const Gap(6),
            Text(
              'Screen is locked · Tap ',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            Icon(
              Icons.lock_outline,
              size: 12,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
            Text(
              ' in toolbar to unlock',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, MoneyPool pool) {
    return Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.groups, size: 24, color: Theme.of(context).colorScheme.primary),
              const Gap(12),
              const Text('Pool Overview').semiBold.large,
            ],
          ),
          const Divider(),
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
          const Gap(12),
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
    );
  }

  Widget _buildStatItem(String label, Widget value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label).muted.xSmall,
        const Gap(4),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[400]),
            const Gap(12),
            const Text('All payouts received!'),
          ],
        ),
      );
    }

    final monthsLeft = pool.monthsUntilNextPayout;

    return SurfaceCard(
      child: Row(
        children: [
          Icon(Icons.event, color: Theme.of(context).colorScheme.primary, size: 28),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Next Payout').muted.xSmall,
                const Gap(2),
                Text(DateFormat.yMMMMd().format(next.date)).semiBold.large,
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CurrencyText(
                amount: next.amount,
                color: Theme.of(context).colorScheme.primary,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                decimals: 0,
              ),
              const Gap(2),
              Text(
                monthsLeft == 0
                    ? 'This month!'
                    : '$monthsLeft month${monthsLeft > 1 ? 's' : ''} left',
              ).muted.xSmall,
            ],
          ),
        ],
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
            const Text('Contributions').semiBold.large,
            const Spacer(),
            Text('${pool.contributionCount} entries').muted.small,
          ],
        ),
        const Gap(8),
        if (pool.contributions.isEmpty)
          Card(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                _isLocked
                    ? 'No contributions yet.'
                    : 'No contributions yet.\nTap + to add one.',
                textAlign: TextAlign.center,
              ).muted,
            ),
          )
        else
          ...pool.contributions.map((c) {
            final child = Card(
              padding: EdgeInsets.zero,
              child: Basic(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.savings, color: Colors.orange, size: 18),
                ),
                leadingAlignment: Alignment.center,
                title: Text(DateFormat.yMMMM().format(c.date)),
                trailing: CurrencyText(
                  amount: c.amount,
                  color: Colors.orange,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  decimals: 0,
                ),
                trailingAlignment: Alignment.center,
              ),
            ).withPadding(bottom: 4);

            if (_isLocked) return child;

            return Dismissible(
              key: ValueKey(c.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => provider.removePoolContribution(c.id),
              child: child,
            );
          }),
      ],
    );
  }

  Widget _buildPayoutScheduleSection(
      BuildContext context, TransactionProvider provider, MoneyPool pool) {
    final sortedPayouts = pool.payouts
        .asMap()
        .entries
        .toList()
      ..sort((a, b) => a.value.date.compareTo(b.value.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payout Schedule').semiBold.large,
        const Gap(8),
        ...sortedPayouts.map((entry) {
          final index = entry.key;
          final payout = entry.value;
          final isNext = pool.nextPayout == payout;

          return Card(
            padding: EdgeInsets.zero,
            borderColor: isNext
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : payout.isReceived
                    ? Colors.green.withValues(alpha: 0.3)
                    : null,
            child: Basic(
              leading: Icon(
                payout.isReceived ? Icons.check_circle : Icons.schedule,
                color: payout.isReceived ? Colors.green : Theme.of(context).colorScheme.mutedForeground,
              ),
              leadingAlignment: Alignment.center,
              title: Text(DateFormat.yMMMMd().format(payout.date)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CurrencyText(
                    amount: payout.amount,
                    color: payout.isReceived ? Colors.green : Theme.of(context).colorScheme.foreground,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: payout.isReceived ? Colors.green : Theme.of(context).colorScheme.foreground,
                    ),
                    decimals: 0,
                  ),
                  const Gap(8),
                  SizedBox(
                    width: 28,
                    child: IconButton.ghost(
                      density: ButtonDensity.icon,
                      icon: Icon(
                        payout.isReceived ? Icons.undo : Icons.check,
                        size: 18,
                      ),
                      onPressed: _isLocked
                          ? null
                          : () => provider.togglePayoutReceived(index),
                    ),
                  ),
                ],
              ),
              trailingAlignment: Alignment.center,
            ),
          ).withPadding(bottom: 4);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Amount (EGP)').semiBold.small,
                  const Gap(4),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    placeholder: const Text('Amount'),
                  ),
                  const Gap(16),
                  GestureDetector(
                    onTap: () async {
                      final picked = await _showMonthPicker(
                        context: ctx,
                        initialDate: selectedDate,
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Basic(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(DateFormat.yMMMM().format(selectedDate)),
                      trailing: const Icon(Icons.edit, size: 16),
                      trailingAlignment: Alignment.center,
                      leadingAlignment: Alignment.center,
                    ),
                  ),
                ],
              ),
              actions: [
                OutlineButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                PrimaryButton(
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

  Future<DateTime?> _showMonthPicker({
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
            OutlineButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
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
            IconButton.ghost(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _selectedYear--),
              density: ButtonDensity.icon,
            ),
            Text('$_selectedYear').semiBold.large,
            IconButton.ghost(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _selectedYear++),
              density: ButtonDensity.icon,
            ),
          ],
        ),
        const Gap(8),
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
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedMonth = month);
                  widget.onChanged(DateTime(_selectedYear, month));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _months[index],
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryForeground
                            : null,
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
