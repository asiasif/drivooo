import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school/models/attendance_model.dart';
import 'package:driving_school/models/contact_model.dart';
import 'package:driving_school/models/course_model.dart';
import 'package:driving_school/const.dart';
import 'package:driving_school/models/instructor_model.dart';
import 'package:driving_school/models/instructor_leave_model.dart';
import 'package:driving_school/models/vehicle_model.dart';
import 'package:driving_school/models/fuel_receipt_model.dart';
import 'package:driving_school/models/invoice_model.dart';
import 'package:driving_school/models/user_model.dart';
import 'package:driving_school/models/time_slot_model.dart';
import 'package:driving_school/models/booking_model.dart';
import 'package:driving_school/models/retest_model.dart'; // Added
import 'package:driving_school/models/rating_model.dart'; // Added
import 'package:driving_school/models/announcement_model.dart'; // Added
import 'package:driving_school/models/trip_log_model.dart'; // Added
import 'package:driving_school/models/message_model.dart'; // Added
import 'package:driving_school/models/fuel_receipt_model.dart';
import 'package:driving_school/models/maintenance_receipt_model.dart';
import 'package:driving_school/views/admin/admin_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driving_school/services/cloudinary_service.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


class AdminController extends ChangeNotifier {
  FirebaseAuth? _firebaseAuth;
  FirebaseAuth get firebaseAuth => _firebaseAuth ??= FirebaseAuth.instance;
  
  FirebaseFirestore? _firebaseFirestore;
  FirebaseFirestore get firebaseFirestore => _firebaseFirestore ??= FirebaseFirestore.instance;

  /////////////////RETEST MANAGEMENT///////////////////
  List<RetestModel> retestList = [];

  Future fetchRetestApplications() async {
    try {
      retestList.clear();
      QuerySnapshot snapshot =
          await firebaseFirestore.collection('retest_applications').get();
      
      for (var doc in snapshot.docs) {
        final retest = RetestModel.fromMap(doc.data() as Map<String, dynamic>);
        retestList.add(retest);
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching retest applications: $e');
    }
  }

  Future<void> assignTestDate(String retestID, String testDate, BuildContext context) async {
    try {
      await firebaseFirestore.collection('retest_applications').doc(retestID).update({
        'testDate': testDate,
      });
      
      // Update local list
      int index = retestList.indexWhere((element) => element.id == retestID);
      if (index != -1) {
        retestList[index].testDate = testDate;
        notifyListeners();
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Test Date assigned successfully'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to assign Test Date: $e'),
        backgroundColor: Colors.red,
      ));
      print("Error assigning test date: $e");
    }
  }


  String adminID = 'admin@driving.com';
  
  List<RatingModel> ratingsList = [];
  double averageRating = 0.0;

  Future<void> fetchRatings(String instructorID) async {
    try {
      ratingsList.clear();
      averageRating = 0.0;
      double totalScore = 0.0;

      QuerySnapshot snapshot = await firebaseFirestore
          .collection('ratings')
          .where('instructorID', isEqualTo: instructorID)
          .get();

      for (var doc in snapshot.docs) {
        RatingModel rating = RatingModel.fromMap(doc.data() as Map<String, dynamic>);
        ratingsList.add(rating);
        totalScore += rating.score;
      }

      if (ratingsList.isNotEmpty) {
        averageRating = totalScore / ratingsList.length;
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching ratings: $e");
    }
  }
  String adminPassword = '123456';
  GlobalKey<FormState> adminLoginKey = GlobalKey<FormState>();
  TextEditingController adminIDController = TextEditingController();
  TextEditingController adminPasswordController = TextEditingController();

  ///////////////////DATABASE OPERATIONS////////////////////////////////////////
  String? _adminid;
  String get adminid => _adminid!;
  Future<void> adminLogin(String username, String password, context) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: username, password: password);
      _adminid = firebaseAuth.currentUser!.uid;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AdminHome(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // If login fails, try to create the admin account automatically
      try {
        await firebaseAuth.createUserWithEmailAndPassword(
            email: username, password: password);
        _adminid = firebaseAuth.currentUser!.uid;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Admin account created successfully! Logging in...',
            ),
          ),
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AdminHome(),
          ),
        );
      } catch (createError) {
        // If creation fails (e.g. user exists but wrong password), show original error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Login Failed: ${e.message}\n(Auto-creation also failed: ${createError.toString()})",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  List<UserModel> usersDataList = [];
  UserModel? users;

  Future fetchUsers() async {
    try {
      usersDataList.clear();

      CollectionReference usersCollection =
          firebaseFirestore.collection('users');
      QuerySnapshot usersSnapshot = await usersCollection.get();

      for (var doc in usersSnapshot.docs) {
        String userID = doc['userID'];
        String userName = doc['userName'];
        String userEmail = doc['userEmail'];
        int userNumber = doc['userNumber'];
        String? userProPic = doc['userProPic'];
        String selectedCourse = doc['selectedCourse'] ?? 'No Course Selected';

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        String? selectionDate = data.containsKey('instructorSelectionDate') ? data['instructorSelectionDate'] : null;
        String selectedInstructor = data['selectedInstructor'] ?? 'No Instructor Selected';

        if (selectedInstructor != 'No Instructor Selected') {
          if (selectionDate != today) {
            selectedInstructor = 'No Instructor Selected';
            selectionDate = null;
          }
        }

        users = UserModel(
            userID: userID,
            userName: userName,
            userEmail: userEmail,
            userNumber: userNumber,
            userProPic: userProPic,
            selectedCourse: selectedCourse,
            selectedInstructor: selectedInstructor,
            instructorSelectionDate: selectionDate);

        usersDataList.add(users!);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteUser(String userID, BuildContext context) async {
    try {
      await firebaseFirestore.collection('users').doc(userID).delete();
      await fetchUsers();
      notifyListeners();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  GlobalKey<FormState> courseAddKey = GlobalKey<FormState>();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController courseHoursController = TextEditingController();
  TextEditingController coursePriceController = TextEditingController();
  CourseModel? _courseModel;
  CourseModel get courseModel => _courseModel!;

  Future<void> saveCourse(
    String courseName,
    int courseHours,
    int coursePrice,
  ) async {
    final courseDoc = firebaseFirestore.collection('courses').doc();
    _courseModel = CourseModel(
        courseID: courseDoc.id,
        courseName: courseName,
        courseHours: courseHours,
        coursePrice: coursePrice);
    await courseDoc.set(_courseModel!.toMap());
    notifyListeners();
  }

  List<CourseModel> coursesList = [];
  CourseModel? courses;

  Future fetchCourses() async {
    try {
      coursesList.clear();

      CollectionReference coursesCollection =
          firebaseFirestore.collection('courses');
      QuerySnapshot coursesSnapshot = await coursesCollection.get();

      for (var doc in coursesSnapshot.docs) {
        String courseID = doc['courseID'];
        String courseName = doc['courseName'];
        int courseHours = doc['courseHours'];
        int coursePrice = doc['coursePrice'];

        courses = CourseModel(
            courseID: courseID,
            courseName: courseName,
            courseHours: courseHours,
            coursePrice: coursePrice);

        coursesList.add(courses!);
      }
      // notifyListeners(); // Removed to prevent infinite loop
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteCourse(String courseID, context) async {
    try {
      await firebaseFirestore.collection('courses').doc(courseID).delete();
      await fetchCourses();
      notifyListeners(); // Update UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Course deleted successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to delete course: $e'),
        ),
      );
    }
  }

  Future<void> updateCourse(CourseModel course, context) async {
    try {
      await firebaseFirestore
          .collection('courses')
          .doc(course.courseID)
          .update(course.toMap());
      await fetchCourses();
      notifyListeners(); // Update UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Course updated successfully'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to update course: $e'),
        ),
      );
    }
  }

  GlobalKey<FormState> instrcutorAddKey = GlobalKey<FormState>();
  TextEditingController instrcutorNameController = TextEditingController();
  TextEditingController instrcutorNumberController = TextEditingController();
  TextEditingController instructorEmailController = TextEditingController();
  TextEditingController instructorUpiController = TextEditingController(); // Added for Salary Payment

  InstructorModel? _instructorModel;
  InstructorModel get instructorModel => _instructorModel!;

  String? _instructorid;
  String get instructorid => _instructorid!;

  Future<void> saveInstructor(
    String instructorName,
    int instructorNumber,
    String instructorEmail,
    String instructorProPic,
    String status,
    String? upiId,
  ) async {
    final instructorDoc = firebaseFirestore.collection('instructors').doc();
    _instructorModel = InstructorModel(
        instructorID: instructorDoc.id,
        instructorName: instructorName,
        instructorNumber: instructorNumber,
        instructorEmail: instructorEmail,
        instructorProPic: instructorProPic,
        status: status,
        upiId: upiId);

    await instructorDoc.set(_instructorModel!.toMap());

    _instructorid = instructorDoc.id;
    print('//////INSTRUCTOR ID : $_instructorid //////////////');
    notifyListeners();
  }

  List<InstructorModel> instructorsList = [];
  InstructorModel? instructors;

  Future fetchInstructors() async {
    try {
      instructorsList.clear();

      CollectionReference instructorsCollection =
          firebaseFirestore.collection('instructors');
      QuerySnapshot instructorSnapshot = await instructorsCollection.get();

      for (var doc in instructorSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String instructorID = data['instructorID'];
        String instructorName = data['instructorName'];
        int instructorNumber = data['instructorNumber'];
        String? instructorEmail = data.containsKey('instructorEmail') ? data['instructorEmail'] : null;
        String? instructorProPic = data['instructorProPic'];
        String status = data.containsKey('status') ? data['status'] : 'Available';
        String? upiId = data.containsKey('upiId') ? data['upiId'] : null;

        instructors = InstructorModel(
            instructorID: instructorID,
            instructorName: instructorName,
            instructorNumber: instructorNumber,
            instructorEmail: instructorEmail,
            instructorProPic: instructorProPic,
            status: status,
            upiId: upiId);

        instructorsList.add(instructors!);
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  double availableSalaryFunds = 0.0;
  
  Future<void> fetchAvailableSalaryFunds() async {
    try {
      final transfersSnap = await firebaseFirestore.collection('super_admin_transfers').get();
      double totalTransferred = 0.0;
      for (var doc in transfersSnap.docs) {
        if (doc.data() is Map && (doc.data() as Map).containsKey('amount')) {
          totalTransferred += double.tryParse(doc['amount'].toString()) ?? 0.0;
        }
      }

      final salariesSnap = await firebaseFirestore.collection('salaries').where('status', isEqualTo: 'Paid').get();
      double totalPaid = 0.0;
      for (var doc in salariesSnap.docs) {
        if (doc.data().containsKey('amount')) {
          totalPaid += double.tryParse(doc['amount'].toString()) ?? 0.0;
        }
      }

      availableSalaryFunds = totalTransferred - totalPaid;
      notifyListeners();
    } catch (e) {
      print("Error fetching salary funds: $e");
    }
  }

  Future<void> deleteInstructor(String instructorID, context) async {
    try {
      await firebaseFirestore
          .collection('instructors')
          .doc(instructorID)
          .delete();
      await fetchInstructors();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Instructor deleted successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to delete instructor: $e'),
        ),
      );
    }
  }

  Future<void> updateInstructor(
      InstructorModel instructor, XFile? newProPic, context) async {
    try {
      String? proPicUrl = instructor.instructorProPic;

      if (newProPic != null) {
        // Upload new image if selected
        proPicUrl = await storeImagetoStorge(
            'Instructors Profile Pic/${instructor.instructorID}', newProPic);
      }

      InstructorModel updatedInstructor = InstructorModel(
          instructorID: instructor.instructorID,
          instructorName: instructor.instructorName,
          instructorNumber: instructor.instructorNumber,
          instructorEmail: instructor.instructorEmail,
          instructorProPic: proPicUrl!,
          status: instructor.status,
          upiId: instructor.upiId);

      await firebaseFirestore
          .collection('instructors')
          .doc(instructor.instructorID)
          .update(updatedInstructor.toMap());

      await fetchInstructors();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Instructor updated successfully'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to update instructor: $e'),
        ),
      );
    }
  }

  Future<void> assignInstructorToUser(String userID, String instructorName, BuildContext context) async {
    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await firebaseFirestore.collection('users').doc(userID).update({
        'selectedInstructor': instructorName,
        'instructorSelectionDate': today,
      });
      // updating local list for instant UI refresh
      int index = usersDataList.indexWhere((u) => u.userID == userID);
      if (index != -1) {
        usersDataList[index].selectedInstructor = instructorName;
        usersDataList[index].instructorSelectionDate = today;
        notifyListeners();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student assigned to $instructorName successfully.'),
          backgroundColor: Colors.green,
        )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign instructor: $e'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  ////////////////////////////////////////////////////////////////////////

  Future<String> storeImagetoStorge(String ref, XFile file) async {
    // Migrating to Cloudinary
    // ref is treated as the folder structure
    String? downloadURL = await CloudinaryService.uploadFile(file, ref);
    
    if (downloadURL != null) {
      log('Cloudinary URL: $downloadURL');
      notifyListeners();
      return downloadURL;
    } else {
       throw 'Cloudinary Upload Failed';
    }
  }

  XFile? proPic;
  String? proPicPath;

  Future<XFile> pickproPic(context) async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        proPic = pickedImage;
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
    return proPic!;
  }

  Future<void> selectproPic(context) async {
    proPic = await pickproPic(context);
    proPicPath = proPic!.path;
    notifyListeners();
  }

  Future uploadInstructorProPic(XFile proPic, String path, String userID) async {
    try {
      await storeImagetoStorge('$path/$userID', proPic).then((value) async {
        instructorModel.instructorProPic = value;

        DocumentReference docRef =
            firebaseFirestore.collection('instructors').doc(_instructorid);
        await docRef.update({'instructorProPic': value});
      });
      _instructorModel = instructorModel;
      print('Pic uploaded successfully');
      // clearCarsField();
      notifyListeners();
    } catch (e) {
      print('image upload failed :$e');
    }
  }

  List<InvoiceModel> invoiceList = [];
  List<InvoiceModel> filteredInvoiceList = [];
  InvoiceModel? invoices;
  DateTime? selectedInvoiceDate;

  Future fetchAllInvoices() async {
    try {
      invoiceList.clear();
      filteredInvoiceList.clear();
      CollectionReference invoiceCollection =
          firebaseFirestore.collection('invoices');
      QuerySnapshot invoiceSnapshot = await invoiceCollection.get();

      for (var doc in invoiceSnapshot.docs) {
        try {
          // Use safe parsing
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          // Handle loose types for price
          double price = 0.0;
          if (data['invoicePrice'] is int) {
             price = (data['invoicePrice'] as int).toDouble();
          } else if (data['invoicePrice'] is double) {
             price = data['invoicePrice'];
          } else if (data['invoicePrice'] is String) {
             price = double.tryParse(data['invoicePrice']) ?? 0.0;
          }

          InvoiceModel invoice = InvoiceModel(
            invoiceID: data['invoiceID'] ?? doc.id,
            invoiceUserName: data['invoiceUserName'] ?? 'Unknown User',
            invoiceCourseName: data['invoiceCourseName'] ?? 'Unknown Course',
            invoiceDate: data['invoiceDate'] ?? '',
            invoicePrice: price,
            dueDate: data['dueDate'] ?? '',
          );

          invoiceList.add(invoice);
        } catch (e) {
          print("Error parsing invoice ${doc.id}: $e");
          // Continue to next invoice
        }
      }
      filteredInvoiceList = List.from(invoiceList);
      notifyListeners();
    } catch (e) {
      print("Error fetching invoices: $e");
    }
  }

  void filterInvoicesByDate(DateTime date) {
    selectedInvoiceDate = date;
    String formattedDate = DateFormat("yyyy-MM-dd").format(date);
    
    // Attempting to match mostly on the date part if invoiceDate is full DateTime string
    // Or if invoiceDate is just "2024-05-12", match string directly or parsed.
    // Based on previous findings, invoiceDate seems to be DateTime.now().toString() which is YYYY-MM-DD HH:MM:SS.XXXX
    
    filteredInvoiceList = invoiceList.where((invoice) {
        try {
            // Parse invoice date string to DateTime to compare Year, Month, Day
            DateTime iDate = DateTime.parse(invoice.invoiceDate);
            return iDate.year == date.year && 
                   iDate.month == date.month && 
                   iDate.day == date.day;
        } catch (e) {
            // Fallback: check if string contains the formatted date (if stored differently)
            return invoice.invoiceDate.contains(formattedDate);
        }
    }).toList();
    
    notifyListeners();
  }

  void clearInvoiceFilter() {
    selectedInvoiceDate = null;
    filteredInvoiceList = List.from(invoiceList);
    notifyListeners();
  }

  GlobalKey<FormState> contactAddKey = GlobalKey<FormState>();
  TextEditingController contactNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();

  ContactModel? _contactModel;
  ContactModel get contactModel => _contactModel!;

  String? _contactid;
  String get contactid => _contactid!;

  Future<void> saveContact(
    String contactName,
    int contactNumber,
  ) async {
    final contactDoc = firebaseFirestore.collection('contacts').doc();
    _contactModel = ContactModel(
        contactID: contactDoc.id,
        contactName: contactName,
        contactNumber: contactNumber);

    await contactDoc.set(_contactModel!.toMap());

    _contactid = contactDoc.id;
    notifyListeners();
  }

  List<ContactModel> contactsList = [];
  ContactModel? contacts;

  Future fetchContacts() async {
    try {
      contactsList.clear();

      CollectionReference contactCollection =
          firebaseFirestore.collection('contacts');
      QuerySnapshot contactSnapshot = await contactCollection.get();

      for (var doc in contactSnapshot.docs) {
        String contactID = doc['contactID'];
        String contactName = doc['contactName'];
        int contactNumber = doc['contactNumber'];

        contacts = ContactModel(
            contactID: contactID,
            contactName: contactName,
            contactNumber: contactNumber);

        contactsList.add(contacts!);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteContact(String contactID, context) async {
    try {
      await FirebaseFirestore.instance
          .collection('contacts')
          .doc(contactID)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact deleted successfully')));
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete Contact: $e')));
    }
  }

  Future<void> updateContact(ContactModel contact, context) async {
    try {
      await firebaseFirestore
          .collection('contacts')
          .doc(contact.contactID)
          .update(contact.toMap());

      await fetchContacts();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Contact updated successfully'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to update contact: $e'),
        ),
      );
    }
  }

  ///////////////////////////////////////////////////////////////////////////

  Map<String, Map<DateTime, List<dynamic>>> userAttendance = {};
  List attendance = [];
  // List<Map<String, dynamic>> userAttendance = [];
  var today = DateTime.now();

  void onDaySelected(
      DateTime selectedDay, DateTime focusedDay, String userName) async {
    attendance.clear();
    String user = userName;
    today = selectedDay;

    if (!userAttendance.containsKey(user)) {
      userAttendance[user] = {};
    }

    if (userAttendance[user]!.containsKey(today)) {
      userAttendance[user]!.remove(today);
    } else {
      userAttendance[user]![today] = [selectedDay];
    }

    print('////////$user');
    print('///////////////${userAttendance[user]}');

    // Map<String, dynamic> attendanceData = {};
    // userAttendance.forEach((key, value) {
    //   attendanceData[key] = value;
    // });

    attendance.add(userAttendance[user]);

    await firebaseFirestore
        .collection('users')
        .doc(user)
        .update({'userAttendance': attendance.toString()});
    print('////////////////Attendance updated////////////////');
    notifyListeners();
  }

  fetchAttendance(
    String userName,
  ) async {
    try {
      DocumentSnapshot userDoc =
          await firebaseFirestore.collection('users').doc(userName).get();

      // Retrieve userAttendance data from Firestore
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('userAttendance')) {
        // Parse the userAttendance data from String to List<Map<String, dynamic>>
        List<Map<String, dynamic>> userAttendanceData =
            jsonDecode(userData['userAttendance']);

        // Convert the List<Map<String, dynamic>> to the desired map structure
        Map<DateTime, List<dynamic>> attendanceData = {};

        userAttendanceData.forEach((attendanceMap) {
          attendanceMap.forEach((key, value) {
            DateTime dateTimeKey = DateTime.parse(key);
            attendanceData[dateTimeKey] = List<dynamic>.from(value);
          });
        });

        // Update the local userAttendance variable
        userAttendance[userName] = attendanceData;

        print('User attendance data fetched successfully for $userName');
        notifyListeners(); // Notify listeners about the updated data
      } else {
        print('User attendance data not found for $userName');
      }
    } catch (e) {
      print('Error fetching user attendance data: $e');
    }
    // try {
    //   DocumentSnapshot userDoc =
    //       await firebaseFirestore.collection('users').doc(userName).get();

    //   // Retrieve userAttendance data from Firestore
    //   Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
    //   if (userData != null && userData.containsKey('userAttendance')) {
    //     // Convert the userAttendance data from String to the desired map type

    //     Map<String, dynamic> attendanceData =
    //         Map<String, dynamic>.from(userData['userAttendance']);

    //     // Update the local userAttendance variable
    //     userAttendance[userName] = attendanceData.cast<DateTime, List>();

    //     print('User attendance data fetched successfully for $userName');
    //     notifyListeners(); // Notify listeners about the updated data
    //   } else {
    //     print('User attendance data not found for $userName');
    //   }
    // } catch (e) {
    //   print('Error fetching user attendance data: $e');
    // }
  }

  TextEditingController attDateController = TextEditingController();
  TextEditingController attTimeController = TextEditingController();
  late DateTime selectedDate;
  final attKey = GlobalKey<FormState>();

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      attDateController.text = DateFormat('dd-MMM-yyyy').format(pickedDate);
      notifyListeners();
    }
  }

  // late TimeOfDay _selectedTime;

  Future<void> selectTime(context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // _selectedTime = picked;
      attTimeController.text = picked.format(context);
      notifyListeners();
    }
  }

  AttendanceModel? _attendanceModel;
  AttendanceModel get attendanceModel => _attendanceModel!;

  Future markAttendance(String attDate, String attTime, String userid,
      String trainerName, context) async {
    try {
      final attRef = firebaseFirestore
          .collection('users')
          .doc(userid)
          .collection('attendance')
          .doc(attDate);
      _attendanceModel = AttendanceModel(
          attID: attDate,
          attDate: attDate,
          attTime: attTime,
          userID: userid,
          trainerName: trainerName);

      await attRef.set(_attendanceModel!.toMap());
      Navigator.of(context).pop();
      attDateController.clear();
      attTimeController.clear();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  List<AttendanceModel> attList = [];
  AttendanceModel? attnds;
  Future fetchAtt(String userid) async {
    try {
      attList.clear();

      CollectionReference attndCollection = firebaseFirestore
          .collection('users')
          .doc(userid)
          .collection('attendance');
      QuerySnapshot attndSnapshot = await attndCollection.get();

      for (var doc in attndSnapshot.docs) {
        String attID = doc['attID'];
        String attDate = doc['attDate'];
        String attTime = doc['attTime'];
        String userID = doc['userID'];
        String trainerName = doc['trainerName'];

        attnds = AttendanceModel(
            attID: attID,
            attDate: attDate,
            attTime: attTime,
            userID: userID,
            trainerName: trainerName);

        attList.add(attnds!);
      }
    } catch (e) {
      print(e);
    }
  }



  /////////////////SLOT MANAGMENT///////////////////
  List<TimeSlotModel> timeSlotsList = [];
  TimeSlotModel? timeSlots;

  Future<void> addTimeSlot(String startTime, String endTime, context) async {
    try {
      DocumentReference docRef =
          firebaseFirestore.collection('time_slots').doc();
      TimeSlotModel newSlot = TimeSlotModel(
        slotID: docRef.id,
        startTime: startTime,
        endTime: endTime,
      );
      await docRef.set(newSlot.toMap());
      await fetchTimeSlots();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Time Slot Added'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add slot: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> deleteTimeSlot(String slotID, context) async {
    try {
      await firebaseFirestore.collection('time_slots').doc(slotID).delete();
      await fetchTimeSlots();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Time Slot Deleted'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print(e);
    }
  }

  Future fetchTimeSlots() async {
    try {
      timeSlotsList.clear();
      QuerySnapshot snapshot =
          await firebaseFirestore.collection('time_slots').orderBy('startTime').get();
      for (var doc in snapshot.docs) {
        timeSlots = TimeSlotModel(
          slotID: doc['slotID'],
          startTime: doc['startTime'],
          endTime: doc['endTime'],
        );
        timeSlotsList.add(timeSlots!);
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  List<BookingModel> bookingsList = [];
  BookingModel? bookings;

  Future fetchBookings() async {
    try {
      bookingsList.clear();
      QuerySnapshot snapshot = await firebaseFirestore
          .collection('bookings')
          .orderBy('date', descending: true)
          .get();
      for (var doc in snapshot.docs) {
        bookings = BookingModel(
          bookingID: doc['bookingID'],
          userID: doc['userID'],
          userName: doc['userName'],
          date: doc['date'],
          slotID: doc['slotID'],
          timeRange: doc['timeRange'],
        );
        bookingsList.add(bookings!);
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  /////////////////ANNOUNCEMENT MANAGEMENT///////////////////
  List<AnnouncementModel> announcementList = [];
  
  Future<void> addAnnouncement(String title, String description, String type, String audience, context) async {
    try {
      DocumentReference docRef = firebaseFirestore.collection('announcements').doc();
      String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      
      AnnouncementModel newAnnouncement = AnnouncementModel(
        id: docRef.id,
        title: title,
        description: description,
        date: date,
        type: type,
        audience: audience,
      );
      
      await docRef.set(newAnnouncement.toMap());
      await fetchAnnouncements();
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Announcement Posted Successfully'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to post announcement: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future fetchAnnouncements() async {
    try {
      announcementList.clear();
      QuerySnapshot snapshot = await firebaseFirestore.collection('announcements').orderBy('date', descending: true).get();
      
      for (var doc in snapshot.docs) {
        announcementList.add(AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching announcements: $e');
    }
  }

  Future<void> deleteAnnouncement(String id, context) async {
    try {
      await firebaseFirestore.collection('announcements').doc(id).delete();
      await fetchAnnouncements();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Announcement Deleted'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print(e);
    }
  }

  /////////////////ANALYTICS///////////////////

  int get totalStudents => usersDataList.length;
  int get totalInstructors => instructorsList.length;
  int get totalCourses => coursesList.length;

  double getCurrentMonthRevenue() {
    double total = 0.0;
    DateTime now = DateTime.now();
    for (var invoice in invoiceList) {
      try {
        // Assuming invoiceDate is stored as a string compatible with DateTime.parse
        // If it's stored as dd-MM-yyyy, we might need DateFormat.
        // Let's check how it's stored. In saveInvoice it says: final date = DateTime.parse(invoiceDate);. 
        // But invoiceDate argument to saveInvoice comes from UI. 
        // In other places, DateFormat('dd-MMM-yyyy') is used for display.
        // Let's be safe and try direct parse, if fail, try format.
        // Actually, looking at fetchAllInvoices, it just reads the string.
        // Let's try parsing. If it fails, we catch it.
        DateTime date = DateTime.parse(invoice.invoiceDate); 
        if (date.year == now.year && date.month == now.month) {
          total += invoice.invoicePrice;
        }
      } catch (e) {
        // If direct parse fails, it might be in a specific format like dd-MM-yyyy or similar.
        // However, standard DateTime.now().toString() is often used or ISO8601.
        // If it was saved using DateFormat('dd-MM-yyyy'), then we need that.
        // Let's assume standard parse for now or logging the error.
        print("Error parsing invoice date for analytics: ${invoice.invoiceDate} - $e");
      }
    }
    return total;
  }

  List<MapEntry<String, int>> getCoursePopularity() {
    Map<String, int> popularity = {};
    for (var invoice in invoiceList) {
      if (popularity.containsKey(invoice.invoiceCourseName)) {
        popularity[invoice.invoiceCourseName] = popularity[invoice.invoiceCourseName]! + 1;
      } else {
        popularity[invoice.invoiceCourseName] = 1;
      }
    }
    var sortedEntries = popularity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Descending order
    return sortedEntries;
  }

  // ---------------- ADMIN CHAT IMPLEMENTATION ----------------
  
  // Send message as Admin
  Future<void> sendAdminMessage(String userId, String text) async {
    if (text.trim().isEmpty) return;

    final message = MessageModel(
      senderId: 'ADMIN', // Special ID for Admin
      text: text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    try {
      await firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('messages')
          .add(message.toMap());
          
      // Ensure we update lastMessageTime so it stays at top of list
      await firebaseFirestore.collection('users').doc(userId).update({
        'lastMessageTime': DateTime.now(),
      });
      
    } catch (e) {
      print("Error sending admin message: $e");
    }
  }

  // Get messages for a specific user
  Stream<List<MessageModel>> getAdminMessages(String userId) {
    return firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data());
      }).toList();
    });
  }

  // Get list of users who have chatted, sorted by recent activity
  Stream<List<UserModel>> getChatUsers() {
    return firebaseFirestore
        .collection('users')
        .where('lastMessageTime', isNull: false) // Only get users who have chatted
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data()); // Assuming UserModel.fromMap handles existing fields securely
      }).toList();
    });
  }


  Future<void> markMessagesAsRead(String userId) async {
    try {
      await firebaseFirestore.collection('users').doc(userId).update({
        'hasUnreadMessages': false,
      });
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  Future<void> updateCourseCompletionStatus(String userId, bool isCompleted, BuildContext context) async {
    try {
      await firebaseFirestore.collection('users').doc(userId).update({
        'isCourseCompleted': isCompleted,
      });
      
      // Update local user list if exists
      int index = usersDataList.indexWhere((user) => user.userID == userId);
      if (index != -1) {
        usersDataList[index].isCourseCompleted = isCompleted;
        notifyListeners();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isCompleted ? 'Course Marked as Completed' : 'Course Marked as Incomplete'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("Error updating completion status: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update status: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ---- Admin Leave Management ----
  Stream<List<InstructorLeaveModel>> getAllLeaveRequests() {
    return firebaseFirestore
        .collection('instructor_leaves')
        .orderBy('appliedOn', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InstructorLeaveModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateLeaveStatus(String leaveId, String newStatus, BuildContext context) async {
    try {
      await firebaseFirestore.collection('instructor_leaves').doc(leaveId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leave marked as $newStatus.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update leave status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ---- Admin Vehicle Management ----
  Future<void> addVehicle({
    required String plateNumber,
    required String modelName,
    required BuildContext context,
    DateTime? insuranceExpiry,
    DateTime? pucExpiry,
  }) async {
    try {
      final newRef = firebaseFirestore.collection('vehicles').doc();
      final vehicle = VehicleModel(
        id: newRef.id,
        plateNumber: plateNumber,
        modelName: modelName,
        status: 'Active',
        insuranceExpiry: insuranceExpiry,
        pucExpiry: pucExpiry,
      );
      await newRef.set(vehicle.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle added successfully.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add vehicle: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Stream<List<VehicleModel>> getAllVehicles() {
    return firebaseFirestore.collection('vehicles').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => VehicleModel.fromMap(doc.data(), doc.id)).toList()
    );
  }

  Future<void> updateVehicleStatus(String vehicleId, String newStatus, BuildContext context) async {
    try {
      await firebaseFirestore.collection('vehicles').doc(vehicleId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle marked as $newStatus.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update vehicle status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> updateVehicleExpiry(String vehicleId, DateTime? insuranceExpiry, DateTime? pucExpiry, BuildContext context) async {
    try {
      await firebaseFirestore.collection('vehicles').doc(vehicleId).update({
        'insuranceExpiry': insuranceExpiry?.toIso8601String(),
        'pucExpiry': pucExpiry?.toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expiry dates updated.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update expiry: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ---- Trip Log Management ----
  Future<void> addTripLog(TripLogModel log, BuildContext context) async {
    try {
      final docRef = firebaseFirestore.collection('trip_logs').doc();
      await docRef.set({...log.toMap(), 'id': docRef.id});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip logged successfully.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log trip: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Stream<List<TripLogModel>> getTripLogsByVehicle(String vehicleId) {
    return firebaseFirestore
        .collection('trip_logs')
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => TripLogModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.tripDate.compareTo(a.tripDate));
          return list;
        });
  }

  Stream<List<TripLogModel>> getAllTripLogs() {
    return firebaseFirestore
        .collection('trip_logs')
        .orderBy('tripDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TripLogModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ---- Admin Fuel Receipts Management ----
  Stream<List<FuelReceiptModel>> getAllFuelReceipts() {
    return firebaseFirestore
        .collection('fuel_receipts')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FuelReceiptModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateFuelReceiptStatus(String receiptId, String newStatus, BuildContext context) async {
    try {
      await firebaseFirestore.collection('fuel_receipts').doc(receiptId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receipt marked as $newStatus.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update receipt status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ---- Admin Maintenance Receipts Management ----
  Stream<List<MaintenanceReceiptModel>> getAllMaintenanceReceipts() {
    return firebaseFirestore
        .collection('maintenance_receipts')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceReceiptModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<MaintenanceReceiptModel>> getMaintenanceByVehicle(String vehicleId) {
    return firebaseFirestore
        .collection('maintenance_receipts')
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => MaintenanceReceiptModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  Future<void> updateMaintenanceReceiptStatus(String receiptId, String newStatus, BuildContext context) async {
    try {
      await firebaseFirestore.collection('maintenance_receipts').doc(receiptId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maintenance bill marked as $newStatus.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
      );
    }
  }
}


