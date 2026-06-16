import 'package:driving_school/const.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/services/certificate_service.dart'; // Added correctly
import 'package:driving_school/controller/admin_controller.dart'; 
import 'package:driving_school/views/user/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart'; // Added
import 'package:driving_school/views/user/widgets/user_header_widget.dart';
import 'package:driving_school/views/user/widgets/dashboard_grid_widget.dart';
import 'package:driving_school/views/widgets/announcement_banner.dart';

class UserHome extends StatefulWidget {
  final String uid;
  const UserHome({required this.uid, super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       Provider.of<AdminController>(context, listen: false).fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final userHomeController = Provider.of<UserController>(context);
    final adminController = Provider.of<AdminController>(context); 
    
    print('HOME PAGE');
    return Scaffold(
      body: Stack(
        children: [
            // Background Elements
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
            FutureBuilder(
            future: userHomeController.fetchUserData(widget.uid),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: defaultBlue,
                      ),
                    )
                  : SafeArea(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            // Header Section
                            SizedBox(
                              width: width,
                              child: UserHeaderWidget(userController: userHomeController),
                            ),
                            
                            // ANNOUNCEMENT SECTION
                            Builder(
                              builder: (context) {
                                final userAnnouncements = adminController.announcementList.where((a) => a.audience == 'Both' || a.audience == 'Users').toList();
                                if (userAnnouncements.isNotEmpty) {
                                  return AnnouncementBanner(
                                    announcement: userAnnouncements.first,
                                  );
                                }
                                return const SizedBox.shrink();
                              }
                            ),


                            const SizedBox(height: 15),
                            
                            // Course Card (Smaller)
                            Container(
                              width: width,
                              height: height / 7.5, // Smaller height
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [defaultBlue, Color(0xFF2979FF)], 
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: defaultBlue.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -15,
                                    top: -15,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: -25,
                                    bottom: -25,
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            "select_course".tr(), // Using translation
                                            style: GoogleFonts.epilogue(
                                              color: Colors.white,
                                              fontSize: 9, 
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          userHomeController.userModel.selectedCourse ?? 'No Class Selected',
                                          style: GoogleFonts.epilogue(
                                            color: Colors.white,
                                            fontSize: 20, // Slightly smaller font
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Service Categories
                            Text(
                              "Service Categories:", // Ideally add a JSON key for this later if needed
                              style: GoogleFonts.epilogue(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Service Grid
                            DashboardGridWidget(userController: userHomeController, uid: widget.uid),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  );
            },
          ),
        ],
      )
    );
  }
}
