import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/views/admin/add_course.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class ManageCourse extends StatelessWidget {
  final bool isReadOnly;

  const ManageCourse({super.key, this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // final adminCourseController = Provider.of<AdminController>(context,listen: false);
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
                        'Manage All Courses',
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
                    'All Courses',
                    style: GoogleFonts.epilogue(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Consumer<AdminController>(
                      builder: (context, adminCourseController, _) {
                    return FutureBuilder(
                        future: adminCourseController.fetchCourses(),
                        builder: (context, snapshot) {
                          return snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : adminCourseController.coursesList.isEmpty
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
                                      itemCount: adminCourseController
                                          .coursesList.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            // Navigator.of(context).push(
                                            //   MaterialPageRoute(
                                            //     builder: (context) => adminCourseController
                                            //         .adminServiceList[index]['onTap'],
                                            //   ),
                                            // );
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
                                                    if (!isReadOnly)
                                                      Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: PopupMenuButton(
                                                          icon: const Icon(
                                                            Icons.more_vert,
                                                            color: Colors.white,
                                                          ),
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              onTap: () {
                                                                Navigator.of(context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        AddCourse(
                                                                      course: adminCourseController
                                                                              .coursesList[
                                                                          index],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: const Text('Edit'),
                                                            ),
                                                            PopupMenuItem(
                                                              onTap: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (context) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                          'Delete Course'),
                                                                      content: const Text(
                                                                          'Are you sure you want to delete this course?'),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                          child: const Text('Cancel'),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            adminCourseController
                                                                                .deleteCourse(
                                                                                    adminCourseController
                                                                                        .coursesList[index]
                                                                                        .courseID,
                                                                                    context);
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                          child: const Text('Delete'),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: const Text(
                                                                  'Delete'),
                                                            ),
                                                          ],
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
                                                                    fontSize:
                                                                        20,
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                          Text(
                                                            adminCourseController
                                                                .coursesList[
                                                                    index]
                                                                .courseName,
                                                            style: GoogleFonts
                                                                .epilogue(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        12),
                                                          ),
                                                          Text(
                                                            '₹${adminCourseController.coursesList[index].coursePrice}',
                                                            style: GoogleFonts
                                                                .fraunces(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        20),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )),
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
      floatingActionButton: isReadOnly ? null : FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddCourse(),
            ),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
