import 'package:flutter_test/flutter_test.dart';
import 'package:sms_transactions/domain/sms/sms_tokenizer.dart';

void main() {
  group('SmsTokenizer.numericTokens', () {
    final tokenizer = SmsTokenizer();

    test('Latin digits with comma thousands + decimal, anchors set', () {
      const body = 'مبلغ 5,000.00 جنية';
      final tokens = tokenizer.numericTokens(body);
      expect(tokens, hasLength(1));
      final t = tokens.single;
      expect(t.normalizedValue, 5000.0);
      expect(t.rawText, '5,000.00');
      expect(t.beforeWord, 'مبلغ');
      expect(t.afterWord, 'جنية');
      expect(t.startIndex, lessThan(t.endIndex));
      expect(body.substring(t.startIndex, t.endIndex), '5,000.00');
      expect(t.isLikelyNonTransactional, isFalse);
    });

    test('Arabic-Indic digits + Arabic separators normalize', () {
      const body = 'رصيد ٥٬٠٠٠٫٥٠ جنيه';
      final tokens = tokenizer.numericTokens(body);
      expect(tokens, hasLength(1));
      final t = tokens.single;
      expect(t.normalizedValue, 5000.5);
      expect(t.beforeWord, 'رصيد');
      expect(t.afterWord, 'جنيه');
    });

    test('EU-style with period thousands, periodThousands locale', () {
      const body = '5.000,00 EGP';
      final tokens = tokenizer.numericTokens(
        body,
        localeHint: NumberLocale.periodThousands,
      );
      expect(tokens, isNotEmpty);
      expect(tokens.first.normalizedValue, 5000.0);
    });

    test('default comma-as-thousands for ambiguous 1,500', () {
      const body = 'amount 1,500 exactly';
      final tokens = tokenizer.numericTokens(body);
      expect(tokens, hasLength(1));
      expect(tokens.first.normalizedValue, 1500.0);
    });

    test('OTP-style long pure-digit token flagged non-transactional', () {
      const body = 'Your OTP code is 123456';
      final tokens = tokenizer.numericTokens(body);
      final otp = tokens.firstWhere((t) => t.rawText == '123456');
      expect(otp.isLikelyNonTransactional, isTrue);
    });

    test('currency-adjacent amount not flagged', () {
      const body = 'بمبلغ 5,000.00 جم';
      final tokens = tokenizer.numericTokens(body);
      expect(tokens, hasLength(1));
      expect(tokens.first.isLikelyNonTransactional, isFalse);
    });

    test('mixed LTR/RTL preserves logical order and spans', () {
      const body = 'Bank AlAhly 100.50 EGP رصيد 200.75';
      final tokens = tokenizer.numericTokens(body);
      expect(tokens.length, greaterThanOrEqualTo(2));
      for (final t in tokens) {
        expect(t.startIndex, lessThan(t.endIndex));
        expect(body.substring(t.startIndex, t.endIndex), t.rawText);
      }
      expect(tokens[0].normalizedValue, 100.50);
      expect(tokens[1].normalizedValue, 200.75);
    });

    test('empty body or no digits yields empty list', () {
      expect(tokenizer.numericTokens(''), isEmpty);
      expect(tokenizer.numericTokens('no numbers here'), isEmpty);
    });

    test('normalize round-trips tokens previously emitted', () {
      const body = 'مبلغ 7,250.00 جنية';
      final tokens = tokenizer.numericTokens(body);
      final again = tokenizer.normalize(tokens.first.rawText);
      expect(again, tokens.first.normalizedValue);
    });

    test('multiple numbers in one body each become their own token', () {
      const body = 'amount 1,000 balance 2,000.50';
      final tokens = tokenizer.numericTokens(body);
      expect(tokens, hasLength(2));
      expect(tokens[0].normalizedValue, 1000.0);
      expect(tokens[0].afterWord, 'balance');
      expect(tokens[1].normalizedValue, 2000.50);
      expect(tokens[1].beforeWord, 'balance');
    });
  });

  group('SmsTokenizer.textTokens', () {
    final tokenizer = SmsTokenizer();

    test('whitespace-delimited words with spans', () {
      const body = 'تم اضافة 500 جنيه';
      final tokens = tokenizer.textTokens(body);
      expect(tokens.map((t) => t.rawText), ['تم', 'اضافة', '500', 'جنيه']);
      for (final t in tokens) {
        expect(body.substring(t.startIndex, t.endIndex), t.rawText);
      }
    });

    test('empty body yields empty list', () {
      expect(tokenizer.textTokens(''), isEmpty);
    });
  });

  group('SmsTokenizer.normalize', () {
    final tokenizer = SmsTokenizer();

    test('Arabic-Indic digits', () {
      expect(tokenizer.normalize('٥٠٠'), 500.0);
    });

    test('single decimal point stays decimal', () {
      expect(tokenizer.normalize('100.50'), 100.50);
    });

    test('multiple dots treated as thousands (EU)', () {
      expect(tokenizer.normalize('1.000.000'), 1000000.0);
    });

    test('multiple commas treated as thousands', () {
      expect(tokenizer.normalize('1,000,000'), 1000000.0);
    });

    test('dot decimal + comma thousands (US)', () {
      expect(tokenizer.normalize('1,234.56'), 1234.56);
    });

    test('comma decimal + dot thousands (EU)', () {
      expect(
        tokenizer.normalize('1.234,56'),
        1234.56,
      );
    });
  });
}
