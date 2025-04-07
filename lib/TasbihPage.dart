import 'package:flutter/material.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({Key? key}) : super(key: key);

  @override
  _TasbihPageState createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المسبحة الإلكترونية"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "عدد التسبيحات:",
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _incrementCounter,
              icon: const Icon(Icons.add),
              label: const Text("تسبيحة"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _resetCounter,
              icon: const Icon(Icons.refresh),
              label: const Text("إعادة التعيين"),
            ),
          ],
        ),
      ),
    );
  }
}
