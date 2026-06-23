import 'package:flutter/material.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';

/// Shared header for each authoring step: a leading icon (so the user can
/// identify the step at a glance — e.g. amount vs. balance — without reading
/// the description), followed by the title and a one-line subtitle.
class StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const StepHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: scheme.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(title, style: context.textTheme.titleMedium),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
