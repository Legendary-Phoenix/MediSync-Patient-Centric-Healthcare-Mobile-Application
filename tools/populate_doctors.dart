import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  final random = Random();

  final List<String> profileImages = [
    "doctor1.jpeg",
    "doctor2.jpg",
    "doctor3.jpeg",
    "doctor4.jpg",
    "doctor5.jpg",
    "doctor6.jpg",
    "doctor7.jpg",
    "doctor8.jpeg",
    "doctor9.jpeg",
    "doctor10.jpg",
  ];

  final names = [
    "Dr. Aiman Ali",
    "Dr. Nur Farah",
    "Dr. Adam Rahman",
    "Dr. Sarah Lim",
    "Dr. Daniel Ong",
    "Dr. Hafiz Kamal",
    "Dr. Rachel Tan",
    "Dr. Faizal Mahmud",
    "Dr. Michelle Yee",
    "Dr. Ariff Musa",
  ];

  final fieldsOfPracticeOptions = [
    ["Internal Medicine", "Cardiology"],
    ["Pediatrics"],
    ["Dermatology"],
    ["Orthopedics", "Sports Medicine"],
    ["Psychiatry"],
    ["ENT", "General Medicine"],
    ["Ophthalmology"],
    ["General Practice"],
    ["Endocrinology"],
    ["Neurology"],
  ];

  final credentialsList = [
    [
      {
        "title": "MBBS",
        "institution": "University of Malaya",
        "yearObtained": 2015,
        "certificateDocumentPath": "doctor_certificate/placeholder.jpg",
      },
      {
        "title": "MRCP (UK)",
        "institution": "Royal College of Physicians",
        "yearObtained": 2020,
        "certificateDocumentPath": "doctor_certificate/placeholder.jpg",
      },
    ],
    [
      {
        "title": "MD",
        "institution": "Universiti Kebangsaan Malaysia",
        "yearObtained": 2013,
        "certificateDocumentPath": "doctor_certificate/placeholder.jpg",
      },
    ],
    [
      {
        "title": "MBBS",
        "institution": "International Medical University",
        "yearObtained": 2012,
        "certificateDocumentPath": "doctor_certificate/placeholder.jpg",
      },
    ],
  ];

  final cities = ["Kuala Lumpur", "Shah Alam", "Penang", "Johor Bahru", "Ipoh"];

  for (int i = 0; i < 10; i++) {
    final docRef = firestore.collection('doctors').doc();

    final doctorData = {
      "id": docRef.id,
      "name": names[i],
      "licenseNumber": "D-${random.nextInt(9000000) + 1000000}",
      "fieldOfPractice":
          fieldsOfPracticeOptions[i % fieldsOfPracticeOptions.length],
      "profileImagePath": "doctor_profile_image/${profileImages[i]}",
      "licenseDocumentPath": "doctor_license/placeholder.jpg",
      "credentials": credentialsList[random.nextInt(credentialsList.length)],
      "verified": true,
      "city": cities[i % cities.length],
      "contactNumbers": ["+6012${random.nextInt(9000000) + 1000000}"],
      "email": "doctor${i + 1}@example.com",
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    };

    await docRef.set(doctorData);
    print("✅ Added doctor: ${names[i]} with ID: ${docRef.id}");
  }

  print("✅ Finished populating doctor collection.");
}
