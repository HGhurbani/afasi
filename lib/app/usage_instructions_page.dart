import 'package:flutter/material.dart';
import 'app.dart';

class UsageInstructionsPage extends StatelessWidget {
  static const String routeName = '/usage-instructions';

  const UsageInstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    const String instructionsText = '''
مرحباً بك في تطبيق مشاري العفاسي

يحتوي التطبيق على عدة ميزات رئيسية. اتبع الخطوات التالية للاستفادة منها:

1) مكتبة الصوتيات:
   - تصفح الأقسام (القرآن الكريم، الأناشيد، الأذكار، الأدعية، الرقية الشرعية...)
   - استخدم البحث لتصفية العناصر داخل القسم الحالي.
   - شغّل المقطع مباشرة. إن لم يكن محملاً، يتم تشغيله عبر الإنترنت أو من المصدر المحلي عند توفره.
   - حمّل المقطع للاستماع دون إنترنت عند توفر زر التحميل.
   - افتح النص المرافق عبر زر "قراءة" مع دعم تكبير/تصغير الخط.
   - أضف للمفضلة عبر أيقونة القلب، وستظهر المفضلات في الرئيسية ضمن قسم "المفضلات الصوتية" مع إمكانية مسح عنصر أو مسح الكل.

2) الصور والخلفيات:
   - استعرض خلفيات إسلامية مميزة ومتجددة.
   - افتح الصورة بكامل الشاشة واحفظها أو اجعلها خلفية (حسب الإمكانية المتاحة على جهازك).

3) منبه الأذكار:
   - فعّل التذكير بالأذكار اليومية.
   - يمنحك التطبيق إشعارات في الأوقات المحددة. قد تحتاج لمنح إذن الإشعارات.

4) أوقات الصلاة:
   - اعرض مواقيت الصلاة حسب مدينتك.
   - قد تحتاج لمنح إذن الوصول للموقع لتحديد المدينة بدقة وتفعيل إشعارات الأذان.

5) المسبحة الإلكترونية:
   - عدّ أذكارك بسهولة وزد/صفّر العداد حسب الحاجة.

6) دعم التطبيق بإعلان مكافآت:
   - من الرئيسية، اضغط بطاقة "ادعم التطبيق" ثم أكد رغبتك بمشاهدة إعلان لدعم التطوير.

7) تطبيق القرآن الكريم:
   - انتقل لمتجر Play لتحميل تطبيق القرآن عبر البطاقة المخصصة.

8) المظهر واللغة:
   - بدّل بين الوضع الفاتح والداكن من أيقونة الشمس/القمر في أعلى التطبيق.
   - التطبيق يعمل باللغة العربية ويدعم اتجاه الكتابة من اليمين لليسار.

نصائح:
 - إذا لم تظهر الإشعارات، تأكد من منح الأذونات للتطبيق من إعدادات النظام.
 - لمسح المفضلات من الرئيسية، استخدم زر "مسح الكل" في قسم المفضلات.
 - لسياسة الخصوصية المفصلة، افتح صفحة "سياسة الخصوصية" من الرئيسية.
''';

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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  instructionsText,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


