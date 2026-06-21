import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/features/pattern_authoring/cubit/pattern_authoring_cubit.dart';
import 'package:sms_transactions/features/pattern_authoring/cubit/pattern_authoring_state.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/authoring_summary.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/step_amount.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/step_balance.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/step_counterparty.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/step_direction.dart';
import 'package:sms_transactions/features/unmatched/cubit/unmatched_cubit.dart';

/// Single-route, cubit-driven 4-step wizard + summary (research R6). Back
/// preserves later-step annotations (FR-013); quitting the route discards
/// in-progress state. The cubit is route-scoped (provided by the router).
class PatternAuthoringScreen extends StatelessWidget {
  const PatternAuthoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatternAuthoringCubit, PatternAuthoringState>(
      listenWhen: (a, b) =>
          a.isSaved != b.isSaved ||
          (b.hasError && b.error != a.error),
      listener: (context, state) {
        if (state.isSaved) {
          // Refresh the unmatched queue + return to the list (FR-015).
          context.read<UnmatchedCubit>().refresh();
          context.pop();
          return;
        }
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not save: ${state.error}'),
              backgroundColor: context.colorScheme.errorContainer,
            ),
          );
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _handleBack(context);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handleBack(context),
            ),
            title: BlocBuilder<PatternAuthoringCubit, PatternAuthoringState>(
              buildWhen: (a, b) => a.stepIndex != b.stepIndex,
              builder: (context, state) => Text(_title(state)),
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<PatternAuthoringCubit, PatternAuthoringState>(
              builder: (context, state) {
                final cubit = context.read<PatternAuthoringCubit>();
                final body = state.source.body ?? '';
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _stepIndicator(context, state),
                    const SizedBox(height: 20),
                    _stepContent(context, state, cubit, body),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: _Footer(),
          ),
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    final cubit = context.read<PatternAuthoringCubit>();
    if (cubit.state.stepIndex > 0) {
      cubit.back();
    } else {
      context.pop();
    }
  }

  Widget _stepIndicator(BuildContext context, PatternAuthoringState state) {
    final scheme = context.colorScheme;
    final current = (state.stepIndex + 1)
        .clamp(0, PatternAuthoringState.selectionStepCount);
    return Row(
      children: [
        for (var i = 0; i < PatternAuthoringState.selectionStepCount; i++)
          Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i == 3 ? 0 : 4),
              decoration: BoxDecoration(
                color: i < current
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _stepContent(
    BuildContext context,
    PatternAuthoringState state,
    PatternAuthoringCubit cubit,
    String body,
  ) {
    switch (state.stepIndex) {
      case PatternAuthoringState.amountStep:
        return StepAmount(
          body: body,
          tokens: state.numericTokens,
          selected: state.amount,
          onSelect: cubit.selectAmount,
        );
      case PatternAuthoringState.balanceStep:
        if (state.amount == null) {
          // Reached balance without an amount (e.g. edit pre-select miss); send
          // the user back to pick one first.
          return _NeedAmountHint(onBack: cubit.back);
        }
        return StepBalance(
          body: body,
          tokens: state.numericTokens,
          amount: state.amount!,
          selected: state.balance,
          onSelect: cubit.selectBalance,
        );
      case PatternAuthoringState.directionStep:
        return StepDirection(
          selected: state.direction,
          onSelect: cubit.selectDirection,
        );
      case PatternAuthoringState.counterpartyStep:
        return StepCounterparty(
          body: body,
          tokens: state.textTokens,
          selectedTokens: state.counterpartyTokens,
          onToggle: cubit.toggleCounterpartyToken,
        );
      default:
        return AuthoringSummary(
          body: body,
          preview: state.preview,
          direction: state.direction ?? SmsDirection.expense,
          isSaving: state.isSaving,
        );
    }
  }

  String _title(PatternAuthoringState state) {
    if (state.isSummary) return 'Summary';
    return 'Step ${state.stepIndex + 1} of ${PatternAuthoringState.selectionStepCount}';
  }
}

class _NeedAmountHint extends StatelessWidget {
  final VoidCallback onBack;

  const _NeedAmountHint({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      children: [
        Icon(Icons.warning_amber_outlined, size: 40, color: scheme.error),
        const SizedBox(height: 12),
        Text('Please select an amount first.', style: context.textTheme.bodyMedium),
        const SizedBox(height: 12),
        FilledButton(onPressed: onBack, child: const Text('Back to amount')),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatternAuthoringCubit, PatternAuthoringState>(
      buildWhen: (a, b) =>
          a.stepIndex != b.stepIndex ||
          a.isSaving != b.isSaving ||
          a.status != b.status ||
          a.counterpartyTokens != b.counterpartyTokens,
      builder: (context, state) {
        final cubit = context.read<PatternAuthoringCubit>();
        switch (state.stepIndex) {
          case PatternAuthoringState.balanceStep:
            return Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.tonal(
                onPressed: () => cubit.selectBalance(null),
                child: const Text('Skip balance'),
              ),
            );
          case PatternAuthoringState.counterpartyStep:
            final hasSelection = state.counterpartyTokens.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: cubit.skipCounterparty,
                      child: const Text('Skip'),
                    ),
                  ),
                  if (hasSelection) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: cubit.confirmCounterparty,
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          default:
            if (!state.isSummary) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: state.isSaving ? null : cubit.save,
                icon: state.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(state.isEditMode ? 'Update pattern' : 'Save pattern'),
              ),
            );
        }
      },
    );
  }
}
