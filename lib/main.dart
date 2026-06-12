import 'package:shadcn_flutter/shadcn_flutter.dart';
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
      child: const ShadcnApp(
        title: 'SMS Transactions',
        theme: ThemeData(
          colorScheme: ColorSchemes.lightSlate,
          radius: 0.5,
        ),
        darkTheme: ThemeData.dark(
          colorScheme: ColorSchemes.darkSlate,
          radius: 0.5,
        ),
        themeMode: ThemeMode.system,
        home: MainScreen(),
      ),
    );
  }
}
