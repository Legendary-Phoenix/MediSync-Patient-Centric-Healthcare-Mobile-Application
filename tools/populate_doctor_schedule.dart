import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  final assignmentSnapshot =
      await firestore.collection('doctorAssignments').get();
  final assignments = assignmentSnapshot.docs;

  if (assignments.isEmpty) {
    print("❗ No doctorAssignments found.");
    return;
  }

  final DateTime startDate = DateTime(2025, 7, 28);
  final int totalDays = 30;

  for (final assignment in assignments) {
    final doctorID = assignment['doctorID'];
    final healthCenterID = assignment['healthCenterID'];

    for (int i = 0; i < totalDays; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final scheduleRef = firestore.collection('doctorSchedule').doc();
      final scheduleID = scheduleRef.id;

      // Create 6 time slots (every 30 mins from 9:00 AM to 12:00 PM)
      final List<Map<String, dynamic>> timeSlots = [];
      DateTime slotTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        9,
        0,
      );
      for (int j = 0; j < 6; j++) {
        final slotID =
            firestore
                .collection('dummy')
                .doc()
                .id; // Just to generate a unique ID
        final startTimeStr =
            "${slotTime.hour.toString().padLeft(2, '0')}:${slotTime.minute.toString().padLeft(2, '0')}";
        final end = slotTime.add(Duration(minutes: 30));
        final endTimeStr =
            "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";

        timeSlots.add({
          "slotID": slotID,
          "startTime": startTimeStr,
          "endTime": endTimeStr,
          "status": "available",
        });

        slotTime = end;
      }

      await scheduleRef.set({
        "scheduleID": scheduleID,
        "doctorID": doctorID,
        "healthCenterID": healthCenterID,
        "date": Timestamp.fromDate(currentDate), // Store date as Timestamp
        "timeSlots": timeSlots,
      });

      print(
        "✅ Created schedule for $doctorID on ${currentDate.toLocal().toIso8601String().split('T').first}",
      );
    }
  }

  print("✅ Finished creating all doctorSchedule records.");
}
