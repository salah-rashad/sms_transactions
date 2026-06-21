import 'package:get_it/get_it.dart';
import 'package:sms_transactions/data/database/app_database.dart';
import 'package:sms_transactions/data/repositories/money_pool_repository.dart';
import 'package:sms_transactions/data/repositories/pattern_repository.dart';
import 'package:sms_transactions/data/repositories/salary_repository.dart';
import 'package:sms_transactions/data/repositories/suppressed_sender_repository.dart';
import 'package:sms_transactions/data/repositories/unmatched_sms_repository.dart';
import 'package:sms_transactions/data/services/sms_scan_service.dart';
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

  // SMS Pattern Authoring (schema v2) — lazy singletons following the existing
  // repository conventions.
  getIt.registerLazySingleton<PatternRepository>(
    () => PatternRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<PatternMatchRepository>(
    () => PatternMatchRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<UnmatchedSmsRepository>(
    () => UnmatchedSmsRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<SuppressedSenderRepository>(
    () => SuppressedSenderRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<SmsScanService>(
    () => SmsScanService(
      smsService: getIt<SmsService>(),
      patternRepository: getIt<PatternRepository>(),
      patternMatchRepository: getIt<PatternMatchRepository>(),
      unmatchedSmsRepository: getIt<UnmatchedSmsRepository>(),
      suppressedSenderRepository: getIt<SuppressedSenderRepository>(),
    ),
  );
}
