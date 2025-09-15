// lib/TasbihPage.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // لإضافة الاهتزاز

class TasbihPage extends StatefulWidget {
  const TasbihPage({Key? key}) : super(key: key); //

  @override
  _TasbihPageState createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int _counter = 0; //

  void _incrementCounter() {
    setState(() {
      _counter++; //
    });
    HapticFeedback.lightImpact(); // إضافة اهتزاز خفيف عند الضغط
  }

  void _resetCounter() {
    setState(() {
      _counter = 0; //
    });
    HapticFeedback.mediumImpact(); // إضافة اهتزاز متوسط عند إعادة التعيين
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("المسبحة الإلكترونية"), //
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "عدد التسبيحات:", //
                style: TextStyle(
                  fontSize: 28, //
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20), //
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: theme.primaryColor, width: 1),
                ),
                child: Text(
                  '$_counter', //
                  style: TextStyle(
                    fontSize: 72, //
                    fontWeight: FontWeight.bold, //
                    color: theme.primaryColor,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30), //
              ElevatedButton.icon(
                onPressed: _incrementCounter, //
                icon: const Icon(Icons.add_circle_outline, size: 28), //
                label: const Text(
                  "تسبيحة", //
                  style: TextStyle(fontSize: 20, fontFamily: 'Tajawal'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
              const SizedBox(height: 15), //
              TextButton.icon(
                onPressed: _resetCounter, //
                icon: const Icon(Icons.refresh, size: 24), //
                label: const Text(
                  "إعادة التعيين", //
                  style: TextStyle(fontSize: 16, fontFamily: 'Tajawal'),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: isDarkMode ? Colors.white70 : Colors.black54,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}