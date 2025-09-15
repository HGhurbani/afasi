
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_styles.dart';
import '../../../core/utils/app_colors.dart';
import '../bloc/audio_bloc.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/supplication_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/native_ad_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AudioBloc, AudioState>(
            builder: (context, state) {
              if (state is AudioLoaded) {
                return Text(state.selectedCategory, style: AppStyles.appBarTitle);
              }
              return const Text('تطبيق مشاري العفاسي', style: AppStyles.appBarTitle);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () => _showInstructions(context),
              tooltip: 'تعليمات الاستخدام',
            ),
            IconButton(
              icon: const Icon(Icons.volunteer_activism, color: Colors.white),
              onPressed: () => _showRewardedAd(context),
              tooltip: 'تبرع بمشاهدة إعلان',
            ),
            IconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Colors.white,
              ),
              tooltip: 'تغيير الوضع',
              onPressed: () {
                // Toggle theme
              },
            ),
          ],
        ),
        drawer: const DrawerWidget(),
        body: BlocBuilder<AudioBloc, AudioState>(
          builder: (context, state) {
            if (state is AudioLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AudioError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: AppColors.errorColor),
                    const SizedBox(height: 16),
                    Text(state.message, style: AppStyles.cardTitle),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AudioBloc>().add(LoadAudioCategories());
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            } else if (state is AudioLoaded) {
              return Column(
                children: [
                  SearchBarWidget(
                    categoryName: state.selectedCategory,
                    onSearch: (query) {
                      context.read<AudioBloc>().add(SearchSupplications(query));
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.filteredSupplications.length +
                          (state.filteredSupplications.length ~/ 3),
                      itemBuilder: (context, index) {
                        if (index > 0 && index % 4 == 0) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: NativeAdWidget(),
                          );
                        }

                        final int itemIndex = index - (index ~/ 4);
                        if (itemIndex >= state.filteredSupplications.length) {
                          return const SizedBox.shrink();
                        }

                        final supplication = state.filteredSupplications[itemIndex];
                        return SupplicationCard(
                          supplication: supplication,
                          isPlaying: state.currentSupplication?.title == supplication.title && state.isPlaying,
                          onPlay: () {
                            if (state.currentSupplication?.title == supplication.title && state.isPlaying) {
                              context.read<AudioBloc>().add(PauseAudio());
                            } else {
                              context.read<AudioBloc>().add(PlayAudio(supplication));
                            }
                          },
                          onDownload: () => _downloadAudio(context, supplication),
                          onToggleFavorite: () => _toggleFavorite(context, supplication),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        bottomNavigationBar: BlocBuilder<AudioBloc, AudioState>(
          builder: (context, state) {
            if (state is AudioLoaded && state.currentSupplication != null) {
              return AudioPlayerWidget(
                supplication: state.currentSupplication!,
                isPlaying: state.isPlaying,
                isRepeat: state.isRepeat,
                isAutoNext: state.isAutoNext,
                position: state.position,
                duration: state.duration,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تعليمات الاستخدام'),
        content: const SingleChildScrollView(
          child: Text(
            'مرحباً بك في تطبيق مشاري العفاسي.\n\n'
            'كيفية الاستخدام:\n'
            '1. استخدم القائمة الجانبية لتحديد قسم الصوتيات\n'
            '2. استخدم حقل البحث لتصفية قائمة الصوتيات\n'
            '3. اضغط على زر التشغيل لتشغيل الصوت\n'
            '4. يمكنك تنزيل الصوت للاستماع دون إنترنت\n'
            '5. أضف الصوتيات إلى المفضلة باستخدام أيقونة القلب',
            textDirection: TextDirection.rtl,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showRewardedAd(BuildContext context) {
    // Implement rewarded ad logic
  }

  void _downloadAudio(BuildContext context, supplication) {
    // Implement download logic
  }

  void _toggleFavorite(BuildContext context, supplication) {
    // Implement favorite toggle logic
  }
}
