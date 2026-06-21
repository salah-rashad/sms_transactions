import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/features/unmatched/cubit/unmatched_cubit.dart';
import 'package:sms_transactions/features/unmatched/cubit/unmatched_state.dart';
import 'package:sms_transactions/features/unmatched/widgets/unmatched_sender_group.dart';

/// Grouped review list for unmatched SMS (US1, FR-005..007). Tap Teach to start
/// authoring a pattern for a sender (`/unmatched/teach`, US2); tap Dismiss to
/// suppress the sender (US3).
class UnmatchedScreen extends StatelessWidget {
  const UnmatchedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unmatched Messages')),
      body: BlocBuilder<UnmatchedCubit, UnmatchedState>(
        builder: (context, state) {
          if (state.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: context.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error ?? 'Something went wrong',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          context.read<UnmatchedCubit>().runLaunchScan(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final groups = state.groupedBySender;
          if (groups.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<UnmatchedCubit>().refresh(),
              child: ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.inbox_rounded,
                    size: 64,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      state.isScanning ? 'Scanning inbox…' : 'All caught up',
                      style: TextStyle(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<UnmatchedCubit>().refresh(),
            child: ListView(
              children: [
                if (state.isScanning)
                  const LinearProgressIndicator(minHeight: 2),
                for (final entry in groups.entries)
                  UnmatchedSenderGroup(
                    senderId: entry.key,
                    messages: entry.value,
                    onTeach: (sms) =>
                        context.push('/unmatched/teach', extra: sms),
                    onDismiss: (senderId) => _confirmDismiss(context, senderId),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDismiss(BuildContext context, String senderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Not a transaction?'),
        content: Text(
          'Future SMS from $senderId will be hidden from the unmatched queue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<UnmatchedCubit>().dismissSender(senderId);
    }
  }
}
