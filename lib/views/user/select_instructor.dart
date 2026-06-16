import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ChooseInstructor extends StatefulWidget {
  const ChooseInstructor({super.key});

  @override
  State<ChooseInstructor> createState() => _ChooseInstructorState();
}

class _ChooseInstructorState extends State<ChooseInstructor> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInstructors();
  }

  Future<void> _loadInstructors() async {
    final adminController = Provider.of<AdminController>(context, listen: false);
    await adminController.fetchInstructors();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Image.asset('assets/Ellipse 36.png')]),
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
                        'Select Instructor',
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
                    'Our all Instructors',
                    style: GoogleFonts.epilogue(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Consumer2<AdminController, UserController>(builder:
                      (context, instructorController, userinstrController, _) {
                    if (_isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (instructorController.instructorsList.isEmpty) {
                      return Center(
                        child: Text(
                          'No Instructors Found',
                          style: GoogleFonts.epilogue(),
                        ),
                      );
                    }
                    return GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 15,
                                              mainAxisSpacing: 15,
                                              childAspectRatio: 0.75),
                                      itemCount: instructorController
                                          .instructorsList.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            // Handle tap
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                // Profile Image
                                                Container(
                                                  padding: const EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.grey.shade200,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 32,
                                                    backgroundImage: instructorController
                                                                .instructorsList[index]
                                                                .instructorProPic != null
                                                        ? NetworkImage(instructorController
                                                            .instructorsList[index]
                                                            .instructorProPic!)
                                                        : const AssetImage(
                                                                'assets/instructor.jpg')
                                                            as ImageProvider,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                
                                                // Name
                                                Text(
                                                  instructorController.instructorsList[index].instructorName,
                                                  style: GoogleFonts.epilogue(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),

                                                // Status
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: instructorController.instructorsList[index].status == 'Available'
                                                        ? Colors.green.withOpacity(0.1)
                                                        : Colors.red.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    instructorController.instructorsList[index].status,
                                                    style: GoogleFonts.epilogue(
                                                      color: instructorController.instructorsList[index].status == 'Available'
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),

                                                // Actions
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 36,
                                                          child: ElevatedButton(
                                                            onPressed: instructorController.instructorsList[index].status == 'Available'
                                                                ? () {
                                                                    userinstrController.updateInstructor(
                                                                        instructorController.instructorsList[index].instructorName,
                                                                        context);
                                                                  }
                                                                : null,
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.black,
                                                              foregroundColor: Colors.white,
                                                              elevation: 0,
                                                              padding: EdgeInsets.zero,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              disabledBackgroundColor: Colors.grey.shade300,
                                                            ),
                                                            child: Text(
                                                              'Select',
                                                              style: GoogleFonts.epilogue(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      SizedBox(
                                                        width: 36,
                                                        height: 36,
                                                        child: IconButton.filled(
                                                          onPressed: () async {
                                                            final Uri launchUri = Uri(
                                                              scheme: 'tel',
                                                              path: instructorController.instructorsList[index].instructorNumber.toString(),
                                                            );
                                                            await launchUrl(launchUri);
                                                          },
                                                          style: IconButton.styleFrom(
                                                            backgroundColor: Colors.grey.shade100,
                                                            foregroundColor: Colors.black87,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                          ),
                                                          icon: const Icon(Icons.call_outlined, size: 18),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
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
