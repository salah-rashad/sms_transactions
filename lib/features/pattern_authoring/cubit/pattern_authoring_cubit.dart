import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_transactions/core/utils/logger.dart';
import 'package:sms_transactions/data/repositories/pattern_repository.dart';
import 'package:sms_transactions/data/repositories/unmatched_sms_repository.dart';
import 'package:sms_transactions/domain/models/pattern_match.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/domain/models/sms_token.dart';
import 'package:sms_transactions/domain/models/unmatched_sms.dart';
import 'package:sms_transactions/domain/sms/pattern_matcher.dart';
import 'package:sms_transactions/domain/sms/sms_tokenizer.dart';
import 'package:sms_transactions/features/pattern_authoring/cubit/pattern_authoring_state.dart';
/// Route-scoped cubit for the 4-step authoring wizard + summary (FR-008..016).
///
/// Accepts the SMS body (via [source]) and an *optional* existing [SmsPattern]
/// for edit mode (FR-021, U1). In edit mode it pre-loads the example body,
/// re-derives the token lists, pre-selects amount/balance/direction/counterparty
/// from the existing locators, and on save updates the existing pattern
/// **preserving** totalAttempts/successfulMatches (FR-020). In create mode the
/// editing argument is null. See `contracts/cubits.contract.md`.
class PatternAuthoringCubit extends Cubit<PatternAuthoringState> {
  PatternAuthoringCubit({
    required UnmatchedSms source,
    SmsPattern? editing,
    PatternMatcher? matcher,
    required this.patternRepository,
    required this.patternMatchRepository,
    required this.unmatchedSmsRepository,
  })  : _matcher = matcher ?? PatternMatcher(),
        super(_initialState(source, editing)) {
    _initFromEditing();
  }

  final PatternMatcher _matcher;
  final PatternRepository patternRepository;
  final PatternMatchRepository patternMatchRepository;
  final UnmatchedSmsRepository unmatchedSmsRepository;

  static PatternAuthoringState _initialState(UnmatchedSms source, SmsPattern? editing) {
    final body = source.body ?? '';
    final tokenizer = SmsTokenizer();
    return PatternAuthoringState(
      source: source,
      editing: editing,
      numericTokens: tokenizer.numericTokens(body),
      textTokens: tokenizer.textTokens(body),
    );
  }

  void _initFromEditing() {
    final editing = state.editing;
    if (editing == null) return;

    final amount = _findNumericByLocator(editing.amountLocator);
    final balance = _findNumericByLocator(editing.balanceLocator);
    final cpTokens = _findTextTokensByLocator(editing.counterpartyLocator);
    final merged = cpTokens.isNotEmpty ? TextToken.merge(cpTokens) : null;
    emit(state.copyWith(
      amount: amount,
      balance: balance,
      direction: editing.direction,
      counterpartyTokens: cpTokens,
      counterparty: merged,
      stepIndex: PatternAuthoringState.counterpartyStep + 1, // land on summary
    ));
    _recomputePreview();
  }

  NumericToken? _findNumericByLocator(FieldLocator? locator) {
    if (locator == null) return null;
    for (final t in state.numericTokens) {
      if (t.beforeWord == locator.beforeAnchor &&
          t.afterWord == locator.afterAnchor) {
        return t;
      }
    }
    for (final t in state.numericTokens) {
      if (locator.beforeAnchor.isNotEmpty &&
          t.beforeWord == locator.beforeAnchor) {
        return t;
      }
      if (locator.afterAnchor.isNotEmpty &&
          t.afterWord == locator.afterAnchor) {
        return t;
      }
    }
    return null;
  }

  List<TextToken> _findTextTokensByLocator(FieldLocator? locator) {
    if (locator == null) return const [];
    final body = state.source.body ?? '';
    final tokens = state.textTokens;
    for (var start = 0; start < tokens.length; start++) {
      final before = _wordBefore(body, tokens[start].startIndex);
      if (locator.beforeAnchor.isNotEmpty && before != locator.beforeAnchor) {
        continue;
      }
      for (var end = start; end < tokens.length; end++) {
        final after = _wordAfter(body, tokens[end].endIndex);
        if (after == locator.afterAnchor) {
          return tokens.sublist(start, end + 1);
        }
        // Stop extending if the next token isn't adjacent in the body.
        if (end + 1 < tokens.length &&
            tokens[end + 1].startIndex - tokens[end].endIndex > 10) {
          break;
        }
      }
    }
    return const [];
  }

  // --- Selection → auto-advance (FR-009..012) -------------------------------

  /// Step 1: select the transaction amount (required), then advance (FR-009).
  void selectAmount(NumericToken t) {
    emit(state.copyWith(amount: t, stepIndex: PatternAuthoringState.balanceStep));
    _recomputePreview();
  }

  /// Step 2: select the running balance, or pass null to skip (FR-010).
  void selectBalance(NumericToken? t) {
    emit(state.copyWith(
      balance: t,
      clearBalance: t == null,
      stepIndex: PatternAuthoringState.directionStep,
    ));
    _recomputePreview();
  }

  /// Step 3: classify the transaction direction (required) (FR-011).
  void selectDirection(SmsDirection d) {
    emit(state.copyWith(
      direction: d,
      stepIndex: PatternAuthoringState.counterpartyStep,
    ));
    _recomputePreview();
  }

  /// Step 4: toggle a text token in/out of the multi-word counterparty
  /// selection. Only consecutive tokens are allowed. Does NOT auto-advance.
  void toggleCounterpartyToken(TextToken t) {
    final allTokens = state.textTokens;
    final idx = allTokens.indexOf(t);
    if (idx < 0) return;

    var selected = [...state.counterpartyTokens];
    if (selected.contains(t)) {
      // Deselect: if edge, shrink; if interior, reset to just this token.
      if (t == selected.first || t == selected.last) {
        selected.remove(t);
      } else {
        selected = [t];
      }
    } else if (selected.isEmpty) {
      selected = [t];
    } else {
      // Check adjacency in the textTokens list.
      final selectedIndices = selected.map((s) => allTokens.indexOf(s)).toList()
        ..sort();
      final lo = selectedIndices.first;
      final hi = selectedIndices.last;
      if (idx == lo - 1 || idx == hi + 1) {
        selected.add(t);
      } else {
        selected = [t];
      }
    }

    final merged = selected.isNotEmpty ? TextToken.merge(selected) : null;
    emit(state.copyWith(
      counterpartyTokens: selected,
      counterparty: merged,
      clearCounterparty: selected.isEmpty,
    ));
    _recomputePreview();
  }

  void confirmCounterparty() {
    emit(state.copyWith(
        stepIndex: PatternAuthoringState.counterpartyStep + 1));
  }

  void skipCounterparty() {
    emit(state.copyWith(
      clearCounterparty: true,
      stepIndex: PatternAuthoringState.counterpartyStep + 1,
    ));
    _recomputePreview();
  }

  /// Decrement the step without clearing later selections (FR-013).
  void back() {
    if (state.stepIndex > 0) {
      emit(state.copyWith(stepIndex: state.stepIndex - 1));
    }
  }

  void _recomputePreview() {
    final s = state;
    if (s.amount == null || s.direction == null) {
      emit(s.copyWith(clearPreview: true));
      return;
    }
    final body = s.source.body ?? '';
    final pattern = _matcher.derivePattern(
      senderId: s.source.senderId,
      exampleBody: body,
      amount: s.amount!,
      balance: s.balance,
      counterparty: s.counterparty,
      direction: s.direction!,
      patternId: s.editing?.id,
      createdAt: s.editing?.createdAt,
    );
    final preview =
        _matcher.match(pattern, s.source.smsId, body, s.source.receivedAt);
    emit(s.copyWith(preview: preview));
  }

  /// FR-015: derive + persist the SmsPattern (or update in edit mode preserving
  /// counters), parse the example into a [PatternMatch] (transaction dated to
  /// the SMS received timestamp), remove it from the unmatched queue, then emit
  /// [PatternAuthoringStatus.saved]. The screen reacts by refreshing the
  /// [UnmatchedCubit] and popping.
  Future<void> save() async {
    final s = state;
    if (s.amount == null || s.direction == null) return;
    emit(s.copyWith(status: PatternAuthoringStatus.saving, clearError: true));
    try {
      final body = s.source.body ?? '';
      final now = DateTime.now();
      final isEdit = s.editing != null;
      final patternId = s.editing?.id ?? 'pattern-${now.microsecondsSinceEpoch}';
      final createdAt = s.editing?.createdAt ?? now;

      final derived = _matcher.derivePattern(
        senderId: s.source.senderId,
        exampleBody: body,
        amount: s.amount!,
        balance: s.balance,
        counterparty: s.counterparty,
        direction: s.direction!,
        patternId: patternId,
        createdAt: createdAt,
      );

      final pattern = derived.copyWith(
        totalAttempts: s.editing?.totalAttempts ?? 0,
        successfulMatches: s.editing?.successfulMatches ?? 0,
        lastMatchedAt: s.editing?.lastMatchedAt,
      );
      await patternRepository.upsert(pattern);

      // Parse the example → PatternMatch (FR-015). smsId PK ⇒ idempotent.
      final match =
          _matcher.match(pattern, s.source.smsId, body, s.source.receivedAt);
      if (match != null) {
        await patternMatchRepository.upsert(match);
        // A new pattern counts its teaching example as 1/1 (FR-020). Edit mode
        // preserves existing counters (no double-count).
        if (!isEdit) {
          await patternRepository.recordAttempt(patternId,
              success: true, matchedAt: match.matchedAt);
        }
      }

      // State transition Unmatched → Matched (FR-035): drop the queue entry.
      await unmatchedSmsRepository.removeBySmsId(s.source.smsId);

      emit(state.copyWith(status: PatternAuthoringStatus.saved, clearError: true));
    } catch (e, st) {
      Logger.error('PatternAuthoringCubit.save', e, st);
      emit(state.copyWith(status: PatternAuthoringStatus.error, error: e.toString()));
    }
  }

  // --- Word-boundary helpers (mirror the tokenizer's logic for edit lookup) --

  static String _wordBefore(String body, int tokenStart) {
    if (tokenStart == 0) return '';
    var i = tokenStart - 1;
    while (i >= 0 && _isWhitespace(body.codeUnitAt(i))) {
      i -= 1;
    }
    if (i < 0) return '';
    final end = i + 1;
    while (i >= 0 && !_isWhitespace(body.codeUnitAt(i))) {
      i -= 1;
    }
    return body.substring(i + 1, end);
  }

  static String _wordAfter(String body, int tokenEnd) {
    if (tokenEnd >= body.length) return '';
    var i = tokenEnd;
    while (i < body.length && _isWhitespace(body.codeUnitAt(i))) {
      i += 1;
    }
    if (i >= body.length) return '';
    final start = i;
    while (i < body.length && !_isWhitespace(body.codeUnitAt(i))) {
      i += 1;
    }
    return body.substring(start, i);
  }

  static bool _isWhitespace(int c) =>
      c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D || c == 0xA0;
}
