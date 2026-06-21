import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_transactions/data/repositories/pattern_repository.dart';
import 'package:sms_transactions/data/repositories/unmatched_sms_repository.dart';
import 'package:sms_transactions/di/injection.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/domain/models/unmatched_sms.dart';
import 'package:sms_transactions/features/accounts/accounts_screen.dart';
import 'package:sms_transactions/features/dashboard/dashboard_screen.dart';
import 'package:sms_transactions/features/home/main_screen.dart';
import 'package:sms_transactions/features/money_pool/money_pool_screen.dart';
import 'package:sms_transactions/features/pattern_authoring/cubit/pattern_authoring_cubit.dart';
import 'package:sms_transactions/features/pattern_authoring/pattern_authoring_screen.dart';
import 'package:sms_transactions/features/settings/settings_screen.dart';
import 'package:sms_transactions/features/transactions/transactions_screen.dart';
import 'package:sms_transactions/features/unmatched/unmatched_screen.dart';

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
      GoRoute(
        path: '/unmatched',
        builder: (context, state) => const UnmatchedScreen(),
        routes: [
          GoRoute(
            path: 'teach',
            builder: (context, state) {
              final extra = state.extra;
              final UnmatchedSms source;
              SmsPattern? editing;

              if (extra is UnmatchedSms) {
                source = extra;
              } else if (extra is ({UnmatchedSms sms, SmsPattern pattern})) {
                source = extra.sms;
                editing = extra.pattern;
              } else {
                return const Scaffold(
                  body: Center(child: Text('Missing SMS data')),
                );
              }

              return BlocProvider(
                create: (_) => PatternAuthoringCubit(
                  source: source,
                  editing: editing,
                  patternRepository: getIt<PatternRepository>(),
                  patternMatchRepository: getIt<PatternMatchRepository>(),
                  unmatchedSmsRepository: getIt<UnmatchedSmsRepository>(),
                ),
                child: const PatternAuthoringScreen(),
              );
            },
          ),
        ],
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
