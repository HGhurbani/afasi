import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/di/injection.dart';
import '../cubit/prayer_times_cubit.dart';

class PrayerTimesPage extends StatelessWidget {
  static const routeName = '/prayer-times';

  const PrayerTimesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PrayerTimesCubit>()..initialize(),
      child: const _PrayerTimesView(),
    );
  }
}

class _PrayerTimesView extends StatelessWidget {
  const _PrayerTimesView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrayerTimesCubit, PrayerTimesState>(
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
        context.read<PrayerTimesCubit>().clearMessages();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('أوقات الصلاة'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث الأوقات',
              onPressed: () =>
                  context.read<PrayerTimesCubit>().refreshPrayerTimes(),
            ),
          ],
        ),
        body: BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.prayerTimes == null) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'تعذر تحميل أوقات الصلاة.',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final colorScheme = Theme.of(context).colorScheme;

            final prayers = [
              {
                'name': 'الفجر',
                'time': state.prayerTimes!.fajr,
                'icon': Icons.nightlight_round,
              },
              {
                'name': 'الشروق',
                'time': state.prayerTimes!.sunrise,
                'icon': Icons.wb_twilight,
              },
              {
                'name': 'الظهر',
                'time': state.prayerTimes!.dhuhr,
                'icon': Icons.wb_sunny,
              },
              {
                'name': 'العصر',
                'time': state.prayerTimes!.asr,
                'icon': Icons.access_time,
              },
              {
                'name': 'المغرب',
                'time': state.prayerTimes!.maghrib,
                'icon': Icons.nights_stay,
              },
              {
                'name': 'العشاء',
                'time': state.prayerTimes!.isha,
                'icon': Icons.brightness_3,
              },
            ];

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                child: RefreshIndicator(
                  onRefresh: () => context
                      .read<PrayerTimesCubit>()
                      .refreshPrayerTimes(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                    // Header card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                              Icons.mosque,
                              size: 48,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'أوقات الصلاة',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              intl.DateFormat('EEEE, d MMMM yyyy', 'ar').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Prayer times cards
                    ...prayers.map((prayer) {
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.95),
                              ],
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            leading: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                prayer['icon'] as IconData,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              prayer['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'Tajawal',
                                color: Color(0xFF1C1B1F),
                              ),
                            ),
                            subtitle: Text(
                              _formatTime(prayer['time'] as DateTime),
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Tajawal',
                                color: Color(0xFF49454F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatTime(prayer['time'] as DateTime),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSecondaryContainer,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    
                    // Notification toggle card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: state.notificationsEnabled
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceVariant,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              state.notificationsEnabled
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              size: 32,
                              color: state.notificationsEnabled
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.notificationsEnabled
                                  ? 'تم تفعيل تنبيهات الصلاة'
                                  : 'تنبيهات الصلاة معطلة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: state.notificationsEnabled
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                                fontFamily: 'Tajawal',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .read<PrayerTimesCubit>()
                                  .toggleNotifications(),
                              icon: Icon(
                                state.notificationsEnabled
                                    ? Icons.notifications_off
                                    : Icons.notifications_active,
                                size: 20,
                              ),
                              label: Text(
                                state.notificationsEnabled
                                    ? 'إلغاء التنبيهات'
                                    : 'تفعيل التنبيهات',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: state.notificationsEnabled
                                    ? colorScheme.error
                                    : colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return intl.DateFormat('h:mm a', 'ar').format(dateTime);
  }
}
