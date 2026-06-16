import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/services/certificate_service.dart';
import 'package:driving_school/views/user/my_progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:driving_school/controller/mock_test_controller.dart';
import 'package:driving_school/views/user/mock_test_screen.dart';

class DashboardGridWidget extends StatelessWidget {
  final UserController userController;
  final String uid;

  const DashboardGridWidget({
    super.key,
    required this.userController,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: userController.userServiceList.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async {
             final serviceName = userController.userServiceList[index]['service name'];
             
            if (serviceName == 'Certificate') {
              if (userController.userModel.selectedCourse == null ||
                  userController.userModel.selectedCourse == 'No Course Selected') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("You need to enroll in a course first!")),
                );
                return;
              }
              
              // Check if course is completed
              if (userController.userModel.isCourseCompleted != true) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Course not completed yet! Please contact Admin for approval."),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Generating Certificate...")),
              );
              await CertificateService.generateCertificate(
                studentName: userController.userModel.userName,
                courseName: userController.userModel.selectedCourse!,
                date: DateFormat('dd MMM yyyy').format(DateTime.now()),
              );
            } else if (serviceName == 'Mock Test') {
              // Trigger AI Smart Mock Test formulation asynchronously before navigating
              final mockController = Provider.of<MockTestController>(context, listen: false);
              mockController.startQuiz(); // Initiates fetch and loading state
              
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MockTestScreen(),
                ),
              );
            } else if (serviceName == 'My Progress') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MyProgressScreen(uid: uid),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      userController.userServiceList[index]['onTap'],
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Image.asset(
                        userController.userServiceList[index]['image'],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userController.userServiceList[index]['service name'],
                style: GoogleFonts.epilogue(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
      },
    );
  }
}
