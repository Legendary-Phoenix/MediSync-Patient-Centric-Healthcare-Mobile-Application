import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medisync/screens/auth/register_screen.dart';
import 'package:medisync/screens/doctor/home.dart';
import 'package:medisync/screens/healthCenter/home.dart';
import 'package:medisync/screens/patient/home.dart';
import 'package:medisync/screens/patient/main_screen.dart';
import 'package:medisync/screens/verify/doctor.dart';
import 'package:medisync/screens/verify/healthCenter.dart';
import 'package:medisync/screens/verify/patient.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MediSyncApp());
}

class MediSyncApp extends StatelessWidget {
  const MediSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediSync',
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
      initialRoute: "/login", // 👈 Set initial screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verify/patient': (context) => const VerifyPatientScreen(),
        '/verify/doctor': (context) => const VerifyDoctorScreen(),
        '/verify/healthCenter': (context) => const VerifyHealthCenter(),
        '/patient/mainScreen': (context) => const PatientMainScreen(),
      },
    );
  }
}
