import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/models/instructor_leave_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminLeaveScreen extends StatelessWidget {
  const AdminLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Provider.of<AdminController>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(EvaIcons.arrow_ios_back_outline),
        ),
        title: Text('Instructor Leaves', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: StreamBuilder<List<InstructorLeaveModel>>(
        stream: adminCtrl.getAllLeaveRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: defaultBlue));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text('No pending leave requests.', style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final leaves = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaves.length,
            itemBuilder: (context, index) {
              final leave = leaves[index];
              final isPending = leave.status == 'Pending';

              Color statusColor = Colors.orange;
              if (leave.status == 'Approved') statusColor = Colors.green;
              if (leave.status == 'Rejected') statusColor = Colors.red;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              leave.instructorName,
                              style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              leave.status,
                              style: GoogleFonts.epilogue(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.date_range, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            '${leave.startDate}  to  ${leave.endDate}',
                            style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Reason: ${leave.reason}', style: GoogleFonts.epilogue(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 10),
                      Text(
                        'Applied on: ${_formatDate(leave.appliedOn)}',
                        style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey),
                      ),
                      if (isPending) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  adminCtrl.updateLeaveStatus(leave.id, 'Rejected', context);
                                },
                                child: Text('Reject', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  adminCtrl.updateLeaveStatus(leave.id, 'Approved', context);
                                },
                                child: Text('Approve', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return isoString;
    }
  }
}
