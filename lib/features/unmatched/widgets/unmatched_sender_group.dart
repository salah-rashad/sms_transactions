import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';
import 'package:sms_transactions/domain/models/unmatched_sms.dart';

import '../../pattern_authoring/widgets/token_chip.dart';

/// One sender's group of unmatched SMS (FR-005..007): sender header, count,
/// a preview of each message + timestamp, and Teach / Dismiss actions.
class UnmatchedSenderGroup extends StatelessWidget {
  final String senderId;
  final List<UnmatchedSms> messages;

  /// Teach the app a pattern for this sender (navigates to the authoring
  /// wizard with the first/selected message). Required for FR-006.
  final ValueChanged<UnmatchedSms> onTeach;

  /// Dismiss / "Not a transaction" (US3): suppress the sender (FR-017).
  final ValueChanged<String> onDismiss;

  const UnmatchedSenderGroup({
    super.key,
    required this.senderId,
    required this.messages,
    required this.onTeach,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final newest = messages.first;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.sms_outlined, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderId,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        messages.length == 1
                            ? '1 message'
                            : '${messages.length} messages',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Not a transaction',
                  icon: const Icon(Icons.block_flipped, size: 20),
                  onPressed: () => onDismiss(senderId),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: messages.length > 3 ? 3 : messages.length,
              separatorBuilder: (context, index) => Divider(
                height: 8,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) =>
                  _MessagePreview(message: messages[index]),
            ),
            if (messages.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  '+${messages.length - 3} more',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => onTeach(newest),
                    icon: const Icon(Icons.school_outlined, size: 18),
                    label: const Text('Teach'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagePreview extends StatelessWidget {
  final UnmatchedSms message;

  const _MessagePreview({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final body = message.body;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Directionality(
            textDirection: detectBaseDirection(body ?? ""),
            child: Text(
              body == null || body.isEmpty
                  ? '(preview unavailable until scan)'
                  : body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          DateFormat('dd MMM, HH:mm').format(message.receivedAt),
          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
