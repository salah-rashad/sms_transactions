import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import '../models/transaction.dart';

class SmsParser {
  static Transaction? parse(SmsMessage sms) {
    final body = sms.body;
    if (body == null || body.isEmpty) return null;

    final address = (sms.address ?? '').toLowerCase();
    final isBankAlAhly = address.contains('ahly');
    final isVfCash = address.contains('vf-cash') ||
        address.contains('vf cash') ||
        address.contains('vodafone') ||
        address.contains('فودافون');

    if (isBankAlAhly) {
      return _parseBankAlAhly(sms, body);
    } else if (isVfCash) {
      return _parseVfCash(sms, body);
    }
    return null;
  }

  static Transaction? _parseBankAlAhly(SmsMessage sms, String body) {
    if (body.contains('تم إضافة تحويل لحظي')) {
      return _parseBankAlAhlyTransfer(sms, body, TransactionType.income);
    } else if (body.contains('تم تنفيذ تحويل لحظي')) {
      return _parseBankAlAhlyTransfer(sms, body, TransactionType.expense);
    } else if (body.contains('تم خصم')) {
      return _parseBankAlAhlyDeduction(sms, body);
    }
    return null;
  }

  static Transaction? _parseBankAlAhlyTransfer(
      SmsMessage sms, String body, TransactionType type) {
    final amountRegex = RegExp(r'بمبلغ\s+([\d,]+\.?\d*)\s*جم');
    final amountMatch = amountRegex.firstMatch(body);
    if (amountMatch == null) return null;

    final amount = _parseAmount(amountMatch.group(1)!);
    final counterparty = _extractCounterpartyFromBank(body);
    final date = sms.date ?? DateTime.now();

    return Transaction(
      id: '${sms.id ?? ''}-${body.hashCode}',
      source: AccountSource.bankAlAhly,
      type: type,
      amount: amount,
      counterparty: counterparty,
      date: date,
      rawSms: body,
    );
  }

  static Transaction? _parseBankAlAhlyDeduction(SmsMessage sms, String body) {
    final amountRegex = RegExp(r'خصم\s+([\d,]+\.?\d*)\s*EGP');
    final amountMatch = amountRegex.firstMatch(body);
    if (amountMatch == null) return null;

    final amount = _parseAmount(amountMatch.group(1)!);

    final counterpartyRegex = RegExp(r'عند\s+(.+?)\s+يوم');
    final counterpartyMatch = counterpartyRegex.firstMatch(body);
    final counterparty = counterpartyMatch?.group(1)?.trim();

    final balanceRegex = RegExp(r'المتاح\s+([\d,]+\.?\d*)\s*جم');
    final balanceMatch = balanceRegex.firstMatch(body);
    final balance =
        balanceMatch != null ? _parseAmount(balanceMatch.group(1)!) : null;

    final date = sms.date ?? DateTime.now();

    return Transaction(
      id: '${sms.id ?? ''}-${body.hashCode}',
      source: AccountSource.bankAlAhly,
      type: TransactionType.expense,
      amount: amount,
      balance: balance,
      counterparty: counterparty,
      date: date,
      rawSms: body,
    );
  }

  static Transaction? _parseVfCash(SmsMessage sms, String body) {
    if (body.contains('Your current Vodafone Cash balance')) {
      return _parseVfCashBalance(sms, body);
    } else if (body.contains('تم شحن رصيد موبايلك')) {
      return _parseVfCashAirtime(sms, body);
    } else if (body.contains('تم استلام مبلغ')) {
      return _parseVfCashReceive(sms, body);
    } else if (body.contains('تم سحب') && body.contains('فودافون كاش')) {
      return _parseVfCashWithdrawal(sms, body);
    }
    return null;
  }

  static Transaction? _parseVfCashBalance(SmsMessage sms, String body) {
    final balanceRegex = RegExp(r'balance\s+is\s+([\d,]+\.?\d*)\s*LE');
    final balanceMatch = balanceRegex.firstMatch(body);
    if (balanceMatch == null) return null;

    final balance = _parseAmount(balanceMatch.group(1)!);
    final date = sms.date ?? DateTime.now();

    return Transaction(
      id: '${sms.id ?? ''}-${body.hashCode}',
      source: AccountSource.vfCash,
      type: TransactionType.balanceCheck,
      amount: balance,
      balance: balance,
      date: date,
      rawSms: body,
    );
  }

  static Transaction? _parseVfCashAirtime(SmsMessage sms, String body) {
    final amountRegex = RegExp(r'وخصم\s+([\d,]+\.?\d*)');
    final amountMatch = amountRegex.firstMatch(body);
    if (amountMatch == null) return null;

    final amount = _parseAmount(amountMatch.group(1)!);
    final date = sms.date ?? DateTime.now();

    return Transaction(
      id: '${sms.id ?? ''}-${body.hashCode}',
      source: AccountSource.vfCash,
      type: TransactionType.expense,
      amount: amount,
      date: date,
      rawSms: body,
    );
  }

  static Transaction? _parseVfCashReceive(SmsMessage sms, String body) {
    final amountRegex = RegExp(r'مبلغ\s+([\d,]+\.?\d*)\s*جنيه');
    final amountMatch = amountRegex.firstMatch(body);
    if (amountMatch == null) return null;

    final amount = _parseAmount(amountMatch.group(1)!);
    final counterparty = _extractCounterpartyFromVf(body);
    final date = sms.date ?? DateTime.now();


    final balanceRegex = RegExp(r'رصيدك\s+([\d,]+\.?\d*)');
    final balanceMatch = balanceRegex.firstMatch(body);
    final balance =
        balanceMatch != null ? _parseAmount(balanceMatch.group(1)!) : null;

    return Transaction(
      id: '${sms.id ?? ''}-${body.hashCode}',
      source: AccountSource.vfCash,
      type: TransactionType.income,
      amount: amount,
      balance: balance,
      counterparty: counterparty,
      date: date,
      rawSms: body,
    );
  }

  static Transaction? _parseVfCashWithdrawal(SmsMessage sms, String body) {
    final amountRegex = RegExp(r'سحب\s+([\d,]+\.?\d*)\s*جني[ةه]');
    final amountMatch = amountRegex.firstMatch(body);
    if (amountMatch == null) return null;

    final amount = _parseAmount(amountMatch.group(1)!);
    final counterparty = _extractCounterpartyFromVf(body);
    final date = sms.date ?? DateTime.now();


    final balanceRegex = RegExp(r'رصيدك\s+([\d,]+\.?\d*)');
    final balanceMatch = balanceRegex.firstMatch(body);
    final balance =
        balanceMatch != null ? _parseAmount(balanceMatch.group(1)!) : null;

    return Transaction(
      id: '${sms.id ?? ''}-${body.hashCode}',
      source: AccountSource.vfCash,
      type: TransactionType.expense,
      amount: amount,
      balance: balance,
      counterparty: counterparty,
      date: date,
      rawSms: body,
    );
  }

  static double _parseAmount(String raw) {
    return double.parse(raw.replaceAll(',', ''));
  }

  static String? _extractCounterpartyFromBank(String body) {
    final regex = RegExp(r'إلى\s+(.+?)(?:\s*بمبلغ|\s*$)');
    final match = regex.firstMatch(body);
    return match?.group(1)?.trim();
  }

  static String? _extractCounterpartyFromVf(String body) {
    final regex = RegExp(r'من\s+(.+?)(?:\s*مبلغ|\s*رصيدك|\s*$)');
    final match = regex.firstMatch(body);
    return match?.group(1)?.trim();
  }
}
