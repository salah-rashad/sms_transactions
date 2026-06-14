import 'package:flutter/material.dart';
import 'package:sms_transactions/core/extensions/build_context.dart';

class YearMonthPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onChanged;

  const YearMonthPicker({
    super.key,
    required this.initialDate,
    required this.onChanged,
  });

  @override
  State<YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<YearMonthPicker> {
  late int _selectedYear;
  late int _selectedMonth;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _selectedYear--),
            ),
            Text(
              '$_selectedYear',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _selectedYear++),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 12,
            itemBuilder: (ctx, index) {
              final month = index + 1;
              final isSelected = month == _selectedMonth;
              return InkWell(
                onTap: () {
                  setState(() => _selectedMonth = month);
                  widget.onChanged(DateTime(_selectedYear, month));
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? scheme.primary : null,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? scheme.primary : scheme.outlineVariant,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _months[index],
                      style: TextStyle(
                        color: isSelected ? scheme.onPrimary : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
}) {
  DateTime tempDate = initialDate;

  return showDialog<DateTime>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Select Month'),
        content: SizedBox(
          width: 300,
          height: 250,
          child: YearMonthPicker(
            initialDate: initialDate,
            onChanged: (date) => tempDate = date,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, tempDate),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
