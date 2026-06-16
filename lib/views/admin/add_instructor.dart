import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/models/instructor_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class AddInstructor extends StatefulWidget {
  final InstructorModel? instructor;
  const AddInstructor({super.key, this.instructor});

  @override
  State<AddInstructor> createState() => _AddInstructorState();
}

class _AddInstructorState extends State<AddInstructor> {
  String selectedStatus = 'Available';
  final List<String> statusOptions = ['Available', 'Busy', 'On Leave'];

  @override
  void initState() {
    super.initState();
    final adminController =
        Provider.of<AdminController>(context, listen: false);
    final userController =
    Provider.of<UserController>(context, listen: false);

    if (widget.instructor != null) {
      adminController.instrcutorNameController.text =
          widget.instructor!.instructorName;
      adminController.instrcutorNumberController.text =
          widget.instructor!.instructorNumber.toString();
      adminController.instructorEmailController.text =
          widget.instructor!.instructorEmail ?? '';
      adminController.instructorUpiController.text = 
          widget.instructor!.upiId ?? '';
      // Logic to handle initial image display from URL if needed could go here
      // But userController.proPicPath is local file path.
      // We'll reset local path to null to rely on network image in UI logic or handle display there.
      userController.proPicPath = null;
      userController.proPic = null;
      selectedStatus = widget.instructor!.status;
    } else {
      adminController.instrcutorNameController.clear();
      adminController.instrcutorNumberController.clear();
      adminController.instructorEmailController.clear();
      adminController.instructorUpiController.clear();
      selectedStatus = 'Available';
      userController.proPicPath = null;
      userController.proPic = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final adminInstrctrController = Provider.of<AdminController>(context);
    final instrctrPicController = Provider.of<UserController>(context);

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
                  widget.instructor == null ? 'Setup Instructor' : 'Edit Instructor',
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
              key: adminInstrctrController.instrcutorAddKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.instructor == null
                        ? 'Add Contact Information'
                        : 'Edit Contact Information',
                    style: GoogleFonts.epilogue(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      instrctrPicController.selectproPic(context);
                    },
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: instrctrPicController.proPicPath != null
                                ? (kIsWeb 
                                    ? NetworkImage(instrctrPicController.proPicPath!) 
                                    : FileImage(File(instrctrPicController.proPicPath!)) as ImageProvider)
                                : widget.instructor?.instructorProPic != null
                                    ? NetworkImage(
                                        widget.instructor!.instructorProPic!)
                                    : const AssetImage('assets/instructor.jpg')
                                        as ImageProvider,
                            fit: BoxFit.cover),
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller:
                        adminInstrctrController.instrcutorNameController,
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
                      hintText: 'Enter Fullname',
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller:
                        adminInstrctrController.instrcutorNumberController,
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
                      hintText: 'Enter Phonenumber',
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller:
                        adminInstrctrController.instructorEmailController,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return '*valid email required';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      hintStyle: GoogleFonts.epilogue(),
                      hintText: 'Enter Email Address',
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller:
                        adminInstrctrController.instructorUpiController,
                    decoration: InputDecoration(
                      isDense: true,
                      hintStyle: GoogleFonts.epilogue(),
                      hintText: 'Enter UPI ID (Optional - for salary)',
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                    items: statusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStatus = newValue!;
                      });
                    },
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
                        if (adminInstrctrController
                            .instrcutorAddKey.currentState!
                            .validate()) {
                          if (widget.instructor == null) {
                            // CREATE NEW
                            if (instrctrPicController.proPicPath != null) {
                              adminInstrctrController
                                  .saveInstructor(
                                      adminInstrctrController
                                          .instrcutorNameController.text,
                                      int.parse(adminInstrctrController
                                          .instrcutorNumberController.text),
                                      adminInstrctrController
                                          .instructorEmailController.text,
                                      instrctrPicController.proPicPath!,
                                      selectedStatus,
                                      adminInstrctrController.instructorUpiController.text.isNotEmpty 
                                          ? adminInstrctrController.instructorUpiController.text 
                                          : null)
                                  .then(
                                    (value) => adminInstrctrController
                                        .uploadInstructorProPic(
                                      instrctrPicController.proPic!,
                                      'Instructors Profile Pic',
                                      adminInstrctrController.instructorid,
                                    ),
                                  )
                                  .whenComplete(
                                    () => Navigator.of(context).pop(),
                                  );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select an image'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            // UPDATE EXISTING
                            print('Updating instructor...');
                            InstructorModel updatedData = InstructorModel(
                              instructorID: widget.instructor!.instructorID,
                              instructorName: adminInstrctrController
                                  .instrcutorNameController.text,
                              instructorNumber: int.parse(adminInstrctrController
                                  .instrcutorNumberController.text),
                              instructorEmail: adminInstrctrController
                                  .instructorEmailController.text,
                              instructorProPic:
                                  widget.instructor!.instructorProPic, // Old URL
                              status: selectedStatus,
                              upiId: adminInstrctrController.instructorUpiController.text.isNotEmpty
                                  ? adminInstrctrController.instructorUpiController.text
                                  : null,
                            );

                            adminInstrctrController.updateInstructor(
                                updatedData, instrctrPicController.proPic, context);
                          }
                        }
                      },
                      child: Text(
                        widget.instructor == null ? 'Upload' : 'Update',
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
