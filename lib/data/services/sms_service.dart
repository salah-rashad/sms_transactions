import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_transactions/domain/models/transaction.dart';

class SmsService {
  final SmsQuery _smsQuery = SmsQuery();

  Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<List<SmsMessage>> getFinancialSms() async {
    final alAhlyMessages = await _smsQuery.querySms(
      kinds: [SmsQueryKind.inbox],
      address: AccountSource.bankAlAhly.displayName,
      count: 5000,
    );

    final vfCashMessages = await _smsQuery.querySms(
      kinds: [SmsQueryKind.inbox],
      address: AccountSource.vfCash.displayName,
      count: 5000,
    );

    return [...alAhlyMessages, ...vfCashMessages]..sort(
      (a, b) => (b.date ?? DateTime(1970)).compareTo(a.date ?? DateTime(1970)),
    );
  }
}
