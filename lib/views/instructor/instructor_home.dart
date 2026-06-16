import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/instructor_controller.dart';
import 'package:driving_school/views/instructor/instructor_users_list.dart';
import 'package:driving_school/views/instructor/instructor_profile_screen.dart';
import 'package:driving_school/views/instructor/instructor_leave_screen.dart';
import 'package:driving_school/views/instructor/instructor_fuel_screen.dart';
import 'package:driving_school/views/instructor/instructor_trip_log_screen.dart'; // Added
import 'package:driving_school/views/instructor/instructor_salary_screen.dart'; // Added
import 'package:driving_school/views/instructor/instructor_maintenance_screen.dart';
import 'package:driving_school/views/shared/announcements_feed.dart';
import 'package:driving_school/views/widgets/announcement_banner.dart';
import 'package:driving_school/views/choose_user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class InstructorHome extends StatefulWidget {
  const InstructorHome({super.key});

  @override
  State<InstructorHome> createState() => _InstructorHomeState();
}

class _InstructorHomeState extends State<InstructorHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminController = Provider.of<AdminController>(context, listen: false);
      adminController.fetchUsers(); // For attendance
      adminController.fetchAnnouncements(); // For global broadcasts
      final instructorController = Provider.of<InstructorController>(context, listen: false);
      instructorController.fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    List<Map<String, dynamic>> instructorServiceList = [
      {
        'service name': 'My Students',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF2979FF),
        'onTap': const InstructorUsersList()
      },
      {
        'service name': 'Announcements',
        'icon': Icons.campaign_rounded,
        'color': Colors.redAccent,
        'onTap': const AnnouncementsFeed()
      },
      {
        'service name': 'Leave Requests',
        'icon': Icons.calendar_month_rounded,
        'color': Colors.orange,
        'onTap': const InstructorLeaveScreen()
      },
      {
        'service name': 'Fuel Logs',
        'icon': Icons.local_gas_station_rounded,
        'color': Colors.purple,
        'onTap': const InstructorFuelScreen()
      },
      {
        'service name': 'Trip Logs',
        'icon': Icons.route_rounded,
        'color': Colors.indigo,
        'onTap': const InstructorTripLogScreen()
      },
      {
        'service name': 'My Salary',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.teal,
        'onTap': const InstructorSalaryScreen()
      },
      {
        'service name': 'My Profile',
        'icon': Icons.person_outline_rounded,
        'color': const Color(0xFF00BFA5),
        'onTap': const InstructorProfileScreen()
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
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
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<InstructorController>(
                  builder: (context, instructorController, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Welcome & Logout
                        SizedBox(
                          width: width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hello,',
                                      style: GoogleFonts.epilogue(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      '${instructorController.currentInstructor?.instructorName ?? 'Instructor'} \u{1F44B}',
                                      style: GoogleFonts.epilogue(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  instructorController.signOut(context);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Iconsax.logout, color: Colors.red, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Logout',
                                        style: GoogleFonts.epilogue(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // ANNOUNCEMENT BANNER
                        Consumer<AdminController>(
                          builder: (context, adminController, child) {
                            final instructorAnnouncements = adminController.announcementList.where((a) => a.audience == 'Both' || a.audience == 'Instructors').toList();
                            if (instructorAnnouncements.isNotEmpty) {
                              return Column(
                                children: [
                                  const SizedBox(height: 10),
                                  AnnouncementBanner(
                                    announcement: instructorAnnouncements.first,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }
                            return const SizedBox(height: 18); // Default spacing if no banner
                          },
                        ),
                        
                        // ---- Status Toggle ----
                        Container(
                          width: width,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.circle, size: 10,
                                    color: instructorController.currentInstructor?.status == 'Available'
                                        ? Colors.green
                                        : instructorController.currentInstructor?.status == 'Busy'
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'My Status',
                                    style: GoogleFonts.epilogue(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    instructorController.currentInstructor?.status ?? 'Unknown',
                                    style: GoogleFonts.epilogue(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: instructorController.currentInstructor?.status == 'Available'
                                          ? Colors.green
                                          : instructorController.currentInstructor?.status == 'Busy'
                                              ? Colors.orange
                                              : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatusChip(
                                      label: 'Available',
                                      color: Colors.green,
                                      isSelected: instructorController.currentInstructor?.status == 'Available',
                                      onTap: () => instructorController.updateMyStatus('Available'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _StatusChip(
                                      label: 'Busy',
                                      color: Colors.orange,
                                      isSelected: instructorController.currentInstructor?.status == 'Busy',
                                      onTap: () => instructorController.updateMyStatus('Busy'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _StatusChip(
                                      label: 'On Leave',
                                      color: Colors.red,
                                      isSelected: instructorController.currentInstructor?.status == 'On Leave',
                                      onTap: () => instructorController.updateMyStatus('On Leave'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // ---- Dashboard Stats Cards ----
                        Text(
                          'Dashboard',
                          style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _StatCard(
                              icon: Icons.people_alt_rounded,
                              label: 'Students',
                              value: '${instructorController.totalStudents}',
                              color: const Color(0xFF2979FF),
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.assessment_rounded,
                              label: 'Evaluations',
                              value: '${instructorController.totalEvaluations}',
                              color: const Color(0xFFFF6D00),
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.star_rounded,
                              label: 'Rating',
                              value: instructorController.myRatingsList.isEmpty
                                  ? '--'
                                  : instructorController.averageRating.toStringAsFixed(1),
                              color: const Color(0xFFFFB300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // ---- Quick Actions Grid ----
                        Text(
                          'Quick Actions',
                          style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: instructorServiceList.length,
                          itemBuilder: (context, index) {
                            final item = instructorServiceList[index];
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => item['onTap'],
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.08),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: (item['color'] as Color).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        item['icon'] as IconData,
                                        color: item['color'] as Color,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      item['service name'],
                                      style: GoogleFonts.epilogue(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Stat Card Widget ----
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: GoogleFonts.epilogue(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.epilogue(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Status Chip Widget ----
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.shade400,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)]
                    : null,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.epilogue(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : Colors.grey.shade500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
