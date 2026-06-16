import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/payment_gateway.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/controller/mock_test_controller.dart';
import 'package:driving_school/controller/instructor_controller.dart';
import 'package:driving_school/controller/super_admin_controller.dart';
import 'package:driving_school/firebase_options.dart';
import 'package:driving_school/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:driving_school/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final notificationService = NotificationService();
  await notificationService.initNotification();
  await notificationService.requestPermissions();

  // --- INSTRUCTOR INJECTION TEMPORARY ---
  try {
    final query = await FirebaseFirestore.instance
        .collection('instructors')
        .where('instructorEmail', isEqualTo: 'instructorktr@gmail.com')
        .get();
        
    if (query.docs.isEmpty) {
      final newDoc = FirebaseFirestore.instance.collection('instructors').doc();
      await newDoc.set({
        'instructorID': newDoc.id,
        'instructorName': 'KTR Instructor',
        'instructorNumber': 1234567890,
        'instructorEmail': 'instructorktr@gmail.com',
        'instructorProPic': null,
        'status': 'Available',
      });
      print('--- ADDED KTR INSTRUCTOR SUCCESSFULLY ---');
    }
  } catch (e) {
    print('Failed to add instructor: $e');
  }
  // --------------------------------------

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserController>(
          create: (context) => UserController(),
        ),
        ChangeNotifierProvider<PaymentGateway>(
          create: (context) => PaymentGateway(),
        ),
        ChangeNotifierProvider<AdminController>(
          create: (context) => AdminController(),
        ),
        ChangeNotifierProvider<MockTestController>(
          create: (context) => MockTestController(),
        ),
        ChangeNotifierProvider<InstructorController>(
          create: (context) => InstructorController(),
        ),
        ChangeNotifierProvider<SuperAdminController>(
          create: (context) => SuperAdminController(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        
        title: 'Driving School',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
