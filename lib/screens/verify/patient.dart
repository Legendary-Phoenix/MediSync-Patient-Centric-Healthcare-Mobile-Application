import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VerifyPatientScreen extends StatefulWidget {
  const VerifyPatientScreen({super.key});

  @override
  State<VerifyPatientScreen> createState() => _PatientVerificationScreenState();
}

class _PatientVerificationScreenState extends State<VerifyPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _icController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  String _selectedGender = 'Male';
  DateTime? _selectedDate;

  File? _profileImage;
  File? _identityDocument;

  bool _isSubmitting = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = '${picked.year}-${picked.month}-${picked.day}';
      });
    }
  }

  Future<void> _pickImage(bool isProfile) async {
    final picker = ImagePicker();
    final source =
        isProfile ? ImageSource.gallery : ImageSource.camera; // switch source

    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(picked.path);
        } else {
          _identityDocument = File(picked.path);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _profileImage == null ||
        _identityDocument == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all required fields and upload documents',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final storage = FirebaseStorage.instance;
      final firestore = FirebaseFirestore.instance;

      final profilePath = 'patient_profile_image/$uid.jpg';
      final idPath = 'patient_identity_card/$uid.jpg';

      await storage.ref(profilePath).putFile(_profileImage!);
      await storage.ref(idPath).putFile(_identityDocument!);

      final now = Timestamp.now();

      await firestore.collection('patients').doc(uid).update({
        'id': uid,
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'dateOfBirth': Timestamp.fromDate(_selectedDate!),
        'gender': _selectedGender,
        'icNumber': _icController.text.trim(),
        'profileImagePath': profilePath,
        'identityDocumentPath': idPath,
        'address': {
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'postalCode': _postalCodeController.text.trim(),
        },
        'verified': true,
        'updatedAt': now,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification completed successfully'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/patient/mainScreen');
      }
    } catch (e) {
      print('Verification failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Patient Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,

                decoration: InputDecoration(
                  labelText: 'Name',

                  // Bottom silver border when not focused
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey, // silver
                      width: 1.0,
                    ),
                  ),

                  // Bottom purple border when focused
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2.5),
                  ),
                ),

                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',

                  // Bottom silver border when not focused
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey, // silver
                      width: 1.0,
                    ),
                  ),

                  // Bottom purple border when focused
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2.5),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: InkWell(
                    onTap: _pickDate, // Makes the icon pressable
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.purple,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (val) => setState(() => _selectedGender = val!),
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _icController,
                decoration: InputDecoration(
                  labelText: 'IC Number',

                  // Bottom silver border when not focused
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey, // silver
                      width: 1.0,
                    ),
                  ),

                  // Bottom purple border when focused
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2.5),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',

                  // Bottom silver border when not focused
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey, // silver
                      width: 1.0,
                    ),
                  ),

                  // Bottom purple border when focused
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2.5),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'State',

                  // Bottom silver border when not focused
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey, // silver
                      width: 1.0,
                    ),
                  ),

                  // Bottom purple border when focused
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2.5),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Postal Code',

                  // Bottom silver border when not focused
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey, // silver
                      width: 1.0,
                    ),
                  ),

                  // Bottom purple border when focused
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2.5),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _pickImage(true),
                icon: const Icon(Icons.image),
                label: const Text('Upload Profile Image'),
              ),
              const SizedBox(height: 8),
              _profileImage != null
                  ? Text('Profile image selected')
                  : const Text('No profile image selected'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _pickImage(false),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Identity Document'),
              ),
              const SizedBox(height: 8),
              _identityDocument != null
                  ? Text('Identity document selected')
                  : const Text('No identity document selected'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Submit Verification',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
