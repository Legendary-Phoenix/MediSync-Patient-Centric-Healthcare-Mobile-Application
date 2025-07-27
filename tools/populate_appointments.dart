import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

final _firestore = FirebaseFirestore.instance;
final _random = Random();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final List<String> patientIDs = await _getPatientIDs();
  final availableSlots = await _getAvailableTimeSlots();

  if (availableSlots.length < 100) {
    print("❗ Not enough available slots to create 100 appointments.");
    return;
  }

  final selectedSlots = availableSlots.sublist(0, 100);
  final appointmentStatuses = _generateStatuses();

  for (int i = 0; i < selectedSlots.length; i++) {
    final slot = selectedSlots[i];
    final appointmentID = _firestore.collection('appointments').doc().id;

    final status = appointmentStatuses[i];
    final patientID = patientIDs[_random.nextInt(patientIDs.length)];
    final bookingMadeAt = Timestamp.fromDate(
      DateTime.now().subtract(Duration(days: _random.nextInt(10))),
    );

    await _firestore.collection('appointments').doc(appointmentID).set({
      'id': appointmentID,
      'patientID': patientID,
      'scheduleID': slot['scheduleID'],
      'slotID': slot['slotID'],
      'status': status,
      'appointmentReason': _generateReason(),
      'bookingMadeAt': bookingMadeAt,
      'cancellationReason': status == 'cancelled' ? "Schedule conflict" : null,
      'declineReason': status == 'declined' ? "Not accepted by clinic" : null,
    });

    // Update the corresponding timeSlot to "booked"
    await _markSlotAsBooked(slot['scheduleID'], slot['slotID']);

    print("✅ Appointment created with ID: $appointmentID");
  }

  print("🎉 Finished creating 100 appointment records.");
}

Future<List<String>> _getPatientIDs() async {
  final snap = await _firestore.collection('patients').get();
  return snap.docs.map((doc) => doc.id).toList();
}

Future<List<Map<String, dynamic>>> _getAvailableTimeSlots() async {
  final snap = await _firestore.collection('doctorSchedule').get();
  final List<Map<String, dynamic>> slots = [];

  for (var doc in snap.docs) {
    final scheduleID = doc.id;
    final data = doc.data();
    final timeSlots = List<Map<String, dynamic>>.from(data['timeSlots']);

    for (final slot in timeSlots) {
      if (slot['status'] == 'available') {
        slots.add({'scheduleID': scheduleID, 'slotID': slot['slotID']});
      }
    }
  }

  slots.shuffle(); // randomize the slot selection
  return slots;
}

Future<void> _markSlotAsBooked(String scheduleID, String slotID) async {
  final scheduleRef = _firestore.collection('doctorSchedule').doc(scheduleID);
  final scheduleDoc = await scheduleRef.get();
  final data = scheduleDoc.data();

  if (data == null) return;

  final timeSlots = List<Map<String, dynamic>>.from(data['timeSlots']);
  final updatedSlots =
      timeSlots.map((slot) {
        if (slot['slotID'] == slotID) {
          return {...slot, 'status': 'booked'};
        }
        return slot;
      }).toList();

  await scheduleRef.update({'timeSlots': updatedSlots});
}

List<String> _generateStatuses() {
  List<String> statuses = [];
  statuses.addAll(List.filled(60, 'pending'));
  statuses.addAll(List.filled(20, 'confirmed'));
  statuses.addAll(List.filled(10, 'cancelled'));
  statuses.addAll(List.filled(10, 'completed'));
  statuses.shuffle();
  return statuses;
}

String _generateReason() {
  final reasons = [
    "Follow-up for cold treatment",
    "Annual checkup",
    "Consultation for chronic pain",
    "Prescription renewal",
    "New symptoms",
    "Lab result discussion",
    "Specialist referral",
    "Blood pressure monitoring",
    "Routine vaccination",
    "General fatigue complaint",
  ];
  return reasons[_random.nextInt(reasons.length)];
}
