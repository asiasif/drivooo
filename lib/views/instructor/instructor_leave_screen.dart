import 'package:driving_school/const.dart';
import 'package:driving_school/controller/instructor_controller.dart';
import 'package:driving_school/models/instructor_leave_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class InstructorLeaveScreen extends StatefulWidget {
  const InstructorLeaveScreen({super.key});

  @override
  State<InstructorLeaveScreen> createState() => _InstructorLeaveScreenState();
}

class _InstructorLeaveScreenState extends State<InstructorLeaveScreen> {
  @override
  Widget build(BuildContext context) {
    final instructorCtrl = Provider.of<InstructorController>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(EvaIcons.arrow_ios_back_outline),
        ),
        title: Text('My Leave Requests', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: StreamBuilder<List<InstructorLeaveModel>>(
        stream: instructorCtrl.getInstructorLeaves(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text('No leave requests found.', style: GoogleFonts.epilogue(color: Colors.grey)),
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
              Color statusColor = Colors.orange;
              if (leave.status == 'Approved') statusColor = Colors.green;
              if (leave.status == 'Rejected') statusColor = Colors.red;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
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
                          Expanded(
                            child: Text(
                              '${leave.startDate} to ${leave.endDate}',
                              style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 15),
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
                      const SizedBox(height: 10),
                      Text('Reason: ${leave.reason}', style: GoogleFonts.epilogue(fontSize: 14)),
                      const SizedBox(height: 10),
                      Text(
                        'Applied on: ${_formatDate(leave.appliedOn)}',
                        style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLeaveRequestBottomSheet(context),
        backgroundColor: defaultBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Request Leave', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showLeaveRequestBottomSheet(BuildContext context) {
    final startDateCtrl = TextEditingController();
    final endDateCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request Leave', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startDateCtrl,
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              startDateCtrl.text = DateFormat('dd-MM-yyyy').format(date);
                            }
                          },
                        ),
                      ),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: endDateCtrl,
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              endDateCtrl.text = DateFormat('dd-MM-yyyy').format(date);
                            }
                          },
                        ),
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for leave',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: defaultBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 5,
                    shadowColor: defaultBlue.withOpacity(0.4),
                  ),
                  onPressed: () async {
                    if (startDateCtrl.text.isEmpty || endDateCtrl.text.isEmpty || reasonCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    Navigator.pop(context); // Close bottom sheet
                    final instructorCtrl = Provider.of<InstructorController>(context, listen: false);
                    await instructorCtrl.submitLeaveRequest(
                      startDate: startDateCtrl.text,
                      endDate: endDateCtrl.text,
                      reason: reasonCtrl.text,
                      context: context,
                    );
                  },
                  child: Text('Submit Request', style: GoogleFonts.epilogue(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
