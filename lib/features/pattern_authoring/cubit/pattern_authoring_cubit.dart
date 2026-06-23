import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_transactions/core/utils/logger.dart';
import 'package:sms_transactions/data/repositories/pattern_repository.dart';
import 'package:sms_transactions/data/repositories/unmatched_sms_repository.dart';
import 'package:sms_transactions/data/services/sms_scan_service.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/domain/models/sms_token.dart';
import 'package:sms_transactions/domain/models/unmatched_sms.dart';
import 'package:sms_transactions/domain/sms/pattern_matcher.dart';
import 'package:sms_transactions/domain/sms/sms_tokenizer.dart';
import 'package:sms_transactions/features/pattern_authoring/cubit/pattern_authoring_state.dart';

/// Route-scoped cubit for the direction-first authoring wizard.
///
/// Step order is computed from the chosen direction (see
/// [PatternAuthoringState.activeSteps]):
///   * income / expense → direction → amount → balance? → counterparty? → summary
///   * balanceCheck     → direction → balance → summary
///   * ignore           → direction → counterparty → summary
///
/// On save, the pattern is persisted, the example is parsed (skipped for
/// ignore — those don't produce ledger rows), the queue is re-matched against
/// other unmatched messages from the same sender, and if any remain the
/// wizard auto-launches into the next one.
class PatternAuthoringCubit extends Cubit<PatternAuthoringState> {
  PatternAuthoringCubit({
    required UnmatchedSms source,
    SmsPattern? editing,
    PatternMatcher? matcher,
    Set<String> deferredIds = const {},
    required this.patternRepository,
    required this.patternMatchRepository,
    required this.unmatchedSmsRepository,
    required this.scanService,
  })  : _matcher = matcher ?? PatternMatcher(),
        super(_initialState(source, editing, deferredIds)) {
    Logger.data(
      'Authoring.boot',
      'mode=${editing == null ? "create" : "edit"} '
          'smsId=${source.smsId} sender=${source.senderId} '
          'numeric=${state.numericTokens.length} '
          'text=${state.textTokens.length}',
      emoji: '🚀',
    );
    _initFromEditing();
    _loadSenderQueue();
  }

  final PatternMatcher _matcher;
  final PatternRepository patternRepository;
  final PatternMatchRepository patternMatchRepository;
  final UnmatchedSmsRepository unmatchedSmsRepository;
  final SmsScanService scanService;

  static PatternAuthoringState _initialState(
      UnmatchedSms source, SmsPattern? editing, Set<String> deferredIds) {
    final body = source.body ?? '';
    final tokenizer = SmsTokenizer();
    return PatternAuthoringState(
      source: source,
      editing: editing,
      deferredIds: deferredIds,
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

    // Land on the summary (last entry in activeSteps) — direction is set so
    // the plan is computed correctly.
    final withDirection = state.copyWith(
      amount: amount,
      balance: balance,
      direction: editing.direction,
      counterpartyTokens: cpTokens,
      counterparty: merged,
    );
    Logger.data(
      'Authoring.preload',
      'dir=${editing.direction} amount=${amount != null} '
          'balance=${balance != null} counterparty=${cpTokens.length} '
          '→ landing@summary',
      emoji: '📥',
    );
    emit(withDirection.copyWith(
      stepIndex: withDirection.activeSteps.length - 1,
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
        if (end + 1 < tokens.length &&
            tokens[end + 1].startIndex - tokens[end].endIndex > 10) {
          break;
        }
      }
    }
    return const [];
  }

  // --- Step navigation ------------------------------------------------------

  /// Step 0: classify the message. Picking a direction recomputes the active
  /// step plan, so we always advance to step 1 of the new plan.
  void selectDirection(SmsDirection d) {
    Logger.data('Authoring.direction', '$d selected', emoji: '👉');
    // If switching from a direction whose primary value step was "balance" /
    // "counterparty" back to one needing amount, the previous selection may
    // no longer fit — keep it for now, the user can re-pick.
    emit(state.copyWith(direction: d, stepIndex: 1));
    Logger.data(
      'Authoring.plan',
      state.activeSteps.map((s) => s.name).join(' → '),
      emoji: '🧭',
    );
    _recomputePreview();
  }

  /// Amount step (income/expense only).
  void selectAmount(NumericToken t) {
    Logger.data(
      'Authoring.amount',
      '${t.rawText} → ${t.normalizedValue} '
          '(before="${t.beforeWord}" after="${t.afterWord}")',
      emoji: '👉',
    );
    emit(state.copyWith(amount: t, stepIndex: state.stepIndex + 1));
    _recomputePreview();
  }

  /// Balance step. Required for balanceCheck; optional for income/expense.
  /// Null = skip (only valid when optional).
  void selectBalance(NumericToken? t) {
    if (t == null) {
      Logger.data('Authoring.balance', 'skipped (optional)', emoji: '⏭️');
    } else {
      Logger.data(
        'Authoring.balance',
        '${t.rawText} → ${t.normalizedValue} '
            '(before="${t.beforeWord}" after="${t.afterWord}")',
        emoji: '👉',
      );
    }
    emit(state.copyWith(
      balance: t,
      clearBalance: t == null,
      stepIndex: state.stepIndex + 1,
    ));
    _recomputePreview();
  }

  /// Counterparty toggle (multi-word selection). Does NOT auto-advance —
  /// the user confirms via the footer.
  void toggleCounterpartyToken(TextToken t) {
    final allTokens = state.textTokens;
    final idx = allTokens.indexOf(t);
    if (idx < 0) return;

    var selected = [...state.counterpartyTokens];
    var action = 'add';
    if (selected.contains(t)) {
      if (t == selected.first || t == selected.last) {
        selected.remove(t);
        action = 'shrink';
      } else {
        selected = [t];
        action = 'restart';
      }
    } else if (selected.isEmpty) {
      selected = [t];
      action = 'first';
    } else {
      final selectedIndices = selected
          .map((s) => allTokens.indexOf(s))
          .toList()
        ..sort();
      final lo = selectedIndices.first;
      final hi = selectedIndices.last;
      if (idx == lo - 1 || idx == hi + 1) {
        selected.add(t);
        action = 'extend';
      } else {
        selected = [t];
        action = 'restart';
      }
    }

    final merged = selected.isNotEmpty ? TextToken.merge(selected) : null;
    Logger.data(
      'Authoring.counterparty',
      '$action "${t.rawText}" → ${selected.length} selected'
          '${merged != null ? ' (="${merged.rawText}")' : ''}',
      emoji: '👉',
    );
    emit(state.copyWith(
      counterpartyTokens: selected,
      counterparty: merged,
      clearCounterparty: selected.isEmpty,
    ));
    _recomputePreview();
  }

  /// Confirm the counterparty step (also used to advance from an empty
  /// selection in income/expense flows, where it's optional).
  void confirmCounterparty() {
    Logger.data(
      'Authoring.confirm',
      '${state.counterpartyTokens.length} token(s)'
          '${state.counterparty != null ? ' ="${state.counterparty!.rawText}"' : ''}',
      emoji: '✅',
    );
    emit(state.copyWith(stepIndex: state.stepIndex + 1));
  }

  /// Skip the (optional) counterparty step. Not valid for ignore-direction
  /// patterns where counterparty IS the identifier — the UI hides the skip
  /// button in that case.
  void skipCounterparty() {
    Logger.data('Authoring.skipCounterparty', 'skipped (optional)', emoji: '⏭️');
    emit(state.copyWith(
      clearCounterparty: true,
      stepIndex: state.stepIndex + 1,
    ));
    _recomputePreview();
  }

  /// Decrement the step without clearing later selections (FR-013).
  void back() {
    if (state.stepIndex > 0) {
      Logger.data(
        'Authoring.back',
        'step ${state.stepIndex} → ${state.stepIndex - 1} '
            '(selections preserved)',
        emoji: '👈',
      );
      emit(state.copyWith(stepIndex: state.stepIndex - 1));
    }
  }

  /// Load other unmatched SMS from the same sender so the direction step can
  /// offer "Skip this message". Ordered non-deferred-first (newest-first within
  /// each group) so deferred messages sink to the end of the session queue.
  /// Bodies are enriched from the scan cache (transient — never persisted).
  Future<void> _loadSenderQueue() async {
    final all = await unmatchedSmsRepository.getActive();
    final others = all
        .where((u) =>
            u.senderId == state.source.senderId &&
            u.smsId != state.source.smsId)
        .map((u) => u.copyWith(body: u.body ?? scanService.bodyFor(u.smsId)))
        .toList()
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    final live =
        others.where((u) => !state.deferredIds.contains(u.smsId)).toList();
    final deferred =
        others.where((u) => state.deferredIds.contains(u.smsId)).toList();
    final queue = [...live, ...deferred];
    Logger.data(
      'Authoring.queue',
      '${queue.length} other(s) for sender '
          '(live=${live.length} deferred=${deferred.length})',
      emoji: '🧭',
    );
    emit(state.copyWith(senderQueue: queue));
  }

  /// Skip the current SMS and navigate to the next non-deferred same-sender
  /// message. The current smsId is added to [PatternAuthoringState.deferredIds]
  /// so it sinks to last for the rest of the session (session-only — nothing is
  /// persisted; the message stays in the unmatched queue).
  void skipToNext() {
    final target = state.senderQueue
        .firstWhere(
          (u) => !state.deferredIds.contains(u.smsId),
          orElse: () => state.source,
        );
    if (target.smsId == state.source.smsId) return;
    final newDeferred = {...state.deferredIds, state.source.smsId};
    Logger.data(
      'Authoring.skip',
      '${state.source.smsId} → ${target.smsId} '
          '(deferred=${newDeferred.length})',
      emoji: '⏭️',
    );
    emit(state.copyWith(
      skipNextSms: target,
      deferredIds: newDeferred,
    ));
  }

  void _recomputePreview() {
    final s = state;
    if (s.direction == null) {
      Logger.gray('no direction yet — preview cleared',
          name: 'Authoring.preview');
      emit(s.copyWith(clearPreview: true));
      return;
    }
    if (!_hasRequiredFieldsForDirection(s)) {
      Logger.gray(
        'required field missing for ${s.direction} — preview cleared',
        name: 'Authoring.preview',
      );
      emit(s.copyWith(clearPreview: true));
      return;
    }
    final body = s.source.body ?? '';
    final pattern = _matcher.derivePattern(
      senderId: s.source.senderId,
      exampleBody: body,
      amount: s.amount,
      balance: s.balance,
      counterparty: s.counterparty,
      direction: s.direction!,
      patternId: s.editing?.id,
      createdAt: s.editing?.createdAt,
    );
    final preview =
        _matcher.match(pattern, s.source.smsId, body, s.source.receivedAt);
    Logger.data(
      'Authoring.preview',
      preview != null
          ? 'OK amount=${preview.amount} balance=${preview.balance} '
              'cp="${preview.counterparty}"'
          : 'NULL (round-trip match failed)',
      emoji: '🧮',
    );
    emit(s.copyWith(preview: preview));
  }

  bool _hasRequiredFieldsForDirection(PatternAuthoringState s) {
    switch (s.direction) {
      case null:
        return false;
      case SmsDirection.income:
      case SmsDirection.expense:
        return s.amount != null;
      case SmsDirection.balanceCheck:
        return s.balance != null;
      case SmsDirection.ignore:
        return s.counterparty != null;
    }
  }

  Future<void> save() async {
    final s = state;
    if (s.direction == null || !_hasRequiredFieldsForDirection(s)) {
      Logger.gray('save skipped — preconditions not met',
          name: 'Authoring.save');
      return;
    }

    final isEdit = s.editing != null;
    Logger.green(
      'dir=${s.direction} edit=$isEdit'
      '${s.amount != null ? ' amount=${s.amount!.normalizedValue}' : ''}'
      '${s.balance != null ? ' balance=${s.balance!.normalizedValue}' : ''}'
      '${s.counterparty != null ? ' cp="${s.counterparty!.rawText}"' : ''}',
      name: 'Authoring.save.start',
      emoji: '💾',
    );
    emit(s.copyWith(status: PatternAuthoringStatus.saving, clearError: true));
    try {
      final body = s.source.body ?? '';
      final now = DateTime.now();
      final patternId =
          s.editing?.id ?? 'pattern-${now.microsecondsSinceEpoch}';
      final createdAt = s.editing?.createdAt ?? now;

      final derived = _matcher.derivePattern(
        senderId: s.source.senderId,
        exampleBody: body,
        amount: s.amount,
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
      Logger.data('Authoring.save.pattern', '$patternId upserted', emoji: '💾');

      // Ignore-direction patterns don't produce ledger entries — they just
      // dismiss the SMS. For income/expense/balanceCheck we parse the example
      // and persist the PatternMatch (FR-015).
      if (s.direction != SmsDirection.ignore) {
        final match = _matcher.match(
          pattern,
          s.source.smsId,
          body,
          s.source.receivedAt,
        );
        if (match != null) {
          await patternMatchRepository.upsert(match);
          Logger.data(
            'Authoring.save.match',
            'persisted PatternMatch amount=${match.amount}'
                ' balance=${match.balance} cp="${match.counterparty}"',
            emoji: '💾',
          );
          if (!isEdit) {
            await patternRepository.recordAttempt(
              patternId,
              success: true,
              matchedAt: match.matchedAt,
            );
            Logger.data(
              'Authoring.save.confidence', '+1 success', emoji: '💾');
          }
        } else {
          Logger.gray('match round-trip returned null', name: 'Authoring.save');
        }
      } else if (!isEdit) {
        // Ignore: count the teaching example as a successful match for
        // confidence display, even though no PatternMatch is created.
        await patternRepository.recordAttempt(
          patternId,
          success: true,
          matchedAt: now,
        );
        Logger.data(
          'Authoring.save.confidence', '+1 success (ignore)', emoji: '💾');
      }

      // Drop the teaching SMS from the queue (always).
      await unmatchedSmsRepository.removeBySmsId(s.source.smsId);
      Logger.data('Authoring.save.dequeue', s.source.smsId, emoji: '🗑️');

      // Re-match other still-unmatched SMS from the same sender against the
      // newly-saved pattern (and any siblings). Pass our in-memory body for
      // robustness in case the scan-service cache was cleared.
      final extraBodies = <String, String>{
        if (s.source.body != null) s.source.smsId: s.source.body!,
      };
      final remaining = await scanService.rematchSender(
        s.source.senderId,
        extraBodies: extraBodies,
      );

      // If any SMS from this sender are still unmatched, queue up the next
      // one so the wizard auto-launches into it.
      final autoNext = remaining.isEmpty ? null : remaining.first;

      Logger.green(
        'saved — ${remaining.length} still unmatched for sender'
        '${autoNext != null ? ' → autoNext=${autoNext.smsId}' : ' → pop'}',
        name: 'Authoring.save.done',
        emoji: '✅',
      );
      emit(state.copyWith(
        status: PatternAuthoringStatus.saved,
        autoNextSms: autoNext,
        clearAutoNext: autoNext == null,
        clearError: true,
      ));
    } catch (e, st) {
      Logger.error('Authoring.save.error', e, st);
      emit(state.copyWith(
        status: PatternAuthoringStatus.error,
        error: e.toString(),
      ));
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
