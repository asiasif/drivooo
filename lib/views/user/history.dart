import 'package:driving_school/controller/admin_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:driving_school/services/pdf_attendance_service.dart';
import 'package:driving_school/models/rating_model.dart'; // Added
import 'package:driving_school/controller/user_controller.dart'; // Ensure UserController is imported
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Added
import 'package:provider/provider.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // final adminCourseController = Provider.of<UserController>(context);
    return Scaffold(
      body: Stack(
        children: [
          ////////////////////////////////////////////////////////
          Positioned(
              top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Image.asset('assets/Ellipse 36.png')]),
          ///////////////////////////////////////////////////
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: width,
                  height: height / 6,
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(EvaIcons.arrow_ios_back_outline),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Attendance',
                        style: GoogleFonts.epilogue(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  width: width,
                  height: 50,
                  child: Text(
                    'Attendance History',
                    style: GoogleFonts.epilogue(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Consumer<AdminController>(
                      builder: (context, historyController, _) {
                    return FutureBuilder(
                        future: historyController
                            .fetchAtt(FirebaseAuth.instance.currentUser!.uid),
                        builder: (context, snapshot) {
                          return snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : historyController.attList.isEmpty
                                  ? const Center(
                                      child: Text('No attendance history'),
                                    )
                                  : ListView.separated(
                                      itemBuilder: (context, index) {
                                        return Card(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: ListTile(
                                              leading: Image.asset(
                                                  'assets/attendance.png'),
                                              title: SizedBox(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Attendance Date:',
                                                      style:
                                                          GoogleFonts.epilogue(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 15),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        historyController
                                                            .attList[index]
                                                            .attDate,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .fraunces(
                                                                fontSize: 15),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                  IconButton(
                                                  onPressed: () {
                                                    // Show Rating Dialog
                                                    showDialog(context: context, builder: (context) {
                                                      double ratingScore = 5.0;
                                                      TextEditingController commentController = TextEditingController();
                                                      return AlertDialog(
                                                        title: Text('Rate ${historyController.attList[index].trainerName}'),
                                                        content: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            RatingBar.builder(
                                                              initialRating: 5,
                                                              minRating: 1,
                                                              direction: Axis.horizontal,
                                                              allowHalfRating: true,
                                                              itemCount: 5,
                                                              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                              itemBuilder: (context, _) => const Icon(
                                                                Icons.star,
                                                                color: Colors.amber,
                                                              ),
                                                              onRatingUpdate: (rating) {
                                                                ratingScore = rating;
                                                              },
                                                            ),
                                                            const SizedBox(height: 10),
                                                            TextField(
                                                              controller: commentController,
                                                              decoration: const InputDecoration(
                                                                hintText: 'Leave a comment (Optional)',
                                                                border: OutlineInputBorder(),
                                                              ),
                                                              maxLines: 3,
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                                          TextButton(
                                                            onPressed: () {
                                                              final userController = Provider.of<UserController>(context, listen: false);
                                                              final attendance = historyController.attList[index];
                                                              
                                                              // Create Rating Model
                                                              // Note: associating via Name since ID is missing in AttendanceModel
                                                              RatingModel newRating = RatingModel(
                                                                ratingID: DateTime.now().millisecondsSinceEpoch.toString(),
                                                                instructorID: attendance.trainerName, // Using Name as ID for now
                                                                studentID: attendance.userID,
                                                                studentName: 'Student', // Ideally fetch user name
                                                                score: ratingScore,
                                                                comment: commentController.text,
                                                                timestamp: DateTime.now().toString(),
                                                              );
                                                              
                                                              userController.addRating(newRating, context);
                                                              Navigator.pop(context);
                                                            },
                                                            child: const Text('Submit'),
                                                          ),
                                                        ],
                                                      );
                                                    });
                                                  },
                                                  icon: const Icon(Icons.star_rate, color: Colors.amber),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Generating PDF...')),
                                                    );
                                                    try {
                                                      final attendance = historyController.attList[index];
                                                      await PdfAttendanceService.generate(attendance);
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Error generating PDF: $e')),
                                                      );
                                                    }
                                                  },
                                                  child: Image.asset('assets/invoice_tail.png'),
                                                ),
                                              ],
                                            ),
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(
                                            height: 10,
                                          ),
                                      itemCount:
                                          historyController.attList.length);
                        });
                  }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
