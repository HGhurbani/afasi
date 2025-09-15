import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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

            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final gradientColors = isDarkMode
                ? [Colors.black87, Colors.black54]
                : [const Color(0xFF3498DB), const Color(0xFF2980B9)];
            final iconBackgroundColor =
                isDarkMode ? Colors.grey[800] : const Color(0xFF3498DB);

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

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...prayers.map((prayer) {
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: iconBackgroundColor,
                          child: Icon(prayer['icon'] as IconData,
                              color: Colors.white),
                        ),
                        title: Text(
                          prayer['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          _formatTime(prayer['time'] as DateTime),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.read<PrayerTimesCubit>().toggleNotifications(),
                      icon: Icon(state.notificationsEnabled
                          ? Icons.notifications_off
                          : Icons.notifications_active),
                      label: Text(state.notificationsEnabled
                          ? 'إلغاء تنبيهات الصلاة'
                          : 'تفعيل تنبيهات الصلاة'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Tajawal',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a', 'ar').format(dateTime);
  }
}
