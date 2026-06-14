import 'package:go_router/go_router.dart';
import 'package:sms_transactions/features/accounts/accounts_screen.dart';
import 'package:sms_transactions/features/dashboard/dashboard_screen.dart';
import 'package:sms_transactions/features/home/main_screen.dart';
import 'package:sms_transactions/features/money_pool/money_pool_screen.dart';
import 'package:sms_transactions/features/settings/settings_screen.dart';
import 'package:sms_transactions/features/transactions/transactions_screen.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter config = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/accounts',
                builder: (context, state) => const AccountsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pool',
                builder: (context, state) => const MoneyPoolScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/transactions/range',
        builder: (context, state) {
          final params = state.uri.queryParameters;
          final startMs = int.tryParse(params['start'] ?? '');
          final endMs = int.tryParse(params['end'] ?? '');
          final label = params['label'];
          return TransactionsScreen(
            initialRangeStart: startMs != null
                ? DateTime.fromMillisecondsSinceEpoch(startMs)
                : null,
            initialRangeEnd: endMs != null
                ? DateTime.fromMillisecondsSinceEpoch(endMs)
                : null,
            initialRangeLabel: label,
          );
        },
      ),
    ],
  );

  static String transactionsRangePath({
    required DateTime start,
    DateTime? end,
    String? label,
  }) {
    final query = <String, String>{'start': '${start.millisecondsSinceEpoch}'};
    if (end != null) query['end'] = '${end.millisecondsSinceEpoch}';
    if (label != null) query['label'] = label;
    final uri = Uri(path: '/transactions/range', queryParameters: query);
    return uri.toString();
  }
}
