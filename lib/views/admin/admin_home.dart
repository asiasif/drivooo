import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/views/choose_user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:driving_school/views/admin/admin_chat_list.dart';
import 'package:driving_school/views/super_admin/super_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:driving_school/services/transfer_pdf_service.dart';
import 'package:driving_school/views/admin/admin_fund_request_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminController = Provider.of<AdminController>(context, listen: false);
      adminController.fetchUsers();
      adminController.fetchInstructors();
      adminController.fetchCourses();
      adminController.fetchAllInvoices();
      adminController.fetchAvailableSalaryFunds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final adminHomeController = Provider.of<UserController>(context);
    final adminStatsController = Provider.of<AdminController>(context);

    return Scaffold(
      body: Stack(
        children: [
            // Background Elements - Same as User Module
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset('assets/Ellipse 2.png'),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 200,
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'assets/Ellipse 36.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Header
                      SizedBox(
                        width: width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Welcome back,\nAdmin,',
                              style: GoogleFonts.epilogue(
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('fund_requests')
                                      .where('status', whereIn: ['Approved', 'Rejected'])
                                      .snapshots(),
                                  builder: (context, fundSnap) {
                                    return StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('super_admin_transfers')
                                          .snapshots(),
                                      builder: (context, transferSnap) {
                                        final total = (fundSnap.data?.docs.length ?? 0) +
                                            (transferSnap.data?.docs.length ?? 0);
                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            IconButton(
                                              onPressed: () => _showNotificationsModal(context),
                                              icon: const Icon(Iconsax.notification, color: Colors.black87, size: 28),
                                            ),
                                            if (total > 0)
                                              Positioned(
                                                right: 4,
                                                top: 4,
                                                child: Container(
                                                  padding: const EdgeInsets.all(3),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                                                  child: Text(
                                                    total > 9 ? '9+' : '$total',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(width: 15),
                                InkWell(
                                  onTap: () {
                                    adminHomeController.firebaseAuth.signOut().then(
                                        (value) => Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) => const ChooseUser(),
                                            ),
                                            (route) => false));
                                  },
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Iconsax.logout,
                                        color: defaultBlue,
                                      ),
                                      Text(
                                        'Logout',
                                        style: GoogleFonts.epilogue(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Super Admin Notices Banner
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('super_admin_notices')
                            .orderBy('date', descending: true)
                            .limit(5)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.campaign_rounded, color: Colors.deepPurple, size: 18),
                                  const SizedBox(width: 6),
                                  Text('Notices from Super Admin', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepPurple)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final isUrgent = data['type'] == 'Urgent';
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isUrgent ? Colors.red.shade50 : Colors.deepPurple.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isUrgent ? Colors.red.shade200 : Colors.deepPurple.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        isUrgent ? Icons.warning_rounded : Icons.campaign_rounded,
                                        color: isUrgent ? Colors.red.shade400 : Colors.deepPurple,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(data['title'] ?? '', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                            const SizedBox(height: 2),
                                            Text(data['description'] ?? '', style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade700, height: 1.4)),
                                            const SizedBox(height: 4),
                                            Text(data['date'] ?? '', style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey.shade500)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),

                      // Stats Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Business Overview',
                            style: GoogleFonts.epilogue(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: defaultBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'This Month',
                              style: GoogleFonts.epilogue(fontSize: 12, color: defaultBlue, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        children: [
                          _buildEnhancedStatItem(
                            context: context,
                            count: adminStatsController.totalStudents.toString(),
                            label: 'Students',
                            icon: Iconsax.user_cirlce_add,
                            color: Colors.blue,
                          ),
                          _buildEnhancedStatItem(
                            context: context,
                            count: adminStatsController.totalInstructors.toString(),
                            label: 'Instructors',
                            icon: Iconsax.teacher,
                            color: Colors.orange,
                          ),
                          _buildEnhancedStatItem(
                            context: context,
                            count: adminStatsController.totalCourses.toString(),
                            label: 'Courses',
                            icon: Iconsax.book_1,
                            color: Colors.purple,
                          ),
                          _buildEnhancedStatItem(
                            context: context,
                            count: '₹${adminStatsController.getCurrentMonthRevenue().toStringAsFixed(0)}',
                            label: 'Revenue',
                            icon: Iconsax.wallet_money,
                            color: Colors.green,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Management Services Grid
                      Text(
                        'Management Console',
                        style: GoogleFonts.epilogue(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10, // Increased spacing
                          mainAxisSpacing: 10,  // Added spacing
                          childAspectRatio: 0.85, // Adjusted ratio
                        ),
                        itemCount: adminHomeController.adminServiceList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => adminHomeController
                                      .adminServiceList[index]['onTap'],
                                ),
                              );
                            },
                            radius: 20,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 55,
                                    width: 55,
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      adminHomeController.adminServiceList[index]['image'],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      adminHomeController.adminServiceList[index]['service name'],
                                      style: GoogleFonts.epilogue(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        tooltip: 'Chat with Super Admin',
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SuperChatScreen(isSuperAdmin: false)));
        },
        child: const Icon(Icons.support_agent_rounded, color: Colors.white),
      ),
    );
  }


  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (ctx) => const AdminFundRequestScreen()),
                          );
                        },
                        icon: const Icon(Icons.request_quote_rounded, size: 18, color: defaultBlue),
                        label: Text(
                          'Request Funds',
                          style: GoogleFonts.epilogue(color: defaultBlue, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('fund_requests')
                          .where('status', whereIn: ['Approved', 'Rejected'])
                          .snapshots(),
                      builder: (context, fundSnap) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('super_admin_transfers')
                              .orderBy('date', descending: true)
                              .snapshots(),
                          builder: (context, transferSnap) {
                            if (fundSnap.connectionState == ConnectionState.waiting ||
                                transferSnap.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            // Sort fund requests client-side by date descending
                            final fundDocs = (fundSnap.data?.docs ?? [])
                              ..sort((a, b) {
                                final aDate = (a.data() as Map<String, dynamic>)['date'] ?? '';
                                final bDate = (b.data() as Map<String, dynamic>)['date'] ?? '';
                                return bDate.compareTo(aDate);
                              });
                            final transferDocs = transferSnap.data?.docs ?? [];

                            if (fundDocs.isEmpty && transferDocs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.notifications_none_rounded, size: 52, color: Colors.grey[300]),
                                    const SizedBox(height: 10),
                                    Text('No notifications yet', style: GoogleFonts.epilogue(color: Colors.grey)),
                                  ],
                                ),
                              );
                            }

                            return ListView(
                              controller: scrollController,
                              children: [
                                // ── Fund Request Status Updates ──────────────────
                                if (fundDocs.isNotEmpty) ...[
                                  _buildNotifSectionHeader(
                                    'Fund Request Updates',
                                    Icons.request_quote_rounded,
                                    Colors.orange.shade700,
                                  ),
                                  ...fundDocs.map((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    final status = data['status'] ?? '';
                                    final amount = double.tryParse(data['amount'].toString()) ?? 0.0;
                                    final reason = data['reason'] ?? '';
                                    final dateStr = data['date'] ?? '';
                                    final rejectionNote = data['rejectionNote'] ?? '';
                                    final isApproved = status == 'Approved';
                                    final accent = isApproved ? Colors.green : Colors.red;

                                    String displayDate = '';
                                    try {
                                      displayDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(dateStr));
                                    } catch (_) {
                                      displayDate = dateStr;
                                    }

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: accent.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: accent.withOpacity(0.12),
                                            child: Icon(
                                              isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                              color: accent,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Fund Request ${isApproved ? 'Approved ✓' : 'Rejected ✗'}',
                                                  style: GoogleFonts.epilogue(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: accent.shade800,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '₹${amount.toStringAsFixed(0)}  •  $reason',
                                                  style: GoogleFonts.epilogue(fontSize: 12, color: Colors.black87),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (!isApproved && rejectionNote.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 3),
                                                    child: Text(
                                                      'Note: $rejectionNote',
                                                      style: GoogleFonts.epilogue(
                                                        fontSize: 11,
                                                        color: Colors.red.shade600,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  displayDate,
                                                  style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 6),
                                ],

                                // ── Salary Fund Transfers ────────────────────────
                                if (transferDocs.isNotEmpty) ...[
                                  _buildNotifSectionHeader(
                                    'Salary Fund Transfers',
                                    Icons.account_balance_wallet,
                                    Colors.green.shade700,
                                  ),
                                  ...transferDocs.map((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    final amount = double.tryParse(data['amount'].toString()) ?? 0.0;
                                    final String dateStr = data['date'] ?? '';
                                    String displayDate = '';
                                    try {
                                      displayDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(dateStr));
                                    } catch (_) {
                                      displayDate = dateStr;
                                    }

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.green.shade50,
                                          child: const Icon(Icons.account_balance_wallet, color: Colors.green),
                                        ),
                                        title: Text(
                                          'Salary Funds Received',
                                          style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        subtitle: Text(
                                          '₹${amount.toStringAsFixed(0)}  •  $displayDate',
                                          style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            TransferPdfService.generateAndShowTransferReceipt(amount, dateStr);
                                          },
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          TransferPdfService.generateAndShowTransferReceipt(amount, dateStr);
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotifSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.epilogue(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: color.withOpacity(0.3), thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatItem({
    required BuildContext context,
    required String count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final width = (MediaQuery.of(context).size.width - 55) / 2;
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
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
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: GoogleFonts.epilogue(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
