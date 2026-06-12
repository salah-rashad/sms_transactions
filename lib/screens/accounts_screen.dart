import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/currency_text.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        const AppBar(
          title: Text('Accounts'),
        ),
        const Divider(),
      ],
      child: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = provider.accounts;

          return RefreshTrigger(
            onRefresh: () async {
              await provider.loadTransactions();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: accounts.map((account) {
                  return Card(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              account.source.name == 'bankAlAhly'
                                  ? Icons.account_balance
                                  : Icons.phone_android,
                              size: 28,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const Gap(12),
                            Expanded(
                              child: Text(account.displayName).semiBold.large,
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Estimated Balance').muted.xSmall,
                                const Gap(4),
                                CurrencyText(
                                  amount: account.estimatedBalance,
                                  color: Theme.of(context).colorScheme.primary,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Transactions').muted.xSmall,
                                const Gap(4),
                                Text('${account.transactionCount}').bold.x2Large,
                              ],
                            ),
                          ],
                        ),
                        if (account.announcedBalance != null) ...[
                          const Gap(12),
                          SurfaceCard(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.mutedForeground,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: _AnnouncedBalanceText(
                                    announcedBalance: account.announcedBalance!,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).withPadding(bottom: 12);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnnouncedBalanceText extends StatelessWidget {
  final double announcedBalance;
  const _AnnouncedBalanceText({required this.announcedBalance});

  @override
  Widget build(BuildContext context) {
    return CurrencyText(
      amount: announcedBalance,
      color: Theme.of(context).colorScheme.mutedForeground,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.mutedForeground),
      prefix: 'Last announced: ',
    );
  }
}
