import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class AddCourse extends StatefulWidget {
  final CourseModel? course;
  const AddCourse({super.key, this.course});

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  @override
  void initState() {
    super.initState();
    final adminCourseController =
        Provider.of<AdminController>(context, listen: false);
    if (widget.course != null) {
      adminCourseController.courseNameController.text =
          widget.course!.courseName;
      adminCourseController.courseHoursController.text =
          widget.course!.courseHours.toString();
      adminCourseController.coursePriceController.text =
          widget.course!.coursePrice.toString();
    } else {
      adminCourseController.courseNameController.clear();
      adminCourseController.courseHoursController.clear();
      adminCourseController.coursePriceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final adminCourseController = Provider.of<AdminController>(context);

    return Scaffold(
      body: Stack(
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
                  widget.course == null ? 'Add Course' : 'Edit Course',
                  style: GoogleFonts.epilogue(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ////////////////////////////////////////////////////////
          Positioned(
              top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Image.asset('assets/Ellipse 36.png')]),

          //////////////////////////////////////////////////////
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: Form(
              key: adminCourseController.courseAddKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter details',
                    style: GoogleFonts.epilogue(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: adminCourseController.courseNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '*required field';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      hintStyle: GoogleFonts.epilogue(),
                      hintText: 'Enter course name',
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: adminCourseController.courseHoursController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '*required field';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      hintStyle: GoogleFonts.epilogue(),
                      hintText: 'Enter total hours',
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: adminCourseController.coursePriceController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '*required field';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      hintStyle: GoogleFonts.epilogue(),
                      hintText: 'Enter price',
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: width,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        backgroundColor:
                            const MaterialStatePropertyAll(defaultBlue),
                      ),
                      onPressed: () {
                        if (adminCourseController.courseAddKey.currentState!
                            .validate()) {
                          if (widget.course == null) {
                            adminCourseController
                                .saveCourse(
                                    adminCourseController
                                        .courseNameController.text,
                                    int.parse(adminCourseController
                                        .courseHoursController.text),
                                    int.parse(adminCourseController
                                        .coursePriceController.text))
                                .then((value) => Navigator.of(context).pop());
                          } else {
                            adminCourseController.updateCourse(
                                CourseModel(
                                  courseID: widget.course!.courseID,
                                  courseName: adminCourseController
                                      .courseNameController.text,
                                  courseHours: int.parse(adminCourseController
                                      .courseHoursController.text),
                                  coursePrice: int.parse(adminCourseController
                                      .coursePriceController.text),
                                ),
                                context);
                          }
                        }
                      },
                      child: Text(
                        widget.course == null ? 'Upload' : 'Update',
                        style: GoogleFonts.epilogue(
                            fontSize: 15, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
