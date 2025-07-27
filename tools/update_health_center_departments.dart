import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  // Define a sample list of departments for all health centers
  final List<String> defaultDepartments = [
    "General Practice",
    "Cardiology",
    "Pediatrics",
    "Dermatology",
    "Orthopedics",
  ];

  final snapshot = await firestore.collection('healthCenters').get();

  for (final doc in snapshot.docs) {
    await doc.reference.update({
      "departments": defaultDepartments,
      "updatedAt": FieldValue.serverTimestamp(),
    });
    print("✅ Updated health center: ${doc.id} with departments");
  }

  print("✅ Finished updating all health centers.");
}
