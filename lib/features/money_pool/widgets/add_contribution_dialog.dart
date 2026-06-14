import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sms_transactions/features/money_pool/cubit/money_pool_cubit.dart';
import 'package:sms_transactions/features/money_pool/widgets/year_month_picker.dart';

void showAddContributionDialog(BuildContext context) {
  final amountController = TextEditingController(text: '10000');
  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Add Contribution'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (EGP)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat.yMMMM().format(selectedDate)),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final picked = await showMonthPicker(
                      context: ctx,
                      initialDate: selectedDate,
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) return;
                  context.read<MoneyPoolCubit>().addContribution(
                    amount,
                    selectedDate,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
