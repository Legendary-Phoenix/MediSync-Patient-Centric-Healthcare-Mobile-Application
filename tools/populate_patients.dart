import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final random = Random();

  final names = [
    "Aiman Lee",
    "Nur Izzah",
    "Daniel Lim",
    "Siti Aminah",
    "Ahmad Syafiq",
    "Chong Wei",
    "Mei Ling",
    "Hafiz Ismail",
    "Zulaikha Aziz",
    "Raj Kumar",
  ];

  final List<String> profileImages = [
    "patient1.jpg",
    "patient2.jpeg",
    "patient3.jpeg",
    "patient4.jpeg",
    "patient5.jpg",
    "patient6.jpeg",
    "patient7.jpg",
    "patient8.jpg",
    "patient9.jpg",
    "patient10.jpg",
  ];

  final genders = ["Male", "Female"];
  final cities = ["Kuala Lumpur", "Shah Alam", "Penang", "Ipoh", "Johor Bahru"];

  for (int i = 0; i < 10; i++) {
    final docRef = firestore.collection('patients').doc();

    final randomGender = genders[i % 2];
    final randomCity = cities[i % cities.length];
    final dob = DateTime(
      1985 + random.nextInt(20),
      1 + random.nextInt(12),
      1 + random.nextInt(28),
    );

    final patientData = {
      "id": docRef.id,
      "name": names[i],
      "phoneNumber": "+6012${random.nextInt(9000000) + 1000000}",
      "email": "patient${i + 1}@example.com",
      "verified": true,
      "dateOfBirth": Timestamp.fromDate(dob),
      "gender": randomGender,
      "icNumber":
          "9504${random.nextInt(90) + 10}-14-${random.nextInt(9000) + 1000}",
      "profileImagePath": "patient_profile_image/${profileImages[i]}",
      "identityDocumentPath": "patient_identity_card/placeholder.jpg",
      "address": {
        "city": randomCity,
        "state": "WP Kuala Lumpur",
        "postalCode": "50000",
      },
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    };

    await docRef.set(patientData);
    print("✅ Added patient: ${names[i]} with ID: ${docRef.id}");
  }

  print("✅ Finished populating patient collection.");
}
