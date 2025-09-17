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
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: BlocBuilder<AdhkarReminderCubit, AdhkarReminderState>(
              builder: (context, state) {
                final colorScheme = Theme.of(context).colorScheme;
                
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header card
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primaryContainer,
                                  colorScheme.primaryContainer.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.alarm_on,
                                  size: 48,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'منبه الأذكار',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'اجعل الذكر جزءاً من يومك',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                                    fontFamily: 'Tajawal',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Morning reminder card
                        _buildReminderCard(
                          context,
                          title: 'تذكير أذكار الصباح',
                          time: state.morningTime,
                          enabled: state.morningEnabled,
                          icon: Icons.wb_sunny,
                          color: const Color(0xFFFFB300),
                          onToggle: (value) => context.read<AdhkarReminderCubit>().toggleMorning(value),
                          onTimeSelect: () => _selectTime(context, true, state.morningTime),
                        ),
                        const SizedBox(height: 16),
                        
                        // Evening reminder card
                        _buildReminderCard(
                          context,
                          title: 'تذكير أذكار المساء',
                          time: state.eveningTime,
                          enabled: state.eveningEnabled,
                          icon: Icons.nights_stay,
                          color: const Color(0xFF1565C0),
                          onToggle: (value) => context.read<AdhkarReminderCubit>().toggleEvening(value),
                          onTimeSelect: () => _selectTime(context, false, state.eveningTime),
                        ),
                        
                        const Spacer(),
                        
                        // Info card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'اضغط على البطاقة لتغيير الوقت واستخدم المفتاح لتفعيل أو إلغاء التنبيه',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context, {
    required String title,
    required TimeOfDay time,
    required bool enabled,
    required IconData icon,
    required Color color,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeSelect,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: enabled ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: enabled
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                )
              : null,
          border: enabled
              ? Border.all(color: color.withOpacity(0.3), width: 1)
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTimeSelect,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: enabled ? color : colorScheme.outline,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: enabled
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: enabled
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withOpacity(0.6),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: enabled ? color : colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time.format(context),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: enabled ? color : colorScheme.outline,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                      if (enabled)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'مفعل',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onToggle,
                  activeColor: color,
                  activeTrackColor: color.withOpacity(0.3),
                ),
              ],
            ),
          ),
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
