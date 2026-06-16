import 'package:driving_school/const.dart';
import 'package:driving_school/controller/super_admin_controller.dart';
import 'package:driving_school/views/admin/admin_salary_screen.dart';
import 'package:driving_school/views/admin/manage_course.dart';
import 'package:driving_school/views/admin/manage_instructor.dart';
import 'package:driving_school/views/admin/users_list.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:driving_school/views/super_admin/super_chat_screen.dart';
import 'package:driving_school/views/super_admin/super_admin_fund_requests_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BranchDetails extends StatefulWidget {
  final String branchName;
  final bool isRealBranch;

  const BranchDetails({super.key, required this.branchName, required this.isRealBranch});

  @override
  State<BranchDetails> createState() => _BranchDetailsState();
}

class _BranchDetailsState extends State<BranchDetails> {
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isRealBranch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<SuperAdminController>(context, listen: false).fetchMainBranchStats();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SuperAdminController>(context);

    // Dummy values
    int users = widget.isRealBranch ? controller.totalUsers : 45;
    int instructors = widget.isRealBranch ? controller.totalInstructors : 6;
    int courses = widget.isRealBranch ? controller.totalCourses : 4;
    double revenue = widget.isRealBranch ? controller.totalRevenue : 85000.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.branchName, style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.black87,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Positioned(bottom: 0, left: 0, child: Opacity(opacity: 0.5, child: Image.asset('assets/Ellipse 36.png'))),
          SafeArea(
            child: controller.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Branch Overview', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        
                        // Pie Chart
                        if (widget.isRealBranch)
                          Container(
                            height: 220,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                      sections: [
                                        PieChartSectionData(
                                          color: Colors.green,
                                          value: revenue > 0 ? revenue : 1,
                                          title: '₹${controller.totalRevenue.toStringAsFixed(0)}',
                                          radius: 25,
                                          titleStyle: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                          showTitle: revenue > 0,
                                        ),
                                        PieChartSectionData(
                                          color: Colors.red.shade400,
                                          value: controller.totalExpenses > 0 ? controller.totalExpenses : 1,
                                          title: '₹${controller.totalExpenses.toStringAsFixed(0)}',
                                          radius: 25,
                                          titleStyle: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                          showTitle: controller.totalExpenses > 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLegend(Colors.green, 'Revenue'),
                                      const SizedBox(height: 15),
                                      _buildLegend(Colors.red.shade400, 'Expenses'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Grid for stats
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.2,
                          children: [
                      _buildStatCard('Total Users', users.toString(), Icons.people, Colors.blue,
                        onTap: widget.isRealBranch ? () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const UsersList(isReadOnly: true))) : null,
                      ),
                      _buildStatCard('Total Instructors', instructors.toString(), Icons.person_pin_rounded, Colors.orange,
                        onTap: widget.isRealBranch ? () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ManageInstructor(isReadOnly: true))) : null,
                      ),
                      _buildStatCard('Active Courses', courses.toString(), Icons.menu_book, Colors.purple,
                        onTap: widget.isRealBranch ? () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ManageCourse(isReadOnly: true))) : null,
                      ),
                      _buildStatCard('Total Revenue', '₹${revenue.toStringAsFixed(0)}', Icons.currency_rupee, Colors.green),
                    ],
                        ),
                        const SizedBox(height: 20),
                        // Transfer Salary section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,5))]
                  ),
                  child: Column(
                    children: [
                      Text('Transfer Instructor Salary Funds', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 15),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter amount (e.g. 10000)',
                          prefixIcon: const Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: defaultBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                          ),
                          onPressed: () {
                            if (amountController.text.isNotEmpty) {
                              if (widget.isRealBranch) {
                                controller.transferSalaryFunds(double.parse(amountController.text), context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Dummy Transfer Successful!'), backgroundColor: Colors.green),
                                );
                              }
                              amountController.clear();
                              FocusScope.of(context).unfocus();
                            }
                          },
                          child: Text('Transfer Funds to Admin', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (widget.isRealBranch) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSalaryScreen(isReadOnly: true)));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Real branch data only'), backgroundColor: Colors.orange),
                              );
                            }
                          },
                          icon: const Icon(Icons.assignment_ind_outlined, color: defaultBlue),
                          label: Text('Check Instructor Salary Status', style: GoogleFonts.epilogue(color: defaultBlue, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: defaultBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (widget.isRealBranch)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('fund_requests')
                        .where('status', isEqualTo: 'Pending')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final pendingCount = snapshot.data?.docs.length ?? 0;
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const SuperAdminFundRequestsScreen()),
                        ),
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: pendingCount > 0 ? Colors.orange.shade300 : Colors.grey.shade200,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.07),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.request_quote_rounded, color: Colors.orange, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fund Requests from Admin',
                                      style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      pendingCount > 0
                                          ? '$pendingCount pending request${pendingCount > 1 ? 's' : ''} awaiting review'
                                          : 'No pending requests',
                                      style: GoogleFonts.epilogue(
                                        fontSize: 12,
                                        color: pendingCount > 0 ? Colors.orange.shade700 : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (pendingCount > 0)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$pendingCount',
                                    style: GoogleFonts.epilogue(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
          ),
        ],
      ),
      floatingActionButton: widget.isRealBranch ? FloatingActionButton.extended(
        backgroundColor: Colors.black87,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SuperChatScreen(isSuperAdmin: true)));
        },
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: Text('Chat with Admin', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
      ) : null,
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.epilogue(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
          const SizedBox(height: 5),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.epilogue(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
     ),
    );
  }
}
