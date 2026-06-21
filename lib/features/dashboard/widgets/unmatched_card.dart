import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/features/unmatched/cubit/unmatched_cubit.dart';
import 'package:sms_transactions/features/unmatched/cubit/unmatched_state.dart';

/// Dashboard card surfacing unmatched SMS (FR-001..004). Visible iff the count
/// is greater than zero (FR-001/003/004). Shows the persisted count + a Review
/// CTA; a small spinner while a background scan is running (R9).
class UnmatchedCard extends StatelessWidget {
  const UnmatchedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnmatchedCubit, UnmatchedState>(
      buildWhen: (a, b) => a.count != b.count || a.isScanning != b.isScanning,
      builder: (context, state) {
        if (state.count <= 0) return const SizedBox.shrink();
        final scheme = context.colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Card(
            elevation: 2,
            color: context.appColors.warning.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.inbox_outlined, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.count == 1
                              ? '1 unmatched message'
                              : '${state.count} unmatched messages',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Teach the app to parse new senders',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.isScanning)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  FilledButton(
                    onPressed: () => context.push('/unmatched'),
                    child: const Text('Review'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
