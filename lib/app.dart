import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_transactions/core/theme/app_theme.dart';
import 'package:sms_transactions/di/injection.dart';
import 'package:sms_transactions/features/money_pool/cubit/money_pool_cubit.dart';
import 'package:sms_transactions/features/settings/cubit/theme_cubit.dart';
import 'package:sms_transactions/features/transactions/cubit/transaction_cubit.dart';
import 'package:sms_transactions/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => TransactionCubit(getIt(), getIt())..loadTransactions(),
        ),
        BlocProvider(create: (_) => MoneyPoolCubit(getIt())..load()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'SMS Transactions',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: AppRouter.config,
          );
        },
      ),
    );
  }
}
