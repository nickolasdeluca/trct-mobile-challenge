import 'package:assets_app/screens/home/view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AssetsApp());
}

class AssetsApp extends StatelessWidget {
  const AssetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
