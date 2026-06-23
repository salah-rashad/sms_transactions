import 'package:sms_transactions/domain/models/pattern_match.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/domain/models/sms_token.dart';
import 'package:sms_transactions/domain/models/unmatched_sms.dart';

enum PatternAuthoringStatus { editing, saving, saved, error }

/// One UI step in the authoring wizard. The active step plan depends on the
/// chosen [SmsDirection] — see [PatternAuthoringState.activeSteps].
enum AuthoringStep { direction, amount, balance, counterparty, summary }

/// Immutable state for the direction-first authoring wizard + summary.
/// `back()` decrements [stepIndex] without clearing later selections (FR-013).
class PatternAuthoringState {
  final UnmatchedSms source;
  final SmsPattern? editing;

  final List<NumericToken> numericTokens;
  final List<TextToken> textTokens;

  final int stepIndex;
  final NumericToken? amount;
  final NumericToken? balance;
  final SmsDirection? direction;
  final List<TextToken> counterpartyTokens;
  final TextToken? counterparty;

  /// Live preview of how the derived pattern will parse the example (FR-014).
  final PatternMatch? preview;

  /// After [save] succeeds, the next unmatched SMS from the same sender that
  /// the wizard should auto-launch to keep teaching back-to-back. Null when
  /// the sender's queue is empty after re-matching.
  final UnmatchedSms? autoNextSms;

  final PatternAuthoringStatus status;
  final String? error;

  const PatternAuthoringState({
    required this.source,
    this.editing,
    this.numericTokens = const [],
    this.textTokens = const [],
    this.stepIndex = 0,
    this.amount,
    this.balance,
    this.direction,
    this.counterpartyTokens = const [],
    this.counterparty,
    this.preview,
    this.autoNextSms,
    this.status = PatternAuthoringStatus.editing,
    this.error,
  });

  bool get isEditMode => editing != null;
  bool get isDirection => currentStep == AuthoringStep.direction;
  bool get isSummary => currentStep == AuthoringStep.summary;
  bool get isSaving => status == PatternAuthoringStatus.saving;
  bool get isSaved => status == PatternAuthoringStatus.saved;
  bool get hasError => status == PatternAuthoringStatus.error;

  /// The sequence of steps the wizard shows for the currently-selected
  /// direction. Direction is step 0; once it's chosen, the primary value step
  /// (amount/balance/counterparty) is step 1, then optional steps, then
  /// summary.
  List<AuthoringStep> get activeSteps {
    switch (direction) {
      case null:
        return const [AuthoringStep.direction];
      case SmsDirection.income:
      case SmsDirection.expense:
        return const [
          AuthoringStep.direction,
          AuthoringStep.amount,
          AuthoringStep.balance,
          AuthoringStep.counterparty,
          AuthoringStep.summary,
        ];
      case SmsDirection.balanceCheck:
        return const [
          AuthoringStep.direction,
          AuthoringStep.balance,
          AuthoringStep.counterparty,
          AuthoringStep.summary,
        ];
      case SmsDirection.ignore:
        return const [
          AuthoringStep.direction,
          AuthoringStep.counterparty,
          AuthoringStep.summary,
        ];
    }
  }

  AuthoringStep get currentStep {
    final steps = activeSteps;
    if (stepIndex < 0) return steps.first;
    if (stepIndex >= steps.length) return steps.last;
    return steps[stepIndex];
  }

  /// Count of pickable steps (excludes the summary) for the "Step X of N"
  /// header.
  int get selectionStepCount => activeSteps.length;

  /// Whether the current step's required input is satisfied (enables Continue).
  bool get canContinueCurrentStep {
    switch (currentStep) {
      case AuthoringStep.direction:
        return direction != null;
      case AuthoringStep.amount:
        return amount != null;
      case AuthoringStep.balance:
        // Required when balance is the primary value (balanceCheck), optional
        // otherwise.
        return direction == SmsDirection.balanceCheck ? balance != null : true;
      case AuthoringStep.counterparty:
        // Required when counterparty is the primary identifier (ignore),
        // optional otherwise.
        return direction == SmsDirection.ignore
            ? counterpartyTokens.isNotEmpty
            : true;
      case AuthoringStep.summary:
        return false;
    }
  }

  PatternAuthoringState copyWith({
    UnmatchedSms? source,
    SmsPattern? editing,
    List<NumericToken>? numericTokens,
    List<TextToken>? textTokens,
    int? stepIndex,
    NumericToken? amount,
    NumericToken? balance,
    SmsDirection? direction,
    List<TextToken>? counterpartyTokens,
    TextToken? counterparty,
    PatternMatch? preview,
    UnmatchedSms? autoNextSms,
    PatternAuthoringStatus? status,
    String? error,
    bool clearAmount = false,
    bool clearBalance = false,
    bool clearDirection = false,
    bool clearCounterparty = false,
    bool clearPreview = false,
    bool clearAutoNext = false,
    bool clearError = false,
  }) {
    final resolvedTokens = clearCounterparty
        ? const <TextToken>[]
        : (counterpartyTokens ?? this.counterpartyTokens);
    return PatternAuthoringState(
      source: source ?? this.source,
      editing: editing ?? this.editing,
      numericTokens: numericTokens ?? this.numericTokens,
      textTokens: textTokens ?? this.textTokens,
      stepIndex: stepIndex ?? this.stepIndex,
      amount: clearAmount ? null : (amount ?? this.amount),
      balance: clearBalance ? null : (balance ?? this.balance),
      direction: clearDirection ? null : (direction ?? this.direction),
      counterpartyTokens: resolvedTokens,
      counterparty: clearCounterparty
          ? null
          : (counterparty ?? this.counterparty),
      preview: clearPreview ? null : (preview ?? this.preview),
      autoNextSms: clearAutoNext ? null : (autoNextSms ?? this.autoNextSms),
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
    );
  }
}
