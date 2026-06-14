import 'package:flutter/material.dart';
import 'package:sms_transactions/app.dart';
import 'package:sms_transactions/data/database/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(App(db: db));
}
