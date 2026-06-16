import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:driving_school/views/user/edit_profile_screen.dart'; // Correctly placed import
import 'package:provider/provider.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final userProfileController = Provider.of<UserController>(context);
    final adminProfileController = Provider.of<AdminController>(context);
    return Scaffold(
      body: FutureBuilder(
          future: Future.wait([
            adminProfileController.fetchAtt(userProfileController.firebaseAuth.currentUser!.uid),
            userProfileController.fetchInvoices(),
            adminProfileController.fetchCourses(),
          ]),
          builder: (context, snapshot) {
            print(userProfileController.invoiceList.length);
            print(adminProfileController.attList.length);
            
            int courseDuration = 30; // Default
            if (userProfileController.userModel.selectedCourse != null) {
              try {
                final course = adminProfileController.coursesList.firstWhere(
                  (c) => c.courseName == userProfileController.userModel.selectedCourse
                );
                courseDuration = course.courseHours;
              } catch (e) {
                print("Course not found in list: $e");
              }
            }

            return snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: width,
                            height: height / 2,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.elliptical(100, 50),
                                bottomRight: Radius.elliptical(100, 50),
                              ),
                              color: defaultBlue,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            height: height / 2,
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 80,
                          ),
                          child: SizedBox(
                            width: width,
                            height: height / 1.7,
                            child: Card(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      width: width,
                                      child: Card(
                                        color: defaultBlue,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: userProfileController
                                                      .userModel
                                                      .selectedCourse ==
                                                  null
                                              ? Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            50.0),
                                                    child: Text(
                                                      'No Course Selected',
                                                      style: GoogleFonts
                                                          .epilogue(),
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      userProfileController
                                                          .userModel
                                                          .selectedCourse!,
                                                      style: GoogleFonts
                                                          .epilogue(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      '$courseDuration Days',
                                                      style: GoogleFonts
                                                          .epilogue(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      'Due Date : ${userProfileController.invoiceList.isNotEmpty ? userProfileController.invoiceList[0].dueDate : "N/A"}',
                                                      style: GoogleFonts
                                                          .epilogue(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    if (userProfileController.userModel.selectedCourse != null) ...[
                                      Text(
                                        'Days Remaining',
                                        style:
                                            GoogleFonts.epilogue(fontSize: 15),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        height: height / 5,
                                        width: width,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                          gradient: LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFF4E558),
                                              Color(0xFFF23479),
                                              Color(0xFF3D6DFF),
                                            ],
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${courseDuration - adminProfileController.attList.length}',
                                                style: GoogleFonts.fraunces(
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                'Days',
                                                style: GoogleFonts.fraunces(
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: height * 0.13,
                        right: 0,
                        left: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  userProfileController.userModel.userProPic !=
                                          null
                                      ? NetworkImage(userProfileController
                                          .userModel.userProPic!)
                                      : const AssetImage('assets/profile.jpg')
                                          as ImageProvider,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              userProfileController.userModel.userName,
                              style: GoogleFonts.epilogue(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
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
                              icon: const Icon(
                                EvaIcons.arrow_ios_back_outline,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded( 
                              child: Text(
                                'Profile',
                                style: GoogleFonts.epilogue(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                             IconButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                              },
                              icon: const Icon(EvaIcons.edit_2_outline, color: Colors.white),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ],
                  );
          }),
    );
  }
}
