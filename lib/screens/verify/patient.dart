import 'package:flutter/material.dart';

class VerifyPatientScreen extends StatelessWidget {
  const VerifyPatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Verify patient screen",
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
        appBar: AppBar(title: const Text("Verify Patient")),
        body: const Center(
          child: Text(
            "Welcome to the Verify Patient Screen!",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
