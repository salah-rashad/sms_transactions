import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'accounts_screen.dart';
import 'money_pool_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    AccountsScreen(),
    MoneyPoolScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      footers: [
        const Divider(),
        NavigationBar(
          labelType: NavigationLabelType.selected,
          expanded: true,
          selectedKey: ValueKey(_currentIndex),
          onSelected: (key) {
            if (key is ValueKey<int>) {
              setState(() => _currentIndex = key.value);
            }
          },
          children: [
            NavigationItem(
              key: const ValueKey(0),
              style: const ButtonStyle.muted(density: ButtonDensity.icon),
              selectedStyle: const ButtonStyle.fixed(density: ButtonDensity.icon),
              label: const Text('Dashboard'),
              child: const Icon(Icons.dashboard_outlined),
            ),
            NavigationItem(
              key: const ValueKey(1),
              style: const ButtonStyle.muted(density: ButtonDensity.icon),
              selectedStyle: const ButtonStyle.fixed(density: ButtonDensity.icon),
              label: const Text('Transactions'),
              child: const Icon(Icons.receipt_long_outlined),
            ),
            NavigationItem(
              key: const ValueKey(2),
              style: const ButtonStyle.muted(density: ButtonDensity.icon),
              selectedStyle: const ButtonStyle.fixed(density: ButtonDensity.icon),
              label: const Text('Accounts'),
              child: const Icon(Icons.account_balance_wallet_outlined),
            ),
            NavigationItem(
              key: const ValueKey(3),
              style: const ButtonStyle.muted(density: ButtonDensity.icon),
              selectedStyle: const ButtonStyle.fixed(density: ButtonDensity.icon),
              label: const Text('Pool'),
              child: const Icon(Icons.groups_outlined),
            ),
          ],
        ),
      ],
      child: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}
