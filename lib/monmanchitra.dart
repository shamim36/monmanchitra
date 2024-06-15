import 'package:flutter/material.dart';
import 'package:monmanchitra/Screens/splash_screen.dart';

class MonManchitra extends StatefulWidget {
  const MonManchitra({super.key});

  @override
  State<MonManchitra> createState() => _MonManchitraState();
}

class _MonManchitraState extends State<MonManchitra> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}