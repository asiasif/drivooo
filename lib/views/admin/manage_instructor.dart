import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/views/admin/add_instructor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ManageInstructor extends StatefulWidget {
  final bool isReadOnly;

  const ManageInstructor({super.key, this.isReadOnly = false});

  @override
  State<ManageInstructor> createState() => _ManageInstructorState();
}

class _ManageInstructorState extends State<ManageInstructor> {
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
      // backgroundColor: Colors.grey[50], // Removed to allow background images to show white/transparent mix if needed, or defaults to white
      body: Stack(
        children: [
           // Background Elements
          Positioned(
              top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Image.asset('assets/Ellipse 36.png')]),
          
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  SizedBox(
                    width: width,
                    height: height / 8, // Adjusted height since it's inside SafeArea and Column
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(EvaIcons.arrow_ios_back_outline),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'Manage Instructors',
                          style: GoogleFonts.epilogue(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Title
                  Text(
                    'Our Instructors',
                    style: GoogleFonts.epilogue(
                        fontSize: 18, 
                        fontWeight: FontWeight.w600,
                        color: Colors.black54
                    ),
                  ),
                  const SizedBox(height: 15),
    
                  // Grid
                  Expanded(
                    child: Consumer<AdminController>(
                      builder: (context, adminInstrctrController, _) {
                        if (_isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (adminInstrctrController.instructorsList.isEmpty) {
                           return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.person_off_outlined, size: 60, color: Colors.grey),
                                    const SizedBox(height: 10),
                                    Text('No Instructors Found', style: GoogleFonts.epilogue(color: Colors.grey)),
                                  ],
                                ),
                           );
                        }

    
                            return GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 0.75, // Taller cards to prevent overflow
                              ),
                              itemCount: adminInstrctrController.instructorsList.length,
                              itemBuilder: (context, index) {
                                final instructor = adminInstrctrController.instructorsList[index];
                                final isAvailable = instructor.status == 'Available';
                                
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Content
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Avatar
                                            Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: isAvailable ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5), width: 2),
                                              ),
                                              child: CircleAvatar(
                                                radius: 32,
                                                backgroundImage: instructor.instructorProPic != null
                                                    ? NetworkImage(instructor.instructorProPic!)
                                                    : const AssetImage('assets/instructor.jpg') as ImageProvider,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            
                                            // Name
                                            Text(
                                              instructor.instructorName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.epilogue(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                              ),
                                            ),
                                            
                                            // Status
                                            Container(
                                              margin: const EdgeInsets.symmetric(vertical: 6),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                instructor.status,
                                                style: GoogleFonts.epilogue(
                                                    color: isAvailable ? Colors.green : Colors.red,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600
                                                ),
                                              ),
                                            ),
                                            
                                            const Spacer(),
    
                                            // Actions Row
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                 // Call Button
                                                 InkWell(
                                                    onTap: () async {
                                                      final Uri launchUri = Uri(
                                                        scheme: 'tel',
                                                        path: instructor.instructorNumber.toString(),
                                                      );
                                                      await launchUrl(launchUri);
                                                    },
                                                    borderRadius: BorderRadius.circular(50),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                          ),
                                                      child: const Icon(Icons.call, color: Colors.blue, size: 20),
                                                    ),
                                                 ),
                                                 
                                                 // Rate Button
                                                 InkWell(
                                                    onTap: () {
                                                        showDialog(context: context, builder: (context) {
                                                           final controller = Provider.of<AdminController>(context, listen: false);
                                                           controller.fetchRatings(instructor.instructorName);
                                                           return AlertDialog(
                                                              title: Text('${instructor.instructorName} Reviews', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                              content: SizedBox(
                                                                width: double.maxFinite,
                                                                child: Consumer<AdminController>(
                                                                  builder: (context, ctrl, _) {
                                                                    if (ctrl.ratingsList.isEmpty) {
                                                                      return const Padding(
                                                                        padding: EdgeInsets.all(20.0),
                                                                        child: Text("No reviews yet."),
                                                                      );
                                                                    }
                                                                    return Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Text("${ctrl.averageRating.toStringAsFixed(1)}", style: GoogleFonts.epilogue(fontSize: 40, fontWeight: FontWeight.bold)),
                                                                        RatingBarIndicator(
                                                                            rating: ctrl.averageRating,
                                                                            itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                                                                            itemCount: 5,
                                                                            itemSize: 20.0,
                                                                        ),
                                                                        const SizedBox(height: 20),
                                                                        Expanded(
                                                                          child: ListView.separated(
                                                                            separatorBuilder: (c, i) => const Divider(),
                                                                            itemCount: ctrl.ratingsList.length,
                                                                            itemBuilder: (context, i) {
                                                                              final review = ctrl.ratingsList[i];
                                                                              return ListTile(
                                                                                contentPadding: EdgeInsets.zero,
                                                                                title: RatingBarIndicator(
                                                                                    rating: review.score,
                                                                                    itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                                                                                    itemCount: 5,
                                                                                    itemSize: 14.0,
                                                                                ),
                                                                                subtitle: Text(
                                                                                  review.comment.isNotEmpty ? review.comment : "No comment",
                                                                                  style: GoogleFonts.epilogue(fontSize: 13),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(context), 
                                                                  child: Text("Close", style: GoogleFonts.epilogue(color: Colors.black))
                                                                )
                                                              ],
                                                           );
                                                        });
                                                    },
                                                    borderRadius: BorderRadius.circular(50),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.amber.withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.star, color: Colors.amber, size: 20),
                                                    ),
                                                 ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
    
                                      // Edit/Delete Menu (Top Right)
                                      if (!widget.isReadOnly)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: PopupMenuButton(
                                            icon: const Icon(Icons.more_horiz, color: Colors.grey),
                                            color: Colors.white,
                                            elevation: 4, 
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                onTap: () {
                                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddInstructor(instructor: instructor)));
                                                },
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.edit, size: 18, color: Colors.blue),
                                                    const SizedBox(width: 10),
                                                    Text('Edit', style: GoogleFonts.epilogue()),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                onTap: () {
                                                   Future.delayed(const Duration(seconds: 0), () => showDialog(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: Text('Delete Instructor', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
                                                        content: const Text('Are you sure you want to delete this instructor?'),
                                                        actions: [
                                                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                                          TextButton(
                                                            onPressed: () {
                                                              adminInstrctrController.deleteInstructor(instructor.instructorID, context);
                                                              Navigator.pop(context);
                                                            },
                                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                          ),
                                                        ],
                                                      ),
                                                    ));
                                                },
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.delete, size: 18, color: Colors.red),
                                                    const SizedBox(width: 10),
                                                    Text('Delete', style: GoogleFonts.epilogue(color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isReadOnly ? null : FloatingActionButton(
        backgroundColor: Colors.black,
        elevation: 4,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddInstructor()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
