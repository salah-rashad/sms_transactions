import 'package:sms_transactions/domain/models/pattern_match.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/domain/models/sms_token.dart';
import 'package:sms_transactions/domain/models/unmatched_sms.dart';

enum PatternAuthoringStatus { editing, saving, saved, error }

/// Immutable state for the 4-step authoring wizard + summary (FR-008..014).
/// See `contracts/cubits.contract.md`.
///
/// Step indices: 0=amount, 1=balance, 2=direction, 3=counterparty, 4=summary.
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
    this.status = PatternAuthoringStatus.editing,
    this.error,
  });

  bool get isEditMode => editing != null;
  bool get isSummary => stepIndex == _summaryIndex;
  bool get isSaving => status == PatternAuthoringStatus.saving;
  bool get isSaved => status == PatternAuthoringStatus.saved;
  bool get hasError => status == PatternAuthoringStatus.error;

  static const int amountStep = 0;
  static const int balanceStep = 1;
  static const int directionStep = 2;
  static const int counterpartyStep = 3;
  static const int _summaryIndex = 4;

  /// Total selection steps (for "Step X of N" counter, FR-013).
  static const int selectionStepCount = 4;

  /// Whether the current step's required input is satisfied (enables Continue).
  bool get canContinueCurrentStep {
    switch (stepIndex) {
      case amountStep:
        return amount != null;
      case balanceStep:
        return true; // optional (skip allowed)
      case directionStep:
        return direction != null;
      case counterpartyStep:
        return true; // optional (skip allowed)
      default:
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
    PatternAuthoringStatus? status,
    String? error,
    bool clearAmount = false,
    bool clearBalance = false,
    bool clearDirection = false,
    bool clearCounterparty = false,
    bool clearPreview = false,
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
      counterparty:
          clearCounterparty ? null : (counterparty ?? this.counterparty),
      preview: clearPreview ? null : (preview ?? this.preview),
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
    );
  }
}
