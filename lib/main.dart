import 'package:flutter/material.dart';
import 'app/app.dart';

Future<void> main() async {
  await initializeApp();
  runApp(MyApp(key: myAppKey));
}
