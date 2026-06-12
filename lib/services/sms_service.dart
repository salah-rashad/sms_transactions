import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  final SmsQuery _smsQuery = SmsQuery();

  Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<List<SmsMessage>> getFinancialSms() async {
    final alAhlyMessages = await _smsQuery.querySms(
      kinds: [SmsQueryKind.inbox],
      address: "BanK-AlAhly",
      count: 5000,
    );

    final vfCashMessages = await _smsQuery.querySms(
      kinds: [SmsQueryKind.inbox],
      address: "VF-Cash",
      count: 5000,
    );

    // return messages.where((msg) {
    //   final address = (msg.address ?? '').toLowerCase();
    //   return address.contains('ahly') ||
    //       address.contains('vf-cash') ||
    //       address.contains('vf cash') ||
    //       address.contains('vodafone') ||
    //       address.contains('فودافون');
    // });

    return [...alAhlyMessages, ...vfCashMessages]..sort(
      (a, b) => (b.date ?? DateTime(1970)).compareTo(a.date ?? DateTime(1970)),
    );
  }
}
