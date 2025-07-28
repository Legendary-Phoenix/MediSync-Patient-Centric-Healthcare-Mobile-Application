import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsPageState();
}

class _PatientAppointmentsPageState extends State<PatientAppointmentsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  DateTime? _selectedDate;
  String _selectedStatus = 'all';

  final Map<String, Color> statusColors = {
    'confirmed': Colors.green.shade700,
    'completed': Colors.green.shade700,
    'pending': Colors.orange.shade800,
    'cancelled': Colors.red.shade700,
    'declined': Colors.red.shade700,
  };

  final Map<String, Color> statusBGColors = {
    'confirmed': Colors.green.shade100,
    'completed': Colors.green.shade100,
    'pending': Colors.yellow.shade100,
    'cancelled': Colors.red.shade100,
    'declined': Colors.red.shade100,
  };

  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    final uid = _auth.currentUser!.uid;
    final query =
        await _firestore
            .collection('appointments')
            .where('patientID', isEqualTo: uid)
            .get();

    List<Map<String, dynamic>> allAppointments = [];

    for (var doc in query.docs) {
      final data = doc.data();

      // Filter by date if applicable
      if (_selectedDate != null) {
        final scheduleSnap =
            await _firestore
                .collection('doctorSchedule')
                .doc(data['scheduleID'])
                .get();

        final scheduleDate =
            (scheduleSnap.data()?['date'] as Timestamp).toDate();
        if (!(scheduleDate.year == _selectedDate!.year &&
            scheduleDate.month == _selectedDate!.month &&
            scheduleDate.day == _selectedDate!.day)) {
          continue;
        }
      }

      // Filter by status if not "all"
      if (_selectedStatus != 'all' && data['status'] != _selectedStatus) {
        continue;
      }

      // Fetch extra info: doctor, schedule, health center, etc.
      final scheduleSnap =
          await _firestore
              .collection('doctorSchedule')
              .doc(data['scheduleID'])
              .get();
      final schedule = scheduleSnap.data()!;

      final doctorSnap =
          await _firestore
              .collection('doctors')
              .doc(schedule['doctorID'])
              .get();

      final healthCenterSnap =
          await _firestore
              .collection('healthCenters')
              .doc(schedule['healthCenterID'])
              .get();

      final slot = (schedule['timeSlots'] as List).firstWhere(
        (slot) => slot['slotID'] == data['slotID'],
      );

      allAppointments.add({
        'appointment': data,
        'appointmentID': doc.id,
        'doctor': doctorSnap.data(),
        'scheduleDate': (schedule['date'] as Timestamp).toDate(),
        'healthCenter': healthCenterSnap.data(),
        'slot': slot,
      });
    }

    return allAppointments;
  }

  void _cancelAppointment(String appointmentID) async {
    await _firestore.collection('appointments').doc(appointmentID).update({
      'status': 'cancelled',
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedStatus,
                    items:
                        [
                              'all',
                              'pending',
                              'confirmed',
                              'completed',
                              'cancelled',
                              'declined',
                            ]
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.capitalize()),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchAppointments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final appointments = snapshot.data!;

                if (appointments.isEmpty) {
                  return const Center(child: Text('No appointments found.'));
                }

                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final item = appointments[index];
                    final doctor = item['doctor'];
                    final scheduleDate = item['scheduleDate'];
                    final center = item['healthCenter'];
                    final slot = item['slot'];
                    final status = item['appointment']['status'];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: NetworkImage(
                                // Replace with actual Firebase Storage URL or helper method
                                'https://firebasestorage.googleapis.com/v0/b/YOUR_BUCKET/o/${doctor['profileImagePath']}?alt=media',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusBGColors[status],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status.capitalize(),
                                      style: TextStyle(
                                        color: statusColors[status],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    doctor['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    doctor['fieldOfPractice']?.join(', ') ?? '',
                                  ),
                                  Text(center['name']),
                                  Text(
                                    '${scheduleDate.toLocal().toString().split(" ")[0]} | ${slot['startTime']} - ${slot['endTime']}',
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      if (status == 'pending' ||
                                          status == 'confirmed')
                                        TextButton(
                                          onPressed:
                                              () => _cancelAppointment(
                                                item['appointmentID'],
                                              ),
                                          child: const Text('Cancel'),
                                        ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pushNamed(
                                              context,
                                              '/appointmentDetails',
                                              arguments: item['appointmentID'],
                                            ),
                                        child: const Text('View Details'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCap on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
