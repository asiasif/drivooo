import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SuperAdminController extends ChangeNotifier {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  int totalUsers = 0;
  int totalInstructors = 0;
  int totalCourses = 0;
  double totalRevenue = 0.0;
  double totalExpenses = 0.0;

  bool isLoading = false;

  Future<void> fetchMainBranchStats() async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. Users
      final userSnap = await firebaseFirestore.collection('users').get();
      totalUsers = userSnap.docs.length;

      // 2. Instructors
      final instructorSnap = await firebaseFirestore.collection('instructors').get();
      totalInstructors = instructorSnap.docs.length;

      // 3. Courses
      final courseSnap = await firebaseFirestore.collection('courses').get();
      totalCourses = courseSnap.docs.length;

      // 4. Revenue (Sum of all invoices)
      final invoiceSnap = await firebaseFirestore.collection('invoices').get();
      double revenue = 0.0;
      for (var doc in invoiceSnap.docs) {
        if (doc.data().containsKey('invoicePrice')) {
          revenue += double.tryParse(doc['invoicePrice'].toString()) ?? 0.0;
        }
      }
      totalRevenue = revenue;

      // 5. Expenses
      double expenses = 0.0;
      
      // 5a. Salaries
      final salariesSnap = await firebaseFirestore.collection('salaries').where('status', isEqualTo: 'Paid').get();
      for (var doc in salariesSnap.docs) {
        if (doc.data().containsKey('amount')) {
          expenses += double.tryParse(doc['amount'].toString()) ?? 0.0;
        }
      }
      
      // 5b. Fuel Receipts
      final fuelSnap = await firebaseFirestore.collection('fuel_receipts').where('status', isEqualTo: 'Approved').get();
      for (var doc in fuelSnap.docs) {
        if (doc.data().containsKey('amount')) {
          expenses += double.tryParse(doc['amount'].toString()) ?? 0.0;
        }
      }
      
      // 5c. Maintenance Receipts
      final maintSnap = await firebaseFirestore.collection('maintenance_receipts').where('status', isEqualTo: 'Approved').get();
      for (var doc in maintSnap.docs) {
        if (doc.data().containsKey('amount')) {
          expenses += double.tryParse(doc['amount'].toString()) ?? 0.0;
        }
      }
      totalExpenses = expenses;

    } catch (e) {
      print("Error fetching main branch stats: $e");
    }

    isLoading = false;
    notifyListeners();
  }
  
  Future<void> transferSalaryFunds(double amount, BuildContext context) async {
    try {
      String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      await firebaseFirestore.collection('super_admin_transfers').add({
        'amount': amount,
        'date': date,
        'status': 'Success',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('₹$amount transferred to Main Branch Admin'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer failed!'), backgroundColor: Colors.red),
      );
    }
  }
}
