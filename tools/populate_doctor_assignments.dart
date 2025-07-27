import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  final doctorsSnapshot = await firestore.collection('doctors').get();
  final clinicsSnapshot = await firestore.collection('healthCenters').get();

  final doctorDocs = doctorsSnapshot.docs;
  final clinicDocs = clinicsSnapshot.docs;

  if (doctorDocs.length < 10 || clinicDocs.length < 5) {
    print("❗ Ensure at least 10 doctors and 5 clinics exist.");
    return;
  }

  int doctorIndex = 0;

  for (int i = 0; i < clinicDocs.length; i++) {
    final clinic = clinicDocs[i];
    final healthCenterID = clinic.id;
    final departments = clinic.data()["departments"] as List<dynamic>? ?? [];

    // Assign 2 doctors per clinic
    for (int j = 0; j < 2; j++) {
      if (doctorIndex >= doctorDocs.length) break;

      final doctor = doctorDocs[doctorIndex];
      final doctorID = doctor.id;

      // Pick a department randomly from clinic’s departments
      final department =
          departments.isNotEmpty
              ? departments[doctorIndex % departments.length]
              : "General Practice";

      final assignmentRef = firestore.collection('doctorAssignments').doc();
      final now = Timestamp.now();

      final assignmentData = {
        "id": assignmentRef.id,
        "doctorID": doctorID,
        "healthCenterID": healthCenterID,
        "department": department,
        "startDate": now,
        "endDate": null,
        "status": "active",
        "createdAt": now,
        "updatedAt": now,
      };

      await assignmentRef.set(assignmentData);
      print(
        "✅ Assigned Doctor ${doctorID} to Clinic ${healthCenterID} (${department})",
      );

      doctorIndex++;
    }
  }

  print("✅ Finished populating doctor_assignments.");
}
