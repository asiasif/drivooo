import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:driving_school/views/user/user_home.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/models/announcement_model.dart';
import 'package:driving_school/models/user_model.dart';

// Fake implementations to bypass Firebase
class FakeUserController extends UserController {
  @override
  UserModel get userModel => UserModel(
    userID: 'test_uid',
    userName: 'Reference User',
    userEmail: 'test@example.com',
    userNumber: 1234567890,
    selectedCourse: 'Test Course'
  );

  @override
  List<Map<String, dynamic>> get userServiceList => [
    {'service name': 'Profile', 'image': 'assets/man 1.png', 'onTap': Container()},
    {'service name': 'Course', 'image': 'assets/settings 1.png', 'onTap': Container()},
  ];

  @override
  Future fetchUserData(String uid) async {
    return Future.value();
  }
}



// ... (existing imports)

class FakeAdminController extends AdminController {
  @override
  List<AnnouncementModel> get announcementList => [];
  
  @override
  Future fetchAnnouncements() async {
    return Future.value();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Firebase to prevent crashes in base classes
  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_core');
  setUpAll(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return <String, dynamic>{
        'name': '[DEFAULT]',
        'options': {
          'apiKey': '123',
          'appId': '123',
          'messagingSenderId': '123',
          'projectId': '123',
        },
        'pluginConstants': {},
      };
    });
  });

  testWidgets('UserHome displays greeting and grid', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserController>(create: (_) => FakeUserController()),
          ChangeNotifierProvider<AdminController>(create: (_) => FakeAdminController()),
        ],
        child: const MaterialApp(
          home: UserHome(uid: 'test_uid'),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    // Pump again for FutureBuilder
    await tester.pump(const Duration(seconds: 1));

    // Verify Greeting
    expect(find.textContaining('Welcome back'), findsOneWidget);
    expect(find.textContaining('Reference User'), findsOneWidget);

    // Verify Grid Items
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Course'), findsOneWidget);
  });
}
