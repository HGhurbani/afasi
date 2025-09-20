import 'package:flutter/material.dart';
import 'package:afasi/app/app.dart';

class PrivacyPolicyPage extends StatefulWidget {
  static const String routeName = '/privacy-policy';

  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(5, (index) => GlobalKey());

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'جمع المعلومات',
      'icon': Icons.data_usage,
      'description': 'كيفية جمعنا للمعلومات وحمايتها',
    },
    {
      'title': 'استخدام المعلومات',
      'icon': Icons.how_to_reg,
      'description': 'الغرض من استخدام البيانات المجمعة',
    },
    {
      'title': 'الأمان والحماية',
      'icon': Icons.security,
      'description': 'إجراءات حماية البيانات والأمان',
    },
    {
      'title': 'التحديثات والتغييرات',
      'icon': Icons.update,
      'description': 'تحديث سياسة الخصوصية',
    },
    {
      'title': 'التواصل معنا',
      'icon': Icons.contact_support,
      'description': 'طرق التواصل والاستفسارات',
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
            'سياسة الخصوصية',
            style: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
          ),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.volunteer_activism, color: Colors.white),
            //   onPressed: () => myAppKey.currentState?.confirmAndShowRewardedAd(),
            //   tooltip: 'تبرع بمشاهدة إعلان',
            // ),
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
        // Header section
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
                Icons.privacy_tip,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'سياسة الخصوصية',
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
                'لتطبيق مشاري العفاسي',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'نحن في تطبيق مشاري العفاسي نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. تُستخدم المعلومات التي يتم جمعها لتحسين تجربة المستخدم وتقديم إعلانات مناسبة، ويتم ذلك وفق الشروط التالية:',
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

        // Data Collection Section
        _buildSection(
          key: _sectionKeys[0],
          title: 'جمع المعلومات',
          icon: Icons.data_usage,
          color: Colors.blue,
          children: [
            _buildPolicyItem(
              icon: Icons.person_off,
              title: 'عدم جمع المعلومات الشخصية',
              description: 'لا نقوم بجمع معلومات شخصية عن المستخدمين بدون موافقتهم الصريحة',
            ),
            _buildPolicyItem(
              icon: Icons.analytics,
              title: 'البيانات التحليلية',
              description: 'نستخدم خدمات مثل Firebase Analytics و Google Mobile Ads لجمع بيانات تحليلية وإحصائية تُستخدم لتحسين أداء التطبيق وتقديم المحتوى المناسب',
            ),
            _buildPolicyItem(
              icon: Icons.verified_user,
              title: 'الموافقة المسبقة',
              description: 'جميع البيانات التي يتم جمعها تتم بموافقة مسبقة من المستخدم',
            ),
          ],
        ),

        // Data Usage Section
        _buildSection(
          key: _sectionKeys[1],
          title: 'استخدام المعلومات',
          icon: Icons.how_to_reg,
          color: Colors.green,
          children: [
            _buildPolicyItem(
              icon: Icons.analytics_outlined,
              title: 'الغرض التحليلي',
              description: 'تُستخدم البيانات فقط لأغراض تحليلية وتطوير التطبيق',
            ),
            _buildPolicyItem(
              icon: Icons.block,
              title: 'عدم البيع أو المشاركة',
              description: 'لا يتم بيع أو مشاركة المعلومات مع أطراف خارجية بدون إذن المستخدم',
            ),
            _buildPolicyItem(
              icon: Icons.trending_up,
              title: 'تحسين الخدمة',
              description: 'البيانات تُستخدم لتحسين جودة الخدمة وتجربة المستخدم',
            ),
          ],
        ),

        // Security Section
        _buildSection(
          key: _sectionKeys[2],
          title: 'الأمان والحماية',
          icon: Icons.security,
          color: Colors.orange,
          children: [
            _buildPolicyItem(
              icon: Icons.shield,
              title: 'إجراءات الحماية',
              description: 'نتخذ إجراءات تقنية وتنظيمية مناسبة لحماية بيانات المستخدمين',
            ),
            _buildPolicyItem(
              icon: Icons.storage,
              title: 'خوادم آمنة',
              description: 'يتم تخزين المعلومات على خوادم آمنة وفق أعلى معايير الحماية',
            ),
            _buildPolicyItem(
              icon: Icons.lock,
              title: 'التشفير',
              description: 'جميع البيانات الحساسة يتم تشفيرها باستخدام أحدث تقنيات التشفير',
            ),
          ],
        ),

        // Updates Section
        _buildSection(
          key: _sectionKeys[3],
          title: 'التحديثات والتغييرات',
          icon: Icons.update,
          color: Colors.purple,
          children: [
            _buildPolicyItem(
              icon: Icons.notifications_active,
              title: 'إشعار التحديثات',
              description: 'سيتم إشعار المستخدمين بأي تحديثات على سياسة الخصوصية',
            ),
            _buildPolicyItem(
              icon: Icons.publish,
              title: 'النشر والتوضيح',
              description: 'سيتم نشر أي تغييرات على هذه السياسة داخل التطبيق وفي صفحة سياسة الخصوصية',
            ),
            _buildPolicyItem(
              icon: Icons.history,
              title: 'سجل التغييرات',
              description: 'نحتفظ بسجل لجميع التغييرات التي تطرأ على سياسة الخصوصية',
            ),
          ],
        ),

        // Contact Section
        _buildSection(
          key: _sectionKeys[4],
          title: 'التواصل معنا',
          icon: Icons.contact_support,
          color: Colors.teal,
          children: [
            _buildPolicyItem(
              icon: Icons.email,
              title: 'البريد الإلكتروني',
              description: 'hazemhataki@gmail.com',
              isEmail: true,
            ),
            _buildPolicyItem(
              icon: Icons.help_outline,
              title: 'الاستفسارات',
              description: 'إذا كانت لديك أي أسئلة أو استفسارات حول سياسة الخصوصية، يمكنك التواصل معنا',
            ),
            _buildPolicyItem(
              icon: Icons.schedule,
              title: 'وقت الاستجابة',
              description: 'نقوم بالرد على جميع الاستفسارات خلال 24-48 ساعة',
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Agreement Section
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
                    Icons.gavel,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الموافقة على السياسة',
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
              Text(
                'باستخدامك لهذا التطبيق، فإنك توافق على جمع واستخدام المعلومات وفقاً لهذه السياسة. إذا كنت لا توافق على هذه السياسة، يرجى عدم استخدام التطبيق.',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'آخر تحديث: ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildPolicyItem({
    required IconData icon,
    required String title,
    required String description,
    bool isEmail = false,
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
                if (isEmail)
                  SelectableText(
                    description,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}


