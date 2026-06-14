import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_transactions/core/theme/app_theme.dart';
import 'package:sms_transactions/data/database/app_database.dart';
import 'package:sms_transactions/data/repositories/money_pool_repository.dart';
import 'package:sms_transactions/data/repositories/salary_repository.dart';
import 'package:sms_transactions/features/home/main_screen.dart';
import 'package:sms_transactions/features/money_pool/providers/money_pool_provider.dart';
import 'package:sms_transactions/features/settings/providers/theme_provider.dart';
import 'package:sms_transactions/features/transactions/providers/transaction_provider.dart';

class App extends StatelessWidget {
  final AppDatabase db;

  const App({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              MoneyPoolProvider(MoneyPoolRepository(db))..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              TransactionProvider(SalaryRepository(db))..loadTransactions(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'SMS Transactions',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
