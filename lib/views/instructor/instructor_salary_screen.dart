import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school/const.dart';
import 'package:driving_school/controller/instructor_controller.dart';
import 'package:driving_school/models/salary_model.dart';
import 'package:driving_school/services/salary_pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InstructorSalaryScreen extends StatelessWidget {
  const InstructorSalaryScreen({super.key});

  Stream<List<SalaryModel>> _mySalaryStream(String instructorId) {
    return FirebaseFirestore.instance
        .collection('salaries')
        .where('instructorId', isEqualTo: instructorId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SalaryModel.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) => b.monthYear.compareTo(a.monthYear)));
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<InstructorController>(context, listen: false);
    final currentInstructorId = userProvider.currentInstructor?.instructorID ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(EvaIcons.arrow_ios_back_outline, color: Colors.black87),
        ),
        title: Text(
          'My Salary History',
          style: GoogleFonts.epilogue(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: currentInstructorId.isEmpty
          ? Center(child: Text("Instructor ID not found.", style: GoogleFonts.epilogue()))
          : StreamBuilder<List<SalaryModel>>(
              stream: _mySalaryStream(currentInstructorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final records = snapshot.data ?? [];

                if (records.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No salary records found.',
                          style: GoogleFonts.epilogue(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: records.length,
                  itemBuilder: (context, i) {
                    return _buildSalaryCard(context, records[i]);
                  },
                );
              },
            ),
    );
  }

  Widget _buildSalaryCard(BuildContext context, SalaryModel salary) {
    final paidDate = salary.paidAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(salary.paidAt!))
        : '';
    final isPaid = salary.status == 'Paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  salary.monthYear,
                  style: GoogleFonts.epilogue(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPaid ? Colors.green.shade200 : Colors.orange.shade200,
                    ),
                  ),
                  child: Text(
                    salary.status,
                    style: GoogleFonts.epilogue(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.currency_rupee, size: 28, color: defaultBlue),
                Text(
                  salary.amount.toStringAsFixed(0),
                  style: GoogleFonts.epilogue(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: defaultBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (paidDate.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Paid on: $paidDate',
                    style: GoogleFonts.epilogue(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    SalaryPdfService.generateAndShowSlip(salary);
                  },
                  icon: const Icon(Icons.picture_as_pdf, color: defaultBlue),
                  label: Text(
                    'Download Salary Slip',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.bold,
                      color: defaultBlue,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: defaultBlue.withOpacity(0.05),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
