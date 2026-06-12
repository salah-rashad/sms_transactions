import 'package:shadcn_flutter/shadcn_flutter.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final Widget value;
  final Color color;
  final IconData icon;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Gap(8),
              Text(title).muted.small,
            ],
          ),
          const Gap(8),
          DefaultTextStyle(
            style: Theme.of(context).typography.xLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            child: value,
          ),
        ],
      ),
    );
  }
}
