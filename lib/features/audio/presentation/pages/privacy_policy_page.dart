import 'package:flutter/material.dart';
import 'package:afasi/app/app.dart';

class PrivacyPolicyPage extends StatelessWidget {
  static const String routeName = '/privacy-policy';

  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    const String privacyPolicyText = '''
سياسة الخصوصية لتطبيق مشاري العفاسي

نحن في تطبيق مشاري العفاسي نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. تُستخدم المعلومات التي يتم جمعها لتحسين تجربة المستخدم وتقديم إعلانات مناسبة، ويتم ذلك وفق الشروط التالية:

1. جمع المعلومات:  
   - لا نقوم بجمع معلومات شخصية عن المستخدمين بدون موافقتهم.
   - نستخدم خدمات مثل Firebase Analytics و Google Mobile Ads لجمع بيانات تحليلية وإحصائية تُستخدم لتحسين أداء التطبيق وتقديم المحتوى المناسب.

2. استخدام المعلومات:  
   - تُستخدم البيانات فقط لأغراض تحليلية وتطوير التطبيق.
   - لا يتم بيع أو مشاركة المعلومات مع أطراف خارجية بدون إذن المستخدم.

3. الأمان:  
   - نتخذ إجراءات تقنية وتنظيمية مناسبة لحماية بيانات المستخدمين.
   - يتم تخزين المعلومات على خوادم آمنة وفق أعلى معايير الحماية.

4. التغييرات على سياسة الخصوصية:  
   - قد نقوم بتحديث سياسة الخصوصية من وقت لآخر.
   - سيتم نشر أي تغييرات على هذه السياسة داخل التطبيق وفي صفحة سياسة الخصوصية.

5. الاتصال:  
   - إذا كانت لديك أي أسئلة أو استفسارات حول سياسة الخصوصية، يمكنك التواصل معنا عبر البريد الإلكتروني: hazemhataki@gmail.com

باستخدامك لهذا التطبيق، فإنك توافق على جمع واستخدام المعلومات وفقاً لهذه السياسة.
''';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'سياسة الخصوصية',
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
                  privacyPolicyText,
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


