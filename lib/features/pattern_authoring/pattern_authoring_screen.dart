import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/core/utils/logger.dart';
import 'package:sms_transactions/domain/models/sms_pattern.dart';
import 'package:sms_transactions/features/pattern_authoring/cubit/pattern_authoring_cubit.dart';
import 'package:sms_transactions/features/pattern_authoring/cubit/pattern_authoring_state.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/authoring_summary.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/step_amount.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/step_balance.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/step_counterparty.dart';
import 'package:sms_transactions/features/pattern_authoring/widgets/step_direction.dart';
import 'package:sms_transactions/features/unmatched/cubit/unmatched_cubit.dart';

/// Single-route, cubit-driven authoring wizard. The step sequence is derived
/// from the chosen direction (see [PatternAuthoringState.activeSteps]). Back
/// preserves later-step annotations (FR-013); quitting discards in-progress
/// state. The cubit is route-scoped (provided by the router).
class PatternAuthoringScreen extends StatelessWidget {
  const PatternAuthoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatternAuthoringCubit, PatternAuthoringState>(
      listenWhen: (a, b) =>
          a.isSaved != b.isSaved || (b.hasError && b.error != a.error),
      listener: (context, state) {
        if (state.isSaved) {
          // Refresh the unmatched queue → if there's a next SMS waiting from
          // the same sender, keep teaching back-to-back; otherwise pop back.
          context.read<UnmatchedCubit>().refresh();
          final next = state.autoNextSms;
          if (next != null) {
            Logger.data(
              'Authoring.nav',
              'auto-next SMS=${next.smsId}',
              emoji: '🚀',
            );
            context.pushReplacement('/unmatched/teach', extra: next);
          } else {
            Logger.data('Authoring.nav', 'queue empty → pop', emoji: '👈');
            context.pop();
          }
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
              buildWhen: (a, b) =>
                  a.stepIndex != b.stepIndex || a.direction != b.direction,
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
          bottomNavigationBar: const SafeArea(child: _Footer()),
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
    final total = max(1, state.selectionStepCount);
    // if (total <= 0) {
    //   return const SizedBox.shrink();
    // }
    final current = (state.stepIndex + 1).clamp(0, total);
    return Row(
      children: [
        for (var i = 0; i < total; i++)
          Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
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
    switch (state.currentStep) {
      case AuthoringStep.direction:
        return StepDirection(
          body: body,
          selected: state.direction,
          onSelect: cubit.selectDirection,
        );
      case AuthoringStep.amount:
        return StepAmount(
          body: body,
          tokens: state.numericTokens,
          selected: state.amount,
          onSelect: cubit.selectAmount,
        );
      case AuthoringStep.balance:
        return StepBalance(
          body: body,
          tokens: state.numericTokens,
          amount: state.amount,
          selected: state.balance,
          onSelect: cubit.selectBalance,
          isPrimary: state.direction == SmsDirection.balanceCheck,
        );
      case AuthoringStep.counterparty:
        return StepCounterparty(
          body: body,
          tokens: state.textTokens,
          selectedTokens: state.counterpartyTokens,
          onToggle: cubit.toggleCounterpartyToken,
          isIdentifier: state.direction == SmsDirection.ignore,
        );
      case AuthoringStep.summary:
        return AuthoringSummary(
          body: body,
          preview: state.preview,
          direction: state.direction ?? SmsDirection.expense,
          isSaving: state.isSaving,
        );
    }
  }

  String _title(PatternAuthoringState state) {
    if (state.isDirection) return 'Select direction';
    if (state.isSummary) return 'Summary';
    return 'Step ${state.stepIndex + 1} of ${state.selectionStepCount}';
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatternAuthoringCubit, PatternAuthoringState>(
      buildWhen: (a, b) =>
          a.stepIndex != b.stepIndex ||
          a.direction != b.direction ||
          a.isSaving != b.isSaving ||
          a.status != b.status ||
          a.counterpartyTokens != b.counterpartyTokens,
      builder: (context, state) {
        final cubit = context.read<PatternAuthoringCubit>();
        switch (state.currentStep) {
          case AuthoringStep.direction:
            // Direction tiles advance on tap; no footer action.
            return const SizedBox.shrink();
          case AuthoringStep.amount:
            return const SizedBox.shrink();
          case AuthoringStep.balance:
            // Skip allowed only when balance is OPTIONAL (income/expense).
            if (state.direction == SmsDirection.balanceCheck) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.tonal(
                onPressed: () => cubit.selectBalance(null),
                child: const Text('Skip balance'),
              ),
            );
          case AuthoringStep.counterparty:
            final isIdentifier = state.direction == SmsDirection.ignore;
            final hasSelection = state.counterpartyTokens.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (!isIdentifier)
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: cubit.skipCounterparty,
                        child: const Text('Skip'),
                      ),
                    ),
                  if (!isIdentifier && hasSelection) const SizedBox(width: 12),
                  if (hasSelection)
                    Expanded(
                      child: FilledButton(
                        onPressed: cubit.confirmCounterparty,
                        child: const Text('Continue'),
                      ),
                    ),
                ],
              ),
            );
          case AuthoringStep.summary:
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
                label: Text(
                  state.isEditMode ? 'Update pattern' : 'Save pattern',
                ),
              ),
            );
        }
      },
    );
  }
}
