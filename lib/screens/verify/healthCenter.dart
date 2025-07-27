import 'package:flutter/material.dart';

class VerifyHealthCenter extends StatelessWidget {
  const VerifyHealthCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Verify health center screen",
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
        appBar: AppBar(title: const Text("Verify Health Center")),
        body: const Center(
          child: Text(
            "Welcome to the Verify Health Center Screen!",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
