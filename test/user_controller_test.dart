import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:driving_school/controller/user_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserController Tests', () {
    late UserController userController;

    setUp(() async {
      // Mock other channels if needed, e.g. path_provider or shared_preferences
      
      // We might need to mock FirebaseAuth as well if UserController calls it immediately
      // But UserController() only calls .instance, which relies on Core.
      
      userController = UserController();
    });

    test('User Service List should not be empty', () {
      expect(userController.userServiceList, isNotEmpty);
      expect(userController.userServiceList.length, greaterThan(0));
    });

    test('Admin Service List should not be empty', () {
      expect(userController.adminServiceList, isNotEmpty);
      expect(userController.adminServiceList.length, greaterThan(0));
    });

    test('Specific services should exist in User Service List', () {
      final services = userController.userServiceList.map((e) => e['service name']).toList();
      expect(services, contains('Profile'));
      expect(services, contains('Course'));
      expect(services, contains('Invoice'));
      expect(services, contains('History'));
    });

    test('Specific services should exist in Admin Service List', () {
      final services = userController.adminServiceList.map((e) => e['service name']).toList();
      expect(services, contains('Users'));
      expect(services, contains('Manage Course'));
      expect(services, contains('Manage Invoice'));
    });

    test('Initial phone number should be empty', () {
      expect(userController.numberController.text, isEmpty);
    });

    // We can test setPhonenumber logic partially
    // We avoid length 10 to prevent sendOTP call which uses Firebase
    test('setPhonenumber updates controller text', () {
      userController.setPhonenumber('12345', null);
      expect(userController.numberController.text, '12345');
    });
  });
}
