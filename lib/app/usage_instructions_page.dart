import 'package:flutter/material.dart';
import 'app.dart';

class UsageInstructionsPage extends StatefulWidget {
  static const String routeName = '/usage-instructions';

  const UsageInstructionsPage({super.key});

  @override
  State<UsageInstructionsPage> createState() => _UsageInstructionsPageState();
}

class _UsageInstructionsPageState extends State<UsageInstructionsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(8, (index) => GlobalKey());

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'مكتبة الصوتيات',
      'icon': Icons.library_music,
      'description': 'تصفح الأقسام المختلفة والاستماع للأذكار والأدعية',
    },
    {
      'title': 'الصور والخلفيات',
      'icon': Icons.wallpaper,
      'description': 'استعرض خلفيات إسلامية مميزة ومتجددة',
    },
    {
      'title': 'منبه الأذكار',
      'icon': Icons.notifications_active,
      'description': 'فعّل التذكير بالأذكار اليومية',
    },
    {
      'title': 'أوقات الصلاة',
      'icon': Icons.mosque,
      'description': 'اعرض مواقيت الصلاة حسب مدينتك',
    },
    {
      'title': 'المسبحة الإلكترونية',
      'icon': Icons.touch_app,
      'description': 'عدّ أذكارك بسهولة وزد/صفّر العداد',
    },
    {
      'title': 'دعم التطبيق',
      'icon': Icons.volunteer_activism,
      'description': 'ادعم التطوير بمشاهدة إعلان مكافآت',
    },
    {
      'title': 'تطبيق القرآن الكريم',
      'icon': Icons.menu_book,
      'description': 'انتقل لمتجر Play لتحميل تطبيق القرآن',
    },
    {
      'title': 'المظهر واللغة',
      'icon': Icons.palette,
      'description': 'بدّل بين الوضع الفاتح والداكن',
    },
  ];

  void _scrollToSection(int index) {
    if (index < _sectionKeys.length) {
      Scrollable.ensureVisible(
        _sectionKeys[index].currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تعليمات الاستخدام',
            style: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.volunteer_activism, color: Colors.white),
              onPressed: () => myAppKey.currentState?.confirmAndShowRewardedAd(),
              tooltip: 'تبرع بمشاهدة إعلان',
            ),
            IconButton(
              icon: Icon(
                myAppKey.currentState?.isDarkMode == true
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Colors.white,
              ),
              tooltip: 'تغيير الوضع',
              onPressed: myAppKey.currentState?.toggleTheme,
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Determine if we should show sidebar based on screen width
            final bool showSidebar = constraints.maxWidth > 800;
            
            if (showSidebar) {
              // Desktop/Tablet layout with sidebar
              return Row(
                children: [
                  // Sidebar with table of contents
                  Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      border: Border(
                        left: BorderSide(
                          color: colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'قائمة المحتويات',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _sections.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Icon(
                                  _sections[index]['icon'],
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                title: Text(
                                  _sections[index]['title'],
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                onTap: () => _scrollToSection(index),
                                dense: true,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      child: _buildMainContent(),
                    ),
                  ),
                ],
              );
            } else {
              // Mobile layout with collapsible drawer
              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mobile table of contents
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.menu,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'قائمة المحتويات',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _sections.asMap().entries.map((entry) {
                              final index = entry.key;
                              final section = entry.value;
                              return GestureDetector(
                                onTap: () => _scrollToSection(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: colorScheme.primary.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        section['icon'],
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        section['title'],
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 12,
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    // Main content
                    _buildMainContent(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.secondary.withOpacity(0.05),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.home,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'مرحباً بك في تطبيق أذكار وأدعية',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'بصوت الشيخ مشاري العفاسي',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'يحتوي التطبيق على عدة ميزات رئيسية. اتبع الخطوات التالية للاستفادة منها:',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Audio Library Section
        _buildSection(
          key: _sectionKeys[0],
          title: 'مكتبة الصوتيات',
          icon: Icons.library_music,
          color: Colors.blue,
          children: [
            _buildFeatureItem(
              icon: Icons.folder_open,
              title: 'تصفح الأقسام',
              description: 'القرآن الكريم، الأناشيد، الأذكار، الأدعية، الرقية الشرعية...',
            ),
            _buildFeatureItem(
              icon: Icons.search,
              title: 'البحث والتصفية',
              description: 'استخدم البحث لتصفية العناصر داخل القسم الحالي',
            ),
            _buildFeatureItem(
              icon: Icons.play_arrow,
              title: 'التشغيل المباشر',
              description: 'شغّل المقطع مباشرة عبر الإنترنت أو من المصدر المحلي',
            ),
            _buildFeatureItem(
              icon: Icons.download,
              title: 'التحميل للاستماع دون إنترنت',
              description: 'حمّل المقطع للاستماع دون إنترنت عند توفر زر التحميل',
            ),
            _buildFeatureItem(
              icon: Icons.menu_book,
              title: 'قراءة النص المرافق',
              description: 'افتح النص المرافق عبر زر "قراءة" مع دعم تكبير/تصغير الخط',
            ),
            _buildFeatureItem(
              icon: Icons.favorite,
              title: 'المفضلات',
              description: 'أضف للمفضلة عبر أيقونة القلب، وستظهر المفضلات في الرئيسية',
            ),
          ],
        ),

        // Wallpapers Section
        _buildSection(
          key: _sectionKeys[1],
          title: 'الصور والخلفيات',
          icon: Icons.wallpaper,
          color: Colors.purple,
          children: [
            _buildFeatureItem(
              icon: Icons.image,
              title: 'استعرض الخلفيات',
              description: 'استعرض خلفيات إسلامية مميزة ومتجددة',
            ),
            _buildFeatureItem(
              icon: Icons.fullscreen,
              title: 'عرض كامل الشاشة',
              description: 'افتح الصورة بكامل الشاشة واحفظها أو اجعلها خلفية',
            ),
          ],
        ),

        // Adhkar Reminder Section
        _buildSection(
          key: _sectionKeys[2],
          title: 'منبه الأذكار',
          icon: Icons.notifications_active,
          color: Colors.orange,
          children: [
            _buildFeatureItem(
              icon: Icons.alarm,
              title: 'تفعيل التذكير',
              description: 'فعّل التذكير بالأذكار اليومية',
            ),
            _buildFeatureItem(
              icon: Icons.notifications,
              title: 'الإشعارات',
              description: 'يمنحك التطبيق إشعارات في الأوقات المحددة. قد تحتاج لمنح إذن الإشعارات',
            ),
          ],
        ),

        // Prayer Times Section
        _buildSection(
          key: _sectionKeys[3],
          title: 'أوقات الصلاة',
          icon: Icons.mosque,
          color: Colors.green,
          children: [
            _buildFeatureItem(
              icon: Icons.location_on,
              title: 'عرض المواقيت',
              description: 'اعرض مواقيت الصلاة حسب مدينتك',
            ),
            _buildFeatureItem(
              icon: Icons.location_searching,
              title: 'تحديد الموقع',
              description: 'قد تحتاج لمنح إذن الوصول للموقع لتحديد المدينة بدقة وتفعيل إشعارات الأذان',
            ),
          ],
        ),

        // Tasbih Section
        _buildSection(
          key: _sectionKeys[4],
          title: 'المسبحة الإلكترونية',
          icon: Icons.touch_app,
          color: Colors.teal,
          children: [
            _buildFeatureItem(
              icon: Icons.add_circle,
              title: 'العد والتسجيل',
              description: 'عدّ أذكارك بسهولة وزد/صفّر العداد حسب الحاجة',
            ),
          ],
        ),

        // Support Section
        _buildSection(
          key: _sectionKeys[5],
          title: 'دعم التطبيق',
          icon: Icons.volunteer_activism,
          color: Colors.red,
          children: [
            _buildFeatureItem(
              icon: Icons.ads_click,
              title: 'إعلان المكافآت',
              description: 'من الرئيسية، اضغط بطاقة "ادعم التطبيق" ثم أكد رغبتك بمشاهدة إعلان لدعم التطوير',
            ),
          ],
        ),

        // Quran App Section
        _buildSection(
          key: _sectionKeys[6],
          title: 'تطبيق القرآن الكريم',
          icon: Icons.menu_book,
          color: Colors.indigo,
          children: [
            _buildFeatureItem(
              icon: Icons.shop,
              title: 'تحميل من المتجر',
              description: 'انتقل لمتجر Play لتحميل تطبيق القرآن عبر البطاقة المخصصة',
            ),
          ],
        ),

        // Theme Section
        _buildSection(
          key: _sectionKeys[7],
          title: 'المظهر واللغة',
          icon: Icons.palette,
          color: Colors.pink,
          children: [
            _buildFeatureItem(
              icon: Icons.brightness_6,
              title: 'تغيير الوضع',
              description: 'بدّل بين الوضع الفاتح والداكن من أيقونة الشمس/القمر في أعلى التطبيق',
            ),
            _buildFeatureItem(
              icon: Icons.language,
              title: 'اللغة والاتجاه',
              description: 'التطبيق يعمل باللغة العربية ويدعم اتجاه الكتابة من اليمين لليسار',
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Tips Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'نصائح مهمة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTipItem(
                'إذا لم تظهر الإشعارات، تأكد من منح الأذونات للتطبيق من إعدادات النظام',
                Icons.notifications_off,
              ),
              _buildTipItem(
                'لمسح المفضلات من الرئيسية، استخدم زر "مسح الكل" في قسم المفضلات',
                Icons.clear_all,
              ),
              _buildTipItem(
                'لسياسة الخصوصية المفصلة، افتح صفحة "سياسة الخصوصية" من الرئيسية',
                Icons.privacy_tip,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required GlobalKey key,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, IconData icon) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}


