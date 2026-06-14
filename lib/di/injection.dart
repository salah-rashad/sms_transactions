import 'package:get_it/get_it.dart';
import 'package:sms_transactions/data/database/app_database.dart';
import 'package:sms_transactions/data/repositories/money_pool_repository.dart';
import 'package:sms_transactions/data/repositories/salary_repository.dart';
import 'package:sms_transactions/data/services/sms_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final db = AppDatabase();

  getIt.registerSingleton<AppDatabase>(db);

  getIt.registerLazySingleton<SalaryRepository>(
    () => SalaryRepository(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<MoneyPoolRepository>(
    () => MoneyPoolRepository(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<SmsService>(() => SmsService());
}
