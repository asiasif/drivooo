import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/views/user/choose_payment.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class Courses extends StatelessWidget {
  const Courses({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final adminCourseController = Provider.of<UserController>(context);
    return Scaffold(
      body: Stack(
        children: [
          ////////////////////////////////////////////////////////
          Positioned(
              top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          // Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [Image.asset('assets/Ellipse 36.png')]),
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
                        'Packages',
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
                    'Choose Package',
                    style: GoogleFonts.epilogue(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Consumer2<AdminController, UserController>(
                      builder: (context, courseController, userController, _) {
                    return FutureBuilder(
                        future: courseController.fetchCourses(),
                        builder: (context, snapshot) {
                          return snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : courseController.coursesList.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No Courses Found',
                                        style: GoogleFonts.epilogue(),
                                      ),
                                    )
                                  : GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 20,
                                              mainAxisSpacing: 20,
                                              childAspectRatio: 1),
                                      itemCount:
                                          courseController.coursesList.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChoosePayment(
                                                  price: double.parse(
                                                    courseController
                                                        .coursesList[index]
                                                        .coursePrice
                                                        .toString(),
                                                  ),
                                                  courseName: courseController
                                                      .coursesList[index]
                                                      .courseName,
                                                  userName: userController
                                                      .userModel.userName,
                                                  invoiceDate:
                                                      DateTime.now().toString(),
                                                ),
                                              ),
                                            );
                                          },
                                          radius: 20,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: SizedBox(
                                            height: height * .19,
                                            child: Card(
                                              color: index % 2 == 0
                                                  ? const Color(0xFF1B53FF)
                                                  : const Color(0xFFF4E558),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    right: 0,
                                                    child: Image.asset(
                                                      'assets/Ellipse 15.png',
                                                      scale: 0.9,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    child: Image.asset(
                                                      'assets/Ellipse 14.png',
                                                      scale: 0.9,
                                                    ),
                                                  ),
                                                  ////////////////////////////////////////////
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Text(
                                                          '${index + 1}',
                                                          style: GoogleFonts
                                                              .fraunces(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        Text(
                                                          courseController.coursesList[index].courseName,
                                                          style: GoogleFonts.epilogue(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              '${courseController.coursesList[index].courseHours} Hours',
                                                              style: GoogleFonts.epilogue(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          '₹${courseController.coursesList[index].coursePrice}',
                                                          style: GoogleFonts.fraunces(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
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
