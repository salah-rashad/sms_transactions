import 'package:flutter_test/flutter_test.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/domain/models/sms_token.dart';
import 'package:sms_transactions/domain/sms/pattern_matcher.dart';
import 'package:sms_transactions/domain/sms/sms_tokenizer.dart';

void main() {
  late PatternMatcher matcher;
  const exampleBody = 'مبلغ 5,000 جنية';

  setUp(() {
    matcher = PatternMatcher();
  });

  NumericToken tokenIn(String body, String raw) {
    final tokens = SmsTokenizer().numericTokens(body);
    return tokens.firstWhere((t) => t.rawText == raw);
  }

  group('PatternMatcher.derivePattern + match round-trip', () {
    test('derived pattern matches its own example body', () {
      final amount = tokenIn(exampleBody, '5,000');
      final pattern = matcher.derivePattern(
        senderId: 'BANQUE-MISR',
        exampleBody: exampleBody,
        amount: amount,
        direction: SmsDirection.expense,
        patternId: 'p1',
        createdAt: DateTime(2026, 1, 1),
      );
      final match = matcher.match(
        pattern,
        'sms-1',
        exampleBody,
        DateTime(2026, 1, 2),
      );
      expect(match, isNotNull);
      expect(match!.amount, 5000.0);
      expect(match.senderId, 'BANQUE-MISR');
      expect(match.direction, SmsDirection.expense);
      expect(match.patternId, 'p1');
    });
  });

  group('PatternMatcher.match', () {
    test('matches new body with different amount', () {
      final amount = tokenIn(exampleBody, '5,000');
      final pattern = matcher.derivePattern(
        senderId: 'BANQUE-MISR',
        exampleBody: exampleBody,
        amount: amount,
        direction: SmsDirection.expense,
        patternId: 'p1',
        createdAt: DateTime(2026, 1, 1),
      );
      const newBody = 'مبلغ 7,250 جنية';
      final match = matcher.match(
        pattern,
        'sms-2',
        newBody,
        DateTime(2026, 1, 3),
      );
      expect(match, isNotNull);
      expect(match!.amount, 7250.0);
    });

    test('matches with extra whitespace/newlines around amount (FR-033)', () {
      final amount = tokenIn(exampleBody, '5,000');
      final pattern = matcher.derivePattern(
        senderId: 'BANQUE-MISR',
        exampleBody: exampleBody,
        amount: amount,
        direction: SmsDirection.expense,
        patternId: 'p1',
        createdAt: DateTime(2026, 1, 1),
      );
      const newBody = 'مبلغ\n\n5,000   جنية';
      final match = matcher.match(
        pattern,
        'sms-3',
        newBody,
        DateTime(2026, 1, 4),
      );
      expect(match, isNotNull);
      expect(match!.amount, 5000.0);
    });

    test('absent amount anchor → null (routes to unmatched, FR-025)', () {
      final amount = tokenIn(exampleBody, '5,000');
      final pattern = matcher.derivePattern(
        senderId: 'BANQUE-MISR',
        exampleBody: exampleBody,
        amount: amount,
        direction: SmsDirection.expense,
        patternId: 'p1',
        createdAt: DateTime(2026, 1, 1),
      );
      const newBody = 'no relevant anchors here 5,000 word';
      final match = matcher.match(
        pattern,
        'sms-4',
        newBody,
        DateTime(2026, 1, 5),
      );
      expect(match, isNull);
    });

    test('balance locator best-effort: null when absent (FR-025)', () {
      const withBalance = 'مبلغ 5,000 رصيد 1,200 جنية';
      final amount = tokenIn(withBalance, '5,000');
      final balance = tokenIn(withBalance, '1,200');
      final pattern = matcher.derivePattern(
        senderId: 'BANQUE-MISR',
        exampleBody: withBalance,
        amount: amount,
        balance: balance,
        direction: SmsDirection.expense,
        patternId: 'p1',
        createdAt: DateTime(2026, 1, 1),
      );
      const noBalanceBody = 'مبلغ 7,250 رصيد';
      final match = matcher.match(
        pattern,
        'sms-5',
        noBalanceBody,
        DateTime(2026, 1, 6),
      );
      expect(match, isNotNull);
      expect(match!.amount, 7250.0);
      expect(match.balance, isNull);
    });

    test('balance locator extracts balance when present', () {
      const withBalance = 'مبلغ 5,000 رصيد 1,200 جنية';
      final amount = tokenIn(withBalance, '5,000');
      final balance = tokenIn(withBalance, '1,200');
      final pattern = matcher.derivePattern(
        senderId: 'BANQUE-MISR',
        exampleBody: withBalance,
        amount: amount,
        balance: balance,
        direction: SmsDirection.expense,
        patternId: 'p1',
        createdAt: DateTime(2026, 1, 1),
      );
      const newBody = 'مبلغ 9,000 رصيد 3,500 جنية';
      final match = matcher.match(
        pattern,
        'sms-6',
        newBody,
        DateTime(2026, 1, 7),
      );
      expect(match, isNotNull);
      expect(match!.amount, 9000.0);
      expect(match.balance, 3500.0);
    });
  });

  group('PatternMatcher.matchAny', () {
    test('returns first resolving pattern in createdAt-asc order (FR-034)', () {
      final amount = tokenIn(exampleBody, '5,000');
      final older = matcher.derivePattern(
        senderId: 'BANQUE-MISR',
        exampleBody: exampleBody,
        amount: amount,
        direction: SmsDirection.expense,
        patternId: 'old',
        createdAt: DateTime(2026, 1, 1),
      );
      // Newer pattern with a different anchor that won't match.
      final newer = matcher.derivePattern(
        senderId: 'BANQUE-MISR',
        exampleBody: 'Charge 5,000 EGP',
        amount: tokenIn('Charge 5,000 EGP', '5,000'),
        direction: SmsDirection.expense,
        patternId: 'new',
        createdAt: DateTime(2026, 2, 1),
      );
      final result = matcher.matchAny(
        [newer, older], // passed out of order
        'sms-7',
        exampleBody,
        DateTime(2026, 3, 1),
      );
      expect(result, isNotNull);
      expect(result!.patternId, 'old');
    });

    test('returns null when no pattern resolves', () {
      final pattern = matcher.derivePattern(
        senderId: 'BANQUE-MISR',
        exampleBody: exampleBody,
        amount: tokenIn(exampleBody, '5,000'),
        direction: SmsDirection.expense,
        patternId: 'p1',
        createdAt: DateTime(2026, 1, 1),
      );
      final result = matcher.matchAny(
        [pattern],
        'sms-8',
        'totally unrelated body',
        DateTime(2026, 3, 1),
      );
      expect(result, isNull);
    });

    test('empty patterns → null', () {
      final result = matcher.matchAny(
        const [],
        'sms-9',
        exampleBody,
        DateTime(2026, 3, 1),
      );
      expect(result, isNull);
    });
  });

  group('PatternMatcher: balanceCheck without amount', () {
    test('matches with null amount when balanceLocator resolves', () {
      const body = 'Your balance is 1,200 EGP';
      final balance = tokenIn(body, '1,200');
      final pattern = matcher.derivePattern(
        senderId: 'BANK',
        exampleBody: body,
        balance: balance,
        direction: SmsDirection.balanceCheck,
        patternId: 'bc',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(pattern.amountLocator, isNull);

      const newBody = 'Your balance is 9,500 EGP';
      final match = matcher.match(
        pattern,
        'sms-bc',
        newBody,
        DateTime(2026, 1, 2),
      );
      expect(match, isNotNull);
      expect(match!.amount, isNull);
      expect(match.balance, 9500.0);
      expect(match.direction, SmsDirection.balanceCheck);
    });

    test('returns null when balance anchor absent', () {
      const body = 'Your balance is 1,200 EGP';
      final pattern = matcher.derivePattern(
        senderId: 'BANK',
        exampleBody: body,
        balance: tokenIn(body, '1,200'),
        direction: SmsDirection.balanceCheck,
        patternId: 'bc',
        createdAt: DateTime(2026, 1, 1),
      );
      const newBody = 'no anchor here either 1,200';
      final match = matcher.match(
        pattern,
        'sms-bc2',
        newBody,
        DateTime(2026, 1, 3),
      );
      expect(match, isNull);
    });
  });

  group('PatternMatcher: ignore-direction patterns', () {
    const promoBody = 'Win 1000 EGP cashback if you spend today';

    test('matches when counterpartyLocator resolves', () {
      final tokens = SmsTokenizer().textTokens(promoBody);
      final cashback = tokens.firstWhere((t) => t.rawText == 'cashback');
      final pattern = matcher.derivePattern(
        senderId: 'PROMO',
        exampleBody: promoBody,
        counterparty: cashback,
        direction: SmsDirection.ignore,
        patternId: 'ig',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(pattern.amountLocator, isNull);

      const newBody = 'Get 500 EGP cashback if you act today';
      final match = matcher.match(
        pattern,
        'sms-ig',
        newBody,
        DateTime(2026, 1, 2),
      );
      expect(match, isNotNull);
      expect(match!.amount, isNull);
      expect(match.direction, SmsDirection.ignore);
    });

    test('returns null when identifier anchor absent', () {
      final tokens = SmsTokenizer().textTokens(promoBody);
      final cashback = tokens.firstWhere((t) => t.rawText == 'cashback');
      final pattern = matcher.derivePattern(
        senderId: 'PROMO',
        exampleBody: promoBody,
        counterparty: cashback,
        direction: SmsDirection.ignore,
        patternId: 'ig',
        createdAt: DateTime(2026, 1, 1),
      );
      const newBody = 'Your bill is due tomorrow';
      final match = matcher.match(
        pattern,
        'sms-ig2',
        newBody,
        DateTime(2026, 1, 3),
      );
      expect(match, isNull);
    });
  });
}
