import 'dart:developer';
import 'dart:io';

import 'package:driving_school/views/choose_user.dart'; // Added
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:driving_school/models/invoice_model.dart';
import 'package:driving_school/models/user_model.dart';
import 'package:driving_school/views/admin/admin_leave_screen.dart';
import 'package:driving_school/views/admin/admin_vehicles_screen.dart';
import 'package:driving_school/views/admin/admin_fuel_screen.dart';
import 'package:driving_school/models/message_model.dart'; // Added
import 'package:driving_school/models/student_skill_model.dart'; // Added for radar
import 'package:driving_school/models/waitlist_model.dart'; // Added
import 'package:driving_school/models/rc_renewal_model.dart'; // Added
import 'package:driving_school/models/retest_model.dart'; // Added
import 'package:driving_school/models/rating_model.dart'; // Added
import 'package:driving_school/models/booking_model.dart'; // Added
import 'package:driving_school/utils/authentication_dialogue_widget.dart';
import 'package:driving_school/services/notification_service.dart'; // Correctly placed
import 'package:easy_localization/easy_localization.dart'; // Added
import 'package:driving_school/views/admin/manage_contact.dart';
import 'package:driving_school/views/admin/manage_course.dart';
import 'package:driving_school/views/admin/manage_instructor.dart';
import 'package:driving_school/views/admin/manage_invoice.dart';
import 'package:driving_school/views/admin/manage_rc.dart';
import 'package:driving_school/views/admin/manage_slot.dart';
import 'package:driving_school/views/admin/view_bookings.dart'; // Added back
import 'package:driving_school/views/admin/test_management.dart';  
import 'package:driving_school/views/admin/users_list.dart';
import 'package:driving_school/views/admin/manage_announcements.dart';
import 'package:driving_school/views/admin/admin_finance_screen.dart'; // Added
import 'package:driving_school/views/admin/admin_chat_list.dart'; // Added
import 'package:driving_school/views/admin/admin_salary_screen.dart'; // Added
import 'package:driving_school/views/user/contact_us.dart';
import 'package:driving_school/views/user/courses.dart';
import 'package:driving_school/views/user/history.dart';
import 'package:driving_school/views/user/invoice.dart';
import 'package:driving_school/views/user/select_instructor.dart';
import 'package:driving_school/views/user/slot_booking.dart';
import 'package:driving_school/views/user/apply_retest.dart'; 
import 'package:driving_school/views/user/apply_rc_renewal.dart'; // Added
import 'package:driving_school/views/user/view_book.dart'; // Added
import 'package:driving_school/views/user/user_profile.dart';
import 'package:driving_school/views/user/payment_successfull.dart'; // Added
import 'package:driving_school/views/user/mock_test_screen.dart'; // Added
import 'package:driving_school/views/user/user_home.dart';
// import 'package:driving_school/views/user/ar_parking_screen.dart';
import 'package:driving_school/views/user/add_user_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:driving_school/services/cloudinary_service.dart';
import 'package:driving_school/views/user/my_applications.dart'; // Added
import 'package:driving_school/models/message_model.dart'; // Added
import 'package:driving_school/views/shared/announcements_feed.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


class UserController extends ChangeNotifier {
  //////////////////////////////////////////////////////////////////////////////

  List<Map<String, dynamic>> adminServiceList = [
    // Row 1
    {
      'service name': 'Users',
      'image': 'assets/man 1.png',
      'onTap': const UsersList()
    },
    {
      'service name': 'Manage Course',
      'image': 'assets/settings 1.png',
      'onTap': const ManageCourse()
    },
    {
      'service name': 'Manage Invoice',
      'image': 'assets/taxation 1.png',
      'onTap': const ManageInvoice(),
    },
    // Row 2
    {
      'service name': 'Manage Instructor',
      'image': 'assets/teacher 1.png',
      'onTap': const ManageInstructor(),
    },
    {
      'service name': 'Manage RC Renewal',
      'image': 'assets/rc_renewal_logo.jpg',
      'onTap': const ManageRC(),
    },
    {
      'service name': 'Manage Slot',
      'image': 'assets/slot_booking.jpg',
      'onTap': const ManageSlot(),
    },
    // Row 3
    {
      'service name': 'Test Management',
      'image': 'assets/retest_icon.jpg',
      'onTap': const TestManagement(),
    },
    {
      'service name': 'View Bookings',
      'image': 'assets/view_bookings_icon.jpg',
      'onTap': const ViewBookings(),
    },
    {
      'service name': 'Announcements',
      'image': 'assets/logo.png',
      'onTap': const ManageAnnouncements(),
    },
    // Remaining features
    {
      'service name': 'Leave Approvals',
      'image': 'assets/leave_approval_logo.jpg',
      'onTap': const AdminLeaveScreen()
    },
    {
      'service name': 'Vehicles',
      'image': 'assets/admin_vehicle_logo.jpg',
      'onTap': const AdminVehiclesScreen()
    },
    {
      'service name': 'Fuel Logs',
      'image': 'assets/fuel_approval_logo.jpg',
      'onTap': const AdminFuelScreen()
    },
    {
      'service name': 'Financials',
      'image': 'assets/view_book_icon.jpg',
      'onTap': const AdminFinanceScreen()
    },
    {
      'service name': 'FAQ & Feedback',
      'image': 'assets/headphones 1.png',
      'onTap': const ManageContact(),
    },
    {
      'service name': 'Student Messages',
      'image': 'assets/chat_icon_gradient.jpg',
      'onTap': const AdminChatList(),
    },
    {
      'service name': 'Salary Payment',
      'image': 'assets/taxation 1.png',
      'onTap': const AdminSalaryScreen(),
    },
  ];

  List<Map<String, dynamic>> userServiceList = [
    {
      'service name': 'profile'.tr(),
      'image': 'assets/man 1.png',
      'onTap': const UserProfile()
    },
    {
      'service name': 'courses'.tr(),
      'image': 'assets/settings 1.png',
      'onTap': const Courses()
    },
    {
      'service name': 'Invoice',
      'image': 'assets/taxation 1.png',
      'onTap': const Invoice(),
    },
    {
      'service name': 'Instructor',
      'image': 'assets/teacher 1.png',
      'onTap': const ChooseInstructor(),
    },
    {
      'service name': 'History',
      'image': 'assets/logout 1.png',
      'onTap': const History(),
    },
    {
      'service name': 'View Book',
      'image': 'assets/view_book_icon.jpg', // Updated icon
      'onTap': const ViewBook(),
    },
    {
      'service name': 'Contact',
      'image': 'assets/headphones 1.png',
      'onTap': const ContactUs(),
    },
    {
      'service name': 'Slot Booking',
      'image': 'assets/slot_booking.jpg',
      'onTap': const SlotBooking(),
    },
    {
      'service name': 'Certificate',
      'image': 'assets/c-tick logo.png', // Reusing tick logo for certificate
      'onTap': null, // We will handle this efficiently in the view or with a logical check
    },
    {
      'service name': 'Apply for Retest',
      'image': 'assets/retest_logo.jpg', 
      'onTap': const ApplyRetest(),
    },
    {
      'service name': 'mock_test'.tr(),
      'image': 'assets/mock_test_logo.jpg', 
      'onTap': const MockTestScreen(),
    },
    {
      'service name': 'RC Renewal',
      'image': 'assets/rc_renewal_logo.jpg', 
      'onTap': const ApplyRcRenewal(),
    },
    {
      'service name': 'My App status',
      'image': 'assets/my_applications_logo.jpg', 
      'onTap': const MyApplications(),
    },
    {
      'service name': 'My Progress',
      'image': 'assets/my_progress_logo.jpg',
      'onTap': null,  // handled specially in dashboard_grid_widget.dart
    },
    {
      'service name': 'Announcements',
      'image': 'assets/logo.png', // Reusing the logo for announcements
      'onTap': const AnnouncementsFeed(),
    },
    // ...
    //   'service name': 'AR Parking',
    //   'image': 'assets/slot_booking.jpg', 
    //   'onTap': const ARParkingScreen(),
    // },
  ];

  List<Map<String, dynamic>> usersList = [
    {'name': 'Rohith', 'image': 'assets/man 1.png', 'phone': 9876543210},
    {'name': 'Sanay', 'image': 'assets/man 1.png', 'phone': 9876543210},
    {'name': 'Akbar', 'image': 'assets/man 1.png', 'phone': 9876543210},
  ];
  List<Map<String, dynamic>> instrctrList = [
    {'name': 'Rohith', 'image': 'assets/teacher 1.png'},
    {'name': 'Sanay', 'image': 'assets/teacher 1.png'},
    {'name': 'Akbar', 'image': 'assets/teacher 1.png'},
    {'name': 'Rohith', 'image': 'assets/teacher 1.png'},
    {'name': 'Sanay', 'image': 'assets/teacher 1.png'},
    {'name': 'Akbar', 'image': 'assets/teacher 1.png'},
  ];
  List<Map<String, dynamic>> courseList = [
    {'name': 'Uniform driving hours (colved)', 'price': 1.00},
    {'name': 'Uniform driving hours (colved)', 'price': 112.00},
    {'name': 'Uniform driving hours (colved)', 'price': 39.00},
    {'name': 'Uniform driving hours (colved)', 'price': 112.00},
  ];

  //////////////////////////////////////////////////////////////////////////////

  GlobalKey<FormState> numberKey = GlobalKey<FormState>();
  GlobalKey<FormState> userDetailsKey = GlobalKey<FormState>();
  TextEditingController numberController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();

  //---------------For country Pick-------------------

  Country selectedCountry = Country(
      phoneCode: "91",
      countryCode: "IN",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "India",
      example: 'India',
      displayName: 'India',
      displayNameNoCountryCode: "IN",
      e164Key: "");

  showCountries(context) {
    showCountryPicker(
      context: context,
      countryListTheme: const CountryListThemeData(bottomSheetHeight: 600),
      onSelect: (value) {
        selectedCountry = value;
        notifyListeners();
      },
    );
  }

  void setPhonenumber(String value, context) {
    numberController.text = value;
    if (value.length == 10) {
      if (!kIsWeb) {
        sendOTP(context);
        FocusScope.of(context).unfocus();
      }
    }
    notifyListeners();
  }

  String? otpError;
  String verificationCode = '';
  
  FirebaseAuth? _firebaseAuth;
  FirebaseAuth get firebaseAuth => _firebaseAuth ??= FirebaseAuth.instance;
  
  FirebaseFirestore? _firebaseFirestore;
  FirebaseFirestore get firebaseFirestore => _firebaseFirestore ??= FirebaseFirestore.instance;

  String? otpCode;

  String? _uid;
  String get uid => _uid!;

  bool isOtpSent = false;
  ConfirmationResult? webConfirmationResult;

  Future<void> sendOTP(context) async {
    isOtpSent = false;
    notifyListeners();
    
    showDialog(
      context: context,
      builder: (context) {
        return const AuthenticationDialogueWidget(
          message: 'Authenticating, Please wait...',
        );
      },
    );
    String userPhoneNumber = numberController.text.trim();
    
    // MOCK AUTHENTICATION BYPASS
    if (userPhoneNumber == '0000000000') {
      isOtpSent = true;
      notifyListeners();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Sent (Mock Mode)')),
      );
      return;
    }

    if (kIsWeb) {
      try {
        print("Attempting to signInWithPhoneNumber: +${selectedCountry.phoneCode}$userPhoneNumber");
        webConfirmationResult = await firebaseAuth.signInWithPhoneNumber(
          "+${selectedCountry.phoneCode}$userPhoneNumber",
        );
        print("signInWithPhoneNumber success. Result: $webConfirmationResult");
        isOtpSent = true;
        notifyListeners(); // Notify to update UI (enable Verify button)

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'OTP Sent to +${selectedCountry.phoneCode}$userPhoneNumber',
            ),
          ),
        );
      } catch (e) {
        isOtpSent = false;
        otpError = e.toString();
        print("signInWithPhoneNumber FAILED: $e");
        
        String errorMessage = "Send Failed: $e";
        if (e.toString().contains("BILLING_NOT_ENABLED")) {
          errorMessage = "Billing not enabled. Please use the Test Number (0000000000) for testing.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              errorMessage,
              style: GoogleFonts.epilogue(
                color: Colors.white,
              ),
            ),
          ),
        );
        Navigator.pop(context);
        log("Verification failed $e");
      }
    } else {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+${selectedCountry.phoneCode}$userPhoneNumber",
        verificationCompleted: (phoneAuthCredential) {},
        verificationFailed: (FirebaseAuthException error) {
          otpError = error.toString();
          
          String errorMessage = error.toString();
          if (error.toString().contains("BILLING_NOT_ENABLED")) {
            errorMessage = "Billing not enabled. Please use the Test Number (0000000000) for testing.";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                errorMessage,
                style: GoogleFonts.epilogue(
                  color: Colors.white,
                ),
              ),
            ),
          );

          Navigator.pop(context);

          log("Verification failed $error");
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          verificationCode = verificationId;
          log(verificationCode);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'OTP Sent to +${selectedCountry.phoneCode}$userPhoneNumber',
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
    _uid = firebaseAuth.currentUser?.uid;
    log("OTP Sent to +${selectedCountry.phoneCode}$userPhoneNumber");

    notifyListeners();
  }

  // Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return const AuthenticationDialogueWidget(
            message: 'Signing in with Google...',
          );
        },
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        Navigator.pop(context); // Close dialog
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        _uid = user.uid;
        bool exists = await checkExistingUser();
        
        Navigator.pop(context); // Close dialog

        if (exists) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => UserHome(uid: _uid!),
            ),
          );
        } else {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const AddUserDetails(),
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context); // Close dialog in case of error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print("Google Sign-In Error: $e");
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      // 1. Clear Data
      _userModel = null;
      _uid = null;
      
      // 2. Sign Out Services
      await _googleSignIn.signOut(); 
      await firebaseAuth.signOut(); 

      // 3. Navigate away (Do not notify listeners to avoid rebuilding dying widgets with null data)
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

  verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
    required Function onSuccess,
  }) async {
    // MOCK VERIFICATION BYPASS
    if (numberController.text.trim() == '0000000000' && userOTP == '123456') {
      _uid = "test_user_id";
      onSuccess();
      return;
    }
    if (kIsWeb && !isOtpSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please Click 'Send OTP' first!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return const AuthenticationDialogueWidget(
          message: 'Verifying OTP...',
        );
      },
    );
    try {
      if (kIsWeb) {
        if (webConfirmationResult != null) {
          UserCredential userCredential =
              await webConfirmationResult!.confirm(userOTP);
          if (userCredential.user != null) {
            _uid = userCredential.user!.uid;
            onSuccess();
          }
        } else {
          throw "Web confirmation result is null (OTP not sent?)";
        }
      } else {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: userOTP);
        User? user = (await firebaseAuth.signInWithCredential(credential)).user;
        if (user != null) {
          _uid = user.uid;
          onSuccess();
        }
      }
      log("OTP correct");
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
            style: GoogleFonts.epilogue(
              color: Colors.white,
            ),
          ),
        ),
      );
      log('$e');
    }
    notifyListeners();
  }

  /////////////////DATEBASE OPERATIONS/////////////////////////////////////////
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await firebaseFirestore.collection('users').doc(_uid).get();

    if (snapshot.exists) {
      log('USER EXISTS');
      return true;
    } else {
      log('NEW USER');
      return false;
    }
  }

  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  Future<void> saveUser(
    String userID,
    String userName,
    String userEmail,
    int userNumber,
  ) async {
    _userModel = UserModel(
      userID: userID,
      userName: userName,
      userEmail: userEmail,
      userNumber: userNumber,
    );

    await firebaseFirestore
        .collection('users')
        .doc(userID)
        .set(_userModel!.toMap());

    notifyListeners();
  }

  Future fetchUserData(String uid) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .get()
          .then((DocumentSnapshot snapshot) {
        _userModel = UserModel(
          userID: snapshot['userID'],
          userName: snapshot['userName'],
          userEmail: snapshot['userEmail'],
          userNumber: snapshot['userNumber'],
          userProPic: snapshot['userProPic'],
          selectedCourse: snapshot['selectedCourse'],
          selectedInstructor: snapshot['selectedInstructor'],
        );
      });
    } catch (e) {
      print(e);
    }
  }

  ////////////////////////////////////////////////////////////////////////////

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

  Future<XFile?> pickproPic(context) async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        proPic = pickedImage;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
    return proPic;
  }

  Future<void> selectproPic(context) async {
    final pickedFile = await pickproPic(context);
    if (pickedFile != null) {
      proPicPath = pickedFile.path;
      notifyListeners();
    }
  }

  Future<void> updateUser({
     required String userName,
     required String userEmail,
     required int userNumber,
     String? userProPic,
  }) async {
    try {
      final updateData = {
         'userName': userName,
         'userEmail': userEmail,
         'userNumber': userNumber,
      };

      if (userProPic != null) {
        updateData['userProPic'] = userProPic;
      }

      await firebaseFirestore
          .collection('users')
          .doc(_uid)
          .update(updateData);
      
      // Update local model
      if (_userModel != null) {
           _userModel = UserModel(
               userID: _userModel!.userID,
               userName: userName,
               userEmail: userEmail,
               userNumber: userNumber,
               userProPic: userProPic ?? _userModel!.userProPic,
               selectedCourse: _userModel!.selectedCourse,
               selectedInstructor: _userModel!.selectedInstructor
           );
      }

      notifyListeners();
    } catch (e) {
      print("Error updating user: $e");
      rethrow;
    }
  }


  Future uploadProPic(XFile proPic, String path, String userID) async {
    try {
      await storeImagetoStorge('$path/$userID', proPic).then((value) async {
        userModel.userProPic = value;

        DocumentReference docRef =
            firebaseFirestore.collection('users').doc(_uid);
        docRef.update({'userProPic': value});
      });
      _userModel = userModel;
      print('Pic uploaded successfully');
      // clearCarsField();
      notifyListeners();
    } catch (e) {
      print('image upload failed :$e');
    }
  }

  InvoiceModel? _invoiceModel;
  InvoiceModel get invoiceModel => _invoiceModel!;

  Future<void> saveInvoice(
    String invoiceUserName,
    String invoiceCourseName,
    String invoiceDate,
    double invoicePrice,
  ) async {
    final date = DateTime.parse(invoiceDate);
    DateTime dueDate = date.add(const Duration(days: 30));
    String formttedDueDate = DateFormat("dd-MMM-yyy").format(dueDate);
    final docs = firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('invoices')
        .doc();
    _invoiceModel = InvoiceModel(
        invoiceID: docs.id,
        invoiceUserName: invoiceUserName,
        invoiceCourseName: invoiceCourseName,
        invoiceDate: invoiceDate,
        invoicePrice: invoicePrice,
        dueDate: formttedDueDate);

    await docs.set(_invoiceModel!.toMap());
    await firebaseFirestore
        .collection('invoices')
        .doc(docs.id)
        .set(_invoiceModel!.toMap());
  }

  List<InvoiceModel> invoiceList = [];
  InvoiceModel? invoices;

  Future fetchInvoices() async {
    try {
      invoiceList.clear();
      CollectionReference invoiceCollection = firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('invoices');
      QuerySnapshot invoiceSnapshot = await invoiceCollection.get();

      for (var doc in invoiceSnapshot.docs) {
        String invoiceID = doc['invoiceID'];
        String invoiceUserName = doc['invoiceUserName'];
        String invoiceCourseName = doc['invoiceCourseName'];
        String invoiceDate = doc['invoiceDate'];
        double invoicePrice = doc['invoicePrice'];
        String dueDate = doc['dueDate'];

        invoices = InvoiceModel(
            invoiceID: invoiceID,
            invoiceUserName: invoiceUserName,
            invoiceCourseName: invoiceCourseName,
            invoiceDate: invoiceDate,
            invoicePrice: invoicePrice,
            dueDate: dueDate);

        invoiceList.add(invoices!);
      }
    } catch (e) {
      print(e);
    }
  }

  Future updateCourse(String courseName) async {
    try {
      userModel.selectedCourse = courseName;

      DocumentReference docRef = firebaseFirestore
          .collection('users')
          .doc(uid);
      await docRef.update({'selectedCourse': courseName});
      _userModel = userModel;
      notifyListeners();
      print('/////////Course Updated/////////////');
    } catch (e) {
      print(e);
    }
  }

  Future updateInstructor(String instructorName, context) async {
    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      userModel.selectedInstructor = instructorName;
      userModel.instructorSelectionDate = today;

      DocumentReference docRef = firebaseFirestore
          .collection('users')
          .doc(uid);
      await docRef.update({
        'selectedInstructor': instructorName,
        'instructorSelectionDate': today,
      });
      _userModel = userModel;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Instructor Selected Successfully'),
        ),
      );
      print('/////////Instructor Updated/////////////');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to select instructor: $e'),
        ),
      );
      print(e);
    }
  }
  Future<void> addRating(RatingModel rating, BuildContext context) async {
    try {
      await firebaseFirestore.collection('ratings').doc(rating.ratingID).set(rating.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit rating: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print("Error adding rating: $e");
    }
  }

  /////////////////SLOT BOOKING///////////////////
  
  Map<String, int> slotBookingCounts = {};
  List<String> bookedSlotIds = []; 
  String? myBookingId; // Track current user's booking ID for the selected date
  String? myBookedSlotId; // Track current user's booked slot ID for the selected date
  Map<String, bool> myWaitlistStatus = {}; // slotID -> isWaitlisted

  Future<void> fetchBookedSlots(String date) async {
    try {
      slotBookingCounts.clear();
      bookedSlotIds.clear();
      myWaitlistStatus.clear();
      myBookingId = null;
      myBookedSlotId = null;
      
      QuerySnapshot snapshot = await firebaseFirestore
          .collection('bookings')
          .where('date', isEqualTo: date)
          .get();
      
      for (var doc in snapshot.docs) {
        String sId = doc['slotID'];
        String uId = doc['userID'];
        bookedSlotIds.add(sId);
        
        if (uId == uid) {
          myBookingId = doc['bookingID'];
          myBookedSlotId = sId;
        }

        if (slotBookingCounts.containsKey(sId)) {
          slotBookingCounts[sId] = slotBookingCounts[sId]! + 1;
        } else {
          slotBookingCounts[sId] = 1;
        }
      }

      
      // Fetch Waitlist Status
      QuerySnapshot waitlistSnapshot = await firebaseFirestore
          .collection('waitlist')
          .where('date', isEqualTo: date)
          .where('userID', isEqualTo: uid)
          .get();

      for (var doc in waitlistSnapshot.docs) {
         myWaitlistStatus[doc['slotID']] = true;
      }

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> joinWaitlist(String slotID, String date, BuildContext context) async {
    try {
      // Get FCM Token
      String? token = await NotificationService().getFCMToken();
      
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not get device token for notification'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      DocumentReference docRef = firebaseFirestore.collection('waitlist').doc();
      
      WaitlistModel waitlistEntry = WaitlistModel(
        waitlistID: docRef.id,
        slotID: slotID,
        date: date,
        userID: uid,
        fcmToken: token,
        createdAt: Timestamp.now(),
      );

      await docRef.set(waitlistEntry.toMap());
      
      myWaitlistStatus[slotID] = true;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Added to Waitlist! You will be notified if a spot opens.'),
        backgroundColor: Colors.green,
      ));

    } catch (e) {
       print("Error joining waitlist: $e");
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to join waitlist: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> bookSlot(
    String slotID,
    String timeRange,
    String date,
    String userName,
    context,
  ) async {
    try {
      if (myBookingId != null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You already booked today slot'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      DocumentReference docRef = firebaseFirestore.collection('bookings').doc();
      
      final booking = BookingModel(
        bookingID: docRef.id,
        userID: uid,
        userName: userName,
        date: date,
        slotID: slotID,
        timeRange: timeRange,
        bookingTime: DateFormat('hh:mm a').format(DateTime.now()), // Added
      );

      // Save to main bookings collection (for Admin)
      await docRef.set(booking.toMap());

      // Save to user's personal booking list (optional, but good for history)
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('my_bookings')
          .doc(docRef.id)
          .set(booking.toMap());

      await fetchBookedSlots(date); // Refresh availability
      notifyListeners();

      // Schedule Reminder Notification
      try {
        final notificationService = NotificationService();
        await notificationService.initNotification(); 
        
        // Parse date and time to create a DateTime object
        // date format example: "24-Oct-2023" (Need to check actual format, assuming dd-MMM-yyyy based on view)
        // timeRange format example: "10:00 AM - 11:00 AM"
        
        // Simple logic: Schedule for 8 AM on the day of booking as a reminder
        // A more robust app would parse the exact start time.
        // Let's try to parse the date.
        
        DateFormat inputFormat = DateFormat('yyyy-MM-dd'); // Matches DateFormat used during booking
        // In fetchBookedSlots above code uses 'dd-MM-yyyy' for formatting, but here input `date` might be different.
        // Let's look at `SlotBooking` screen if possible, but safe bet is to schedule for "Morning of the day".
        
        DateTime parsedDate = inputFormat.parse(date);
        DateTime reminderTime = parsedDate.add(const Duration(hours: 8)); // 8:00 AM
        
        // If booking is for today and it's past 8 AM, show immediately or skip.
        if (reminderTime.isAfter(DateTime.now())) {
             await notificationService.scheduleNotification(
                id: parsedDate.day + parsedDate.month + parsedDate.year, // Simple unique ID
                title: 'Driving Session Reminder',
                body: 'You have a driving session today ($date) at $timeRange. Don\'t be late!',
                scheduledTime: reminderTime
             );
        } else {
             // Immediate notification if booked for today late
             await notificationService.showNotification(
               id: 12345, 
               title: 'Booking Confirmed', 
               body: 'Your driving session is confirmed for $date at $timeRange.'
             );
        }

      } catch (e) {
        print("Notification scheduling failed: $e");
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Slot Booked Successfully'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to book slot: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> cancelSlot(String bookingID, String date, context) async {
    try {
      // 1. Get slot ID before deleting (for waitlist)
      String? matchedSlotID;
      try {
        if (myBookedSlotId != null) {
           matchedSlotID = myBookedSlotId; 
        } else {
           // Fallback if state is lost, read DB
           DocumentSnapshot doc = await firebaseFirestore.collection('bookings').doc(bookingID).get();
           if (doc.exists) {
             matchedSlotID = doc['slotID'];
           }
        }
      } catch (e) {
        print("Error reading booking for waitlist: $e");
      }

      // 2. Delete from main bookings collection
      await firebaseFirestore.collection('bookings').doc(bookingID).delete();

      // 3. Delete from user's personal booking list
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('my_bookings')
          .doc(bookingID)
          .delete();

      await fetchBookedSlots(date); // Refresh availability
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Slot Cancelled Successfully'),
        backgroundColor: Colors.green,
      ));

      // 4. TRIGGER WAITLIST NOTIFICATIONS
      print("Starting Waitlist Trigger Check for date: $date");
      if (matchedSlotID != null) {
        print("Matched Slot ID found: $matchedSlotID");
        try {
          QuerySnapshot waitlistSnapshot = await firebaseFirestore
              .collection('waitlist')
              .where('slotID', isEqualTo: matchedSlotID)
              .get(); // Removing date filter temporarily to debug if slotID matches

          print("Found ${waitlistSnapshot.docs.length} users in waitlist for this slot.");

          NotificationService notificationService = NotificationService();
          // await notificationService.initNotification(); // Init might be redundant here if not needed for sending

          for (var doc in waitlistSnapshot.docs) {
             WaitlistModel waiter = WaitlistModel.fromMap(doc.data() as Map<String, dynamic>);
             print("Checking waiter: (${waiter.userID}) against current uid: $uid");
             
             if (waiter.userID != uid) {
               
               // 1. Delete from waitlist FIRST (Ensure cleanup)
               print("Deleting waitlist entry: ${waiter.waitlistID}");
               try {
                  await firebaseFirestore.collection('waitlist').doc(waiter.waitlistID).delete();
               } catch (e) {
                  print("Error deleting waitlist doc: $e");
               }

               // 2. Send Notification (Best Effort)
               print("Sending notification to ${waiter.fcmToken}");
               try {
                 await notificationService.sendPushNotification(
                   waiter.fcmToken, 
                   "Slot Available!", 
                   "A slot has opened up for $date! Book it now before it's gone."
                 );
               } catch (e) {
                 print("Failed to send notification (Check Server Key): $e");
               }
               
             } else {
               print("Skipping self-notification/deletion (Waitlist ID: ${waiter.waitlistID})");
             }
          }
        } catch (e) {
          print("Error sending waitlist notifications: $e");
        }
      } else {
        print("MatchedSlotID is NULL. Cannot query waitlist.");
      }

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to cancel slot: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  /////////////////RETEST APPLICATION///////////////////
  
  Future<void> applyForRetest({
    required String phone,
    required String learnersNumber,
    required List<String> selectedTests,
    required double amount,
    required BuildContext context,
  }) async {
    try {
      DocumentReference docRef = firebaseFirestore.collection('retest_applications').doc();

      final retest = RetestModel(
        id: docRef.id,
        userId: uid,
        userName: userModel.userName, // Assuming userModel is loaded
        phoneNumber: phone,
        learnersNumber: learnersNumber,
        selectedTests: selectedTests,
        amount: amount,
        date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
        paymentStatus: 'Paid',
      );

      await docRef.set(retest.toMap());

      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Retest Applied Successfully'),
        backgroundColor: Colors.green,
      ));
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PaymentSuccessful(paymentType: 'Retest Payment'),
        ),
      );

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to apply for retest: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }


  /////////////////RC RENEWAL///////////////////

  Future<void> applyForRcRenewal({
    required String name,
    required String phone,
    required String rcNumber,
    required String expiryDate,
    required String vehicleClass,
    required XFile? idProofImage,
    required String engineNumber, // Added
    required String chassisNumber, // Added
    required XFile? pollutionCertificate, // Added
    required double amount,
    required BuildContext context,
  }) async {
    try {
      DocumentReference docRef = firebaseFirestore.collection('rc_renewals').doc();
      String idProofUrl = '';
       String pollutionCertificateUrl = ''; // Added

       if (idProofImage != null) {
          idProofUrl = await storeImagetoStorge('rc_id_proofs/${uid}/${docRef.id}', idProofImage);
       }
       if (pollutionCertificate != null) {
          pollutionCertificateUrl = await storeImagetoStorge('rc_pollution_certs/${uid}/${docRef.id}', pollutionCertificate);
       }

      final rcRenewal = RcRenewalModel(
        id: docRef.id,
        userId: uid,
        userName: name,
        phoneNumber: phone,
        rcNumber: rcNumber,
        expiryDate: expiryDate,
        applicationDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
        status: 'Pending',
        vehicleClass: vehicleClass,
        idProofUrl: idProofUrl,
        amount: amount,
        paymentStatus: 'Paid',
        engineNumber: engineNumber, // Added
        chassisNumber: chassisNumber, // Added
        pollutionCertificateUrl: pollutionCertificateUrl, // Added
      );

      await docRef.set(rcRenewal.toMap());

      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('RC Renewal Application Submitted Successfully'),
        backgroundColor: Colors.green,
      ));
      
      // Navigate close happens in payment screen or we pop to root/home
       Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PaymentSuccessful(paymentType: 'RC Renewal Payment')),
          (route) => false);

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to submit application: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  List<RcRenewalModel> rcRenewalList = [];

  Future<void> fetchRcRenewals() async {
    try {
      rcRenewalList.clear();
      QuerySnapshot snapshot = await firebaseFirestore
          .collection('rc_renewals')
          .orderBy('applicationDate', descending: true)
          .get();

      for (var doc in snapshot.docs) {
        rcRenewalList.add(RcRenewalModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching RC renewals: $e");
    }
  }

  Future<void> updateRcRenewalStatus(String id, String newStatus, BuildContext context) async {
    try {
      await firebaseFirestore.collection('rc_renewals').doc(id).update({
        'status': newStatus,
      });
      
      // Update local list
      int index = rcRenewalList.indexWhere((element) => element.id == id);
      if (index != -1) {
        rcRenewalList[index].status = newStatus;
        notifyListeners();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Status updated to $newStatus'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update status: $e'),
        backgroundColor: Colors.red,
      ));
      print("Error updating status: $e");
    }
  }

  // User Side Applications
  List<RcRenewalModel> userRcRenewalList = [];
  List<RetestModel> userRetestList = [];

  Future<void> fetchUserRcRenewals() async {
    try {
      userRcRenewalList.clear();
      QuerySnapshot snapshot = await firebaseFirestore
          .collection('rc_renewals')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in snapshot.docs) {
        userRcRenewalList.add(RcRenewalModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      
      // Sort locally to avoid needing a composite index in Firestore
      userRcRenewalList.sort((a, b) {
           try { 
             return DateFormat('dd-MM-yyyy').parse(b.applicationDate).compareTo(DateFormat('dd-MM-yyyy').parse(a.applicationDate));
           } catch (e) { return 0; }
      });

      notifyListeners();
    } catch (e) {
      print("Error fetching user RC renewals: $e");
    }
  }

  Future<void> fetchUserRetestApplications() async {
    try {
      userRetestList.clear();
      QuerySnapshot snapshot = await firebaseFirestore
          .collection('retest_applications')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in snapshot.docs) {
        userRetestList.add(RetestModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      // Sort manually since date format might be custom string "dd-MM-yyyy"
      userRetestList.sort((a, b) {
           try { 
             return DateFormat('dd-MM-yyyy').parse(b.date).compareTo(DateFormat('dd-MM-yyyy').parse(a.date));
           } catch (e) { return 0; }
      });

      notifyListeners();
    } catch (e) {
      print("Error fetching user retest applications: $e");
    }
  }

  // ---------------- CHAT IMPLEMENTATION ----------------
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final message = MessageModel(
      senderId: uid, 
      text: text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    try {
      await firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('messages')
          .add(message.toMap());
      
      // Update last message time on user doc for sorting in Admin list
      await firebaseFirestore.collection('users').doc(uid).update({
        'lastMessageTime': DateTime.now(),
        'hasUnreadMessages': true,
      });
      
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Stream<List<MessageModel>> getMessages() {
    return firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> deleteUser(String userId, BuildContext context) async {
    try {
      await firebaseFirestore.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('User deleted successfully'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("Error deleting user: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete user: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ---------------- STUDENT SKILL TRACKING (RADAR CHART) ----------------
  Future<StudentSkillModel> fetchStudentSkills(String studentId) async {
    try {
      DocumentSnapshot doc = await firebaseFirestore
          .collection('student_skills')
          .doc(studentId)
          .get();

      if (doc.exists) {
        return StudentSkillModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching student skills: $e");
    }
    return StudentSkillModel.initial(studentId);
  }

  Future<void> updateStudentSkills(StudentSkillModel skills, BuildContext context) async {
    try {
      final now = DateTime.now().toIso8601String();
      skills.lastUpdated = now;

      // 1. Overwrite the latest snapshot (for the radar chart)
      await firebaseFirestore
          .collection('student_skills')
          .doc(skills.studentId)
          .set(skills.toMap(), SetOptions(merge: true));

      // 2. Also append to history sub-collection
      await firebaseFirestore
          .collection('student_skills')
          .doc(skills.studentId)
          .collection('evaluations')
          .add(skills.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student evaluation saved successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error updating student skills: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save evaluation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Returns all historical evaluations for a student, newest first.
  Future<List<StudentSkillModel>> fetchSkillHistory(String studentId) async {
    try {
      final snapshot = await firebaseFirestore
          .collection('student_skills')
          .doc(studentId)
          .collection('evaluations')
          .orderBy('lastUpdated', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return StudentSkillModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      print("Error fetching skill history: $e");
      return [];
    }
  }

  // ---------------- INSTRUCTOR CHAT ----------------
  /// Sends a message in the instructor ↔ student conversation.
  /// The chat thread lives at: instructor_chats/{instructorId}_{studentId}/messages/
  Future<void> sendInstructorMessage({
    required String instructorId,
    required String studentId,
    required String text,
    required String senderId,
  }) async {
    if (text.trim().isEmpty) return;
    final threadId = '${instructorId}_$studentId';
    try {
      await firebaseFirestore
          .collection('instructor_chats')
          .doc(threadId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'text': text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error sending instructor message: $e");
    }
  }

  /// Streams messages for the instructor ↔ student thread.
  Stream<List<Map<String, dynamic>>> getInstructorMessages({
    required String instructorId,
    required String studentId,
  }) {
    final threadId = '${instructorId}_$studentId';
    return firebaseFirestore
        .collection('instructor_chats')
        .doc(threadId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }
}

