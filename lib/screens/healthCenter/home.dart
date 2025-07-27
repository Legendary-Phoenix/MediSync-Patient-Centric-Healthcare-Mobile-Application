import 'package:flutter/material.dart';

class HealthCenterHomeScreen extends StatelessWidget {
  const HealthCenterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Health center home screen",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.purple,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.purple,
          secondary: Colors.purpleAccent,
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text("Health center home screen")),
        body: const Center(
          child: Text(
            "Welcome to the health center home screen!",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
