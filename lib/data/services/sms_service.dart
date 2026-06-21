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

  /// Returns candidate SMS for the learned-pattern scan (research R2):
  /// alphanumeric-sender SMS plus already-patterned senders. No hardcoded
  /// address list. [patternedSenders] whitelists phone-number senders that the
  /// user has explicitly taught.
  Future<List<SmsMessage>> getCandidateSms(
    Set<String> patternedSenders, {
    int count = 10000,
  }) async {
    final all = await _smsQuery.querySms(
      kinds: [SmsQueryKind.inbox],
      count: count,
    );
    final filtered = all.where((sms) {
      final address = sms.address ?? '';
      if (address.isEmpty) return false;
      return isAlphanumericSender(address) || patternedSenders.contains(address);
    }).toList()
      ..sort(
        (a, b) =>
            (b.date ?? DateTime(1970)).compareTo(a.date ?? DateTime(1970)),
      );
    return filtered;
  }

  /// A sender is alphanumeric (a financial short-code) if it contains at least
  /// one letter (Latin or Arabic). Pure phone-number senders are excluded
  /// unless the user has taught them (R2).
  static bool isAlphanumericSender(String address) {
    for (final rune in address.runes) {
      if ((rune >= 0x41 && rune <= 0x5A) ||
          (rune >= 0x61 && rune <= 0x7A)) {
        return true;
      }
      if (rune >= 0x0600 && rune <= 0x06FF) return true;
    }
    return false;
  }
}
