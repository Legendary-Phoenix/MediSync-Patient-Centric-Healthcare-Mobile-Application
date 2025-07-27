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

    final prescriptionData = {
      'appointmentID': appointmentID,
      'medicineName': _getRandomMedicineName(),
      'functionDescription': _getRandomFunction(),
      'reasonPrescribed': _getRandomReason(),
      'notes': _getRandomNote(),
      'intakeGuideline': _generateIntakeGuideline(),
    };

    await _firestore.collection('prescription').add(prescriptionData);
    print("✅ Prescription created for appointment: $appointmentID");
  }

  print("🎉 Finished generating prescriptions.");
}

String _getRandomMedicineName() {
  final meds = [
    "Paracetamol",
    "Amoxicillin",
    "Ibuprofen",
    "Cetirizine",
    "Omeprazole",
    "Loratadine",
    "Metformin",
    "Amlodipine",
  ];
  return meds[_random.nextInt(meds.length)];
}

String _getRandomFunction() {
  final functions = [
    "Reduces fever and relieves pain.",
    "Treats bacterial infections.",
    "Reduces inflammation and pain.",
    "Relieves allergy symptoms.",
    "Reduces stomach acid.",
    "Controls blood sugar levels.",
    "Lowers blood pressure.",
  ];
  return functions[_random.nextInt(functions.length)];
}

String _getRandomReason() {
  final reasons = [
    "Treatment of headache and mild fever.",
    "Prescribed for upper respiratory infection.",
    "Used for seasonal allergy symptoms.",
    "Gastric reflux management.",
    "Control of type 2 diabetes.",
    "Hypertension management.",
  ];
  return reasons[_random.nextInt(reasons.length)];
}

String _getRandomNote() {
  final notes = [
    "Do not exceed recommended daily intake.",
    "Complete the full course even if symptoms improve.",
    "Take with water and do not crush.",
    "Avoid driving after intake.",
    "Monitor blood pressure regularly.",
  ];
  return notes[_random.nextInt(notes.length)];
}

Map<String, dynamic> _generateIntakeGuideline() {
  final dietaryGuidelines = ["Before food", "After food", "With food"];
  final times = [
    ["Morning"],
    ["Night"],
    ["Morning", "Evening"],
    ["Morning", "Afternoon", "Night"],
  ];

  final frequency = [1, 2, 3];
  final quantity = [1, 2];
  final unit = ["tablet", "capsule"];

  final freq = frequency[_random.nextInt(frequency.length)];
  final quant = quantity[_random.nextInt(quantity.length)];
  final timeGuideline = times[_random.nextInt(times.length)];

  return {
    "quantityPerIntake": {
      "amount": quant,
      "unit": unit[_random.nextInt(unit.length)],
    },
    "dosePerIntake": _random.nextBool() ? 25 * quant : null,
    "maxDailyDosage": 25 * quant * freq,
    "dietaryGuideline":
        dietaryGuidelines[_random.nextInt(dietaryGuidelines.length)],
    "timeGuideline": timeGuideline,
    "frequencyPerDay": freq,
    "intervalHours": (24 ~/ freq),
  };
}
