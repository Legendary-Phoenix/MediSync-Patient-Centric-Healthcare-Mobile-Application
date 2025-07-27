import 'package:flutter/material.dart';

class VerifyDoctorScreen extends StatelessWidget {
  const VerifyDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Verify doctor screen",
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
        appBar: AppBar(title: const Text("Verify Doctor")),
        body: const Center(
          child: Text(
            "Welcome to the Verify Doctor Screen!",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
