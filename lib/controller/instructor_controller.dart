import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:driving_school/utils/authentication_dialogue_widget.dart';
import 'package:driving_school/views/instructor/instructor_home.dart';
import 'package:driving_school/models/instructor_model.dart';
import 'package:driving_school/models/rating_model.dart';
import 'package:driving_school/models/session_note_model.dart';
import 'package:driving_school/models/instructor_leave_model.dart';
import 'package:driving_school/models/fuel_receipt_model.dart';
import 'package:driving_school/models/maintenance_receipt_model.dart';
import 'package:driving_school/models/trip_log_model.dart'; // Added
import 'package:driving_school/services/cloudinary_service.dart';
import 'package:driving_school/views/choose_user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class InstructorController extends ChangeNotifier {
  FirebaseAuth? _firebaseAuth;
  FirebaseAuth get firebaseAuth => _firebaseAuth ??= FirebaseAuth.instance;

  FirebaseFirestore? _firebaseFirestore;
  FirebaseFirestore get firebaseFirestore =>
      _firebaseFirestore ??= FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? _instructorId;
  String get instructorId => _instructorId!;

  InstructorModel? _currentInstructor;
  InstructorModel? get currentInstructor => _currentInstructor;

  // ---- Dashboard Stats ----
  int totalStudents = 0;
  int totalEvaluations = 0;
  double averageRating = 0.0;
  List<RatingModel> myRatingsList = [];
  bool statsLoaded = false;

  // ---- Session Notes ----
  List<SessionNoteModel> sessionNotesList = [];

  Future<void> saveSessionNote({
    required String studentId,
    required String note,
    required BuildContext context,
  }) async {
    if (_currentInstructor == null) return;
    try {
      final docRef = firebaseFirestore.collection('session_notes').doc();
      final sessionNote = SessionNoteModel(
        id: docRef.id,
        studentId: studentId,
        instructorName: _currentInstructor!.instructorName,
        note: note,
        date: DateTime.now().toIso8601String(),
      );
      await docRef.set(sessionNote.toMap());
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session note saved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save note: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<List<SessionNoteModel>> fetchSessionNotes(String studentId) async {
    try {
      final snapshot = await firebaseFirestore
          .collection('session_notes')
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SessionNoteModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching session notes: $e');
      // Fallback without orderBy if index not created
      try {
        final snapshot = await firebaseFirestore
            .collection('session_notes')
            .where('studentId', isEqualTo: studentId)
            .get();

        final list = snapshot.docs
            .map((doc) => SessionNoteModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      } catch (e2) {
        print('Fallback also failed: $e2');
        return [];
      }
    }
  }

  // ---- Status Management ----
  Future<void> updateMyStatus(String newStatus) async {
    if (_currentInstructor == null) return;
    try {
      await firebaseFirestore
          .collection('instructors')
          .doc(_currentInstructor!.instructorID)
          .update({'status': newStatus});
      _currentInstructor!.status = newStatus;
      notifyListeners();
    } catch (e) {
      print('Failed to update status: $e');
    }
  }

  Future<void> fetchDashboardStats() async {
    if (_currentInstructor == null) return;
    try {
      final instructorName = _currentInstructor!.instructorName;

      // 1. Count assigned students
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final usersSnapshot = await firebaseFirestore
          .collection('users')
          .where('selectedInstructor', isEqualTo: instructorName)
          .where('instructorSelectionDate', isEqualTo: today)
          .get();
      totalStudents = usersSnapshot.docs.length;

      // 2. Count evaluations done (student_skills docs)
      int evalCount = 0;
      for (var userDoc in usersSnapshot.docs) {
        final skillsSnapshot = await firebaseFirestore
            .collection('student_skills')
            .where('studentId', isEqualTo: userDoc['userID'])
            .get();
        evalCount += skillsSnapshot.docs.length;
      }
      totalEvaluations = evalCount;

      // 3. Fetch ratings
      await fetchMyRatings();

      statsLoaded = true;
      notifyListeners();
    } catch (e) {
      print('Error fetching dashboard stats: $e');
    }
  }

  Future<void> fetchMyRatings() async {
    if (_currentInstructor == null) return;
    try {
      myRatingsList.clear();
      averageRating = 0.0;
      double totalScore = 0.0;

      final snapshot = await firebaseFirestore
          .collection('ratings')
          .where('instructorID', isEqualTo: _currentInstructor!.instructorName)
          .get();

      for (var doc in snapshot.docs) {
        RatingModel rating = RatingModel.fromMap(doc.data() as Map<String, dynamic>);
        myRatingsList.add(rating);
        totalScore += rating.score;
      }

      if (myRatingsList.isNotEmpty) {
        averageRating = totalScore / myRatingsList.length;
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching instructor ratings: $e');
    }
  }

  Future<void> updateMyProfile({
    required String name,
    required int phoneNumber,
    String? upiId,
    required BuildContext context,
  }) async {
    if (_currentInstructor == null || _instructorId == null) return;
    try {
      final updateData = <String, dynamic>{
        'instructorName': name,
        'instructorNumber': phoneNumber,
      };
      if (upiId != null) updateData['upiId'] = upiId;

      await firebaseFirestore
          .collection('instructors')
          .doc(_instructorId)
          .update(updateData);

      _currentInstructor = InstructorModel(
        instructorID: _currentInstructor!.instructorID,
        instructorName: name,
        instructorNumber: phoneNumber,
        instructorEmail: _currentInstructor!.instructorEmail,
        instructorProPic: _currentInstructor!.instructorProPic,
        status: _currentInstructor!.status,
        upiId: upiId ?? _currentInstructor!.upiId,
      );
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return const AuthenticationDialogueWidget(
            message: 'Authenticating Instructor...',
          );
        },
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        String queryEmail = user.email ?? '';

        // Check if this email exists in the instructors collection
        QuerySnapshot instructorSnapshot = await firebaseFirestore
            .collection('instructors')
            .where('instructorEmail', isEqualTo: queryEmail)
            .get();

        Navigator.pop(context); // close dialog

        if (instructorSnapshot.docs.isNotEmpty) {
          // Instructor is verified
          var doc = instructorSnapshot.docs.first;
          _instructorId = doc.id;
          final mapData = doc.data() as Map<String, dynamic>;
          
          // Ensure map has instructorID as we use factory fromMap
          mapData['instructorID'] = doc.id; 
          _currentInstructor = InstructorModel.fromMap(mapData);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const InstructorHome(),
            ),
          );
        } else {
          // Not an added instructor
          await _googleSignIn.signOut();
          await firebaseAuth.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Access Denied: This email is not registered as an instructor.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print("Instructor Google Sign-In Error: $e");
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      _currentInstructor = null;
      _instructorId = null;
      statsLoaded = false;
      totalStudents = 0;
      totalEvaluations = 0;
      averageRating = 0.0;
      myRatingsList.clear();

      await _googleSignIn.signOut();
      await firebaseAuth.signOut();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ChooseUser()),
          (route) => false,
        );
      }
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // ---- Leave Management ----
  Future<void> submitLeaveRequest({
    required String startDate,
    required String endDate,
    required String reason,
    required BuildContext context,
  }) async {
    if (_currentInstructor == null) return;
    try {
      final newRef = firebaseFirestore.collection('instructor_leaves').doc();
      final model = InstructorLeaveModel(
        id: newRef.id,
        instructorId: _currentInstructor!.instructorID,
        instructorName: _currentInstructor!.instructorName,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        status: 'Pending',
        appliedOn: DateTime.now().toIso8601String(),
      );

      await newRef.set(model.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request submitted successfully.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit leave: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Stream<List<InstructorLeaveModel>> getInstructorLeaves() {
    if (_currentInstructor == null) return Stream.value([]);
    return firebaseFirestore
        .collection('instructor_leaves')
        .where('instructorId', isEqualTo: _currentInstructor!.instructorID)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => InstructorLeaveModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.appliedOn.compareTo(a.appliedOn));
          return list;
        });
  }

  // ---- Fuel Management ----
  Future<void> submitFuelReceipt({
    required String vehicleId,
    required String vehiclePlate,
    required String amount,
    required String liters,
    required XFile receiptImage,
    required BuildContext context,
  }) async {
    if (_currentInstructor == null) return;
    try {
      // Show loading UI if needed, but we upload then set document
      final uploadedUrl = await CloudinaryService.uploadFile(receiptImage, 'fuel_receipts');
      if (uploadedUrl == null) {
        throw Exception('Image upload failed');
      }

      final newRef = firebaseFirestore.collection('fuel_receipts').doc();
      final model = FuelReceiptModel(
        id: newRef.id,
        instructorId: _currentInstructor!.instructorID,
        instructorName: _currentInstructor!.instructorName,
        vehicleId: vehicleId,
        vehiclePlate: vehiclePlate,
        amount: amount,
        liters: liters,
        date: DateTime.now().toIso8601String(),
        receiptImageUrl: uploadedUrl,
        status: 'Pending',
      );

      await newRef.set(model.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fuel receipt submitted successfully.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit fuel receipt: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Stream<List<FuelReceiptModel>> getInstructorFuelReceipts() {
    if (_currentInstructor == null) return Stream.value([]);
    return firebaseFirestore
        .collection('fuel_receipts')
        .where('instructorId', isEqualTo: _currentInstructor!.instructorID)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => FuelReceiptModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  // ---- Maintenance Management ----
  Future<void> submitMaintenanceReceipt({
    required String vehicleId,
    required String vehiclePlate,
    required String amount,
    required String description,
    required XFile receiptImage,
    required BuildContext context,
  }) async {
    if (_currentInstructor == null) return;
    try {
      final uploadedUrl = await CloudinaryService.uploadFile(receiptImage, 'maintenance_receipts');
      if (uploadedUrl == null) {
        throw Exception('Image upload failed');
      }

      final newRef = firebaseFirestore.collection('maintenance_receipts').doc();
      final model = MaintenanceReceiptModel(
        id: newRef.id,
        instructorId: _currentInstructor!.instructorID,
        instructorName: _currentInstructor!.instructorName,
        vehicleId: vehicleId,
        vehiclePlate: vehiclePlate,
        amount: double.parse(amount),
        description: description,
        date: DateTime.now(),
        imageUrl: uploadedUrl,
        status: 'Pending',
      );

      await newRef.set(model.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maintenance receipt submitted successfully.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit maintenance receipt: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Stream<List<MaintenanceReceiptModel>> getInstructorMaintenanceReceipts() {
    if (_currentInstructor == null) return Stream.value([]);
    return firebaseFirestore
        .collection('maintenance_receipts')
        .where('instructorId', isEqualTo: _currentInstructor!.instructorID)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => MaintenanceReceiptModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  // ---- Trip Log Management ----
  Future<void> submitTripLog({
    required String vehicleId,
    required String vehiclePlate,
    required String destination,
    required String startKm,
    required String endKm,
    required String startTime,
    required String endTime,
    required BuildContext context,
  }) async {
    if (_currentInstructor == null) return;
    try {
      final docRef = firebaseFirestore.collection('trip_logs').doc();
      final log = TripLogModel(
        id: docRef.id,
        vehicleId: vehicleId,
        vehiclePlate: vehiclePlate,
        instructorId: _currentInstructor!.instructorID,
        instructorName: _currentInstructor!.instructorName,
        destination: destination,
        startKm: int.parse(startKm),
        endKm: int.parse(endKm),
        tripDate: DateTime.now(),
        startTime: startTime,
        endTime: endTime,
      );

      await docRef.set(log.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip logged successfully.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log trip: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Stream<List<TripLogModel>> getInstructorTripLogs() {
    if (_currentInstructor == null) return Stream.value([]);
    return firebaseFirestore
        .collection('trip_logs')
        .where('instructorId', isEqualTo: _currentInstructor!.instructorID)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => TripLogModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.tripDate.compareTo(a.tripDate));
          return list;
        });
  }
}


