import 'package:flutter/material.dart';
import 'package:pinjemin_mobile/screens/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinjemin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B), // Teal — warna utama Pinjemin
          secondary: const Color(0xFF4CAF50),
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
