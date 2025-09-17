import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../cubit/adhkar_reminder_cubit.dart';

class AdhkarReminderPage extends StatelessWidget {
  static const routeName = '/adhkar-reminder';

  const AdhkarReminderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdhkarReminderCubit>()..initialize(),
      child: const _AdhkarReminderView(),
    );
  }
}

class _AdhkarReminderView extends StatelessWidget {
  const _AdhkarReminderView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdhkarReminderCubit, AdhkarReminderState>(
      listenWhen: (previous, current) =>
          previous.statusMessage != current.statusMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.statusMessage != null) {
          messenger.showSnackBar(SnackBar(content: Text(state.statusMessage!)));
        }
        if (state.errorMessage != null) {
          messenger.showSnackBar(
            SnackBar(content: Text('حدث خطأ: ${state.errorMessage}')),
          );
        }
        context.read<AdhkarReminderCubit>().clearMessages();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('منبة الأذكار'),
        ),
        body: BlocBuilder<AdhkarReminderCubit, AdhkarReminderState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('تذكير أذكار الصباح'),
                      subtitle: Text('الوقت: ${state.morningTime.format(context)}'),
                      trailing: Switch(
                        value: state.morningEnabled,
                        onChanged: (value) =>
                            context.read<AdhkarReminderCubit>().toggleMorning(value),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () => _selectTime(context, true, state.morningTime),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Card(
                    child: ListTile(
                      title: const Text('تذكير أذكار المساء'),
                      subtitle: Text('الوقت: ${state.eveningTime.format(context)}'),
                      trailing: Switch(
                        value: state.eveningEnabled,
                        onChanged: (value) =>
                            context.read<AdhkarReminderCubit>().toggleEvening(value),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () => _selectTime(context, false, state.eveningTime),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isMorning, TimeOfDay initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final buttonTextColor = isDark ? colorScheme.secondary : colorScheme.primary;
        final helpTextColor = isDark ? colorScheme.onSurface : colorScheme.onSurfaceVariant;

        return Theme(
          data: theme.copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: buttonTextColor,
              ),
            ),
            timePickerTheme: theme.timePickerTheme.copyWith(
              helpTextStyle: theme.timePickerTheme.helpTextStyle?.copyWith(
                    color: helpTextColor,
                  ) ??
                  TextStyle(color: helpTextColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isMorning) {
        await context.read<AdhkarReminderCubit>().updateMorningTime(picked);
      } else {
        await context.read<AdhkarReminderCubit>().updateEveningTime(picked);
      }
    }
  }
}
