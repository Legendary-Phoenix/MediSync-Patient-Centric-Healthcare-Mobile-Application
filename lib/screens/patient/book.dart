import 'package:flutter/material.dart';

class PatientBookScreen extends StatelessWidget {
  const PatientBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Patient Booking Screen",
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
        appBar: AppBar(title: const Text("Patient Booking Screen")),
        body: const Center(
          child: Text(
            "Welcome to the Patient Booking Screen!",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
