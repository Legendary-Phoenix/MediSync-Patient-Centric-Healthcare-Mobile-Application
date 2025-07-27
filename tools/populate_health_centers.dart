import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math';
import 'package:flutter/widgets.dart'; //Required for WidgetsFlutterBinding

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final List<String> clinicNames = [
    "Kuala City Medical Clinic",
    "Seri Medika Clinic",
    "WellCare Health Center",
    "Bandar Utama Medical",
    "Putrajaya Family Clinic",
    "CyberMed Center",
    "Bangsar General Care",
    "Sunway Medical Hub",
    "Ampang Wellness Center",
    "Subang Medical Express",
  ];

  final List<String> cities = [
    "Kuala Lumpur",
    "Shah Alam",
    "Petaling Jaya",
    "Putrajaya",
    "Cyberjaya",
  ];

  final List<String> states = ["WP Kuala Lumpur", "Selangor"];

  final List<String> types = [
    "General Care",
    "Dental",
    "Mental Health",
    "Pediatrics",
  ];

  final List<String> profileImageFilenames = [
    "clinic1.jpeg",
    "clinic2.jpg",
    "clinic3.jpg",
    "clinic4.png",
    "clinic5.jpg",
    "clinic6.jpg",
    "clinic7.jpg",
    "clinic8.jpg",
    "clinic9.jpg",
    "clinic10.jpg",
  ];

  final String licenseDocumentFilename = "placeholder.jpg";

  final Random random = Random();

  for (int i = 0; i < 10; i++) {
    final String name = clinicNames[i];
    final String city = cities[random.nextInt(cities.length)];
    final String state = states[random.nextInt(states.length)];
    final String type = types[random.nextInt(types.length)];

    final docRef =
        firestore.collection('healthCenters').doc(); // Auto-generated ID
    final generatedID = docRef.id;

    final Map<String, dynamic> clinicData = {
      "id": generatedID,
      "name": name,
      "type": type,
      "profileDescription": "We provide specialized care in $type.",
      "licenseNumber": "MED${100 + i}",
      "address": {
        "firstAddressLine":
            "${random.nextInt(100)}, Jalan ${name.split(" ").last}",
        "city": city,
        "state": state,
        "postalCode": "5${random.nextInt(1000).toString().padLeft(3, '0')}",
      },
      "profileImagePath":
          "health_center_profile_image/${profileImageFilenames[i]}",
      "licenseDocumentPath": "health_center_license/$licenseDocumentFilename",
      "operatingHours": List.generate(7, (dayIndex) {
        const days = [
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
          "Friday",
          "Saturday",
          "Sunday",
        ];
        bool isOpen = dayIndex < 5;
        return {
          "day": days[dayIndex],
          "isOpen": isOpen,
          "openTime": isOpen ? "09:00" : null,
          "closeTime": isOpen ? "17:00" : null,
        };
      }),
      "businessContactNumber": ["+6012345678", "+6019876543"],
      "personalContactNumber": [
        {"name": "Ms. Siti", "contactNumber": "+6016345245"},
        {"name": "Mr. David", "contactNumber": "+6016345315"},
      ],
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    };

    await docRef.set(clinicData);
    print("✅ Added clinic: $name with ID: $generatedID");
  }
}
