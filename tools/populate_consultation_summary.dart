import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
final _random = Random();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final appointmentsSnap =
      await _firestore
          .collection('appointments')
          .where('status', isEqualTo: 'completed')
          .get();

  if (appointmentsSnap.docs.isEmpty) {
    print("❗ No completed appointments found.");
    return;
  }

  for (var appointmentDoc in appointmentsSnap.docs) {
    final appointmentID = appointmentDoc.id;
    final scheduleID = appointmentDoc['scheduleID'];

    // Get the consultation date from the doctorSchedule document
    final scheduleDoc =
        await _firestore.collection('doctorSchedule').doc(scheduleID).get();
    if (!scheduleDoc.exists || !scheduleDoc.data()!.containsKey('date')) {
      print(
        "⚠️ Schedule not found or missing date for appointment: $appointmentID",
      );
      continue;
    }

    final Timestamp consultationDateTS = scheduleDoc['date'];
    final consultationDate = consultationDateTS.toDate().toUtc();

    final consultationID =
        _firestore.collection('consultationSummary').doc().id;

    await _firestore.collection('consultationSummary').doc(consultationID).set({
      'consultationID': consultationID,
      'appointmentID': appointmentID,
      'consultationDate': consultationDate.toIso8601String(),
      'patientConditionDescription': _generateCondition(),
      'diagnosis': _generateDiagnosis(),
      'summary': _generateSummary(),
      'procedures': _generateProcedures(),
      'createdAt': Timestamp.now(),
    });

    print("✅ Consultation summary created for appointment: $appointmentID");
  }

  print("🎉 Finished generating consultation summaries.");
}

String _generateCondition() {
  final options = [
    "Patient reported frequent headaches and fatigue.",
    "Complains of chest pain and shortness of breath.",
    "Sore throat and persistent cough for 5 days.",
    "Mild abdominal pain and loss of appetite.",
    "Experiencing dizziness and general weakness.",
  ];
  return options[_random.nextInt(options.length)];
}

String _generateDiagnosis() {
  final options = [
    "Mild anemia and general fatigue.",
    "Acute pharyngitis.",
    "Suspected early bronchitis.",
    "Gastritis with mild dehydration.",
    "Post-viral fatigue syndrome.",
  ];
  return options[_random.nextInt(options.length)];
}

String _generateSummary() {
  final options = [
    "Advised iron supplements, proper hydration, and rest. Scheduled follow-up after 1 month.",
    "Prescribed antibiotics, advised warm saline gargles. Monitor for 1 week.",
    "Suggested x-ray if symptoms persist. Rest and steam inhalation.",
    "Prescribed antacids and soft diet. Follow-up if symptoms worsen.",
    "Reassured patient, no serious findings. Monitor and follow lifestyle advice.",
  ];
  return options[_random.nextInt(options.length)];
}

List<Map<String, dynamic>> _generateProcedures() {
  final List<Map<String, dynamic>> procedures = [];

  procedures.add({
    'procedureType': 'blood_test',
    'results': {
      'hemoglobin':
          '${(9.0 + _random.nextDouble() * 4).toStringAsFixed(1)} g/dL',
      'whiteCellCount': '${(4000 + _random.nextInt(2000))} /µL',
      'plateletCount': '${(150000 + _random.nextInt(100000))} /µL',
    },
    'notes': 'Blood test within normal limits.',
  });

  procedures.add({
    'procedureType': 'auscultation',
    'results': {'lungCondition': 'Normal', 'heartSounds': 'No murmur detected'},
    'notes': 'No abnormal sounds noted.',
  });

  return procedures;
}
