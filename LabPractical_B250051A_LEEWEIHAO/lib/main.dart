import 'package:flutter/material.dart';
import '/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Education Fair App',
      home: const HomeScreen(title: 'Education Fair App'),
    );
  }
}