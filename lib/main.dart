import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/app_database.dart';
import 'providers/transaction_provider.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(MainApp(db: db));
}

class MainApp extends StatelessWidget {
  final AppDatabase db;

  const MainApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider(db)..loadTransactions(),
      child: MaterialApp(
        title: 'SMS Transactions',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
