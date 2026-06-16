import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/instructor_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:driving_school/views/admin/user_attedance.dart';
import 'package:driving_school/views/instructor/student_evaluation.dart';
import 'package:driving_school/views/instructor/instructor_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:driving_school/const.dart';

import 'package:driving_school/widgets/shimmer_loading.dart';

class InstructorUsersList extends StatefulWidget {
  const InstructorUsersList({super.key});

  @override
  State<InstructorUsersList> createState() => _InstructorUsersListState();
}

class _InstructorUsersListState extends State<InstructorUsersList> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final instructorName = Provider.of<InstructorController>(context, listen: false).currentInstructor?.instructorName ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          Positioned(top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Positioned(
            left: 0,
            top: height * 0.4,
            child: Opacity(opacity: 0.3, child: Image.asset('assets/Ellipse 36.png')),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(EvaIcons.arrow_ios_back_outline),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'My Students',
                        style: GoogleFonts.epilogue(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search by name or email...",
                        hintStyle: GoogleFonts.epilogue(fontSize: 14, color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Student List
                Expanded(
                  child: Consumer<AdminController>(
                    builder: (context, userController, _) {
                      return FutureBuilder(
                        future: userController.fetchUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: 4,
                              itemBuilder: (context, index) => const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: ShimmerCard(),
                              ),
                            );
                          }

                          final filteredList = userController.usersDataList.where((user) {
                            bool matchesInstructor = user.selectedInstructor == instructorName;
                            bool matchesSearch = user.userName.toLowerCase().contains(searchQuery) ||
                                user.userEmail.toLowerCase().contains(searchQuery);
                            return matchesInstructor && matchesSearch;
                          }).toList();

                          if (filteredList.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline, size: 70, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text('No Students Found',
                                      style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 18)),
                                  const SizedBox(height: 4),
                                  Text('Students assigned to you will appear here',
                                      style: GoogleFonts.epilogue(color: Colors.grey.shade400, fontSize: 13)),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final user = filteredList[index];
                              return _StudentCard(
                                name: user.userName,
                                email: user.userEmail,
                                imageUrl: user.userProPic,
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => UserAttendance(
                                      userID: user.userID,
                                      userName: user.userName,
                                      userNumber: user.userNumber,
                                      trainerName: user.selectedInstructor ?? "Not available",
                                    ),
                                  ));
                                },
                                onCall: () async {
                                  final Uri url = Uri(scheme: 'tel', path: user.userNumber.toString());
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                                onChat: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => InstructorChatScreen(
                                      studentId: user.userID,
                                      studentName: user.userName,
                                    ),
                                  ));
                                },
                                onEvaluate: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => StudentEvaluation(
                                      userID: user.userID,
                                      userName: user.userName,
                                    ),
                                  ));
                                },
                                onNote: () {
                                  _showAddNoteDialog(context, user.userID, user.userName);
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, String studentId, String studentName) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Session Note for $studentName',
          style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Write a note about today\'s session. The student will see this in their progress screen.',
              style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'e.g. Good progress on parallel parking...',
                hintStyle: GoogleFonts.epilogue(fontSize: 13, color: Colors.grey.shade400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.epilogue(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: defaultBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (noteController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please write a note'), backgroundColor: Colors.red),
                );
                return;
              }
              final instructorCtrl = Provider.of<InstructorController>(context, listen: false);
              await instructorCtrl.saveSessionNote(
                studentId: studentId,
                note: noteController.text.trim(),
                context: context,
              );
              Navigator.pop(ctx);
            },
            child: Text('Save Note', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ---- Student Card Widget ----
class _StudentCard extends StatelessWidget {
  final String name;
  final String email;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onEvaluate;
  final VoidCallback onNote;

  const _StudentCard({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.onTap,
    required this.onCall,
    required this.onChat,
    required this.onEvaluate,
    required this.onNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl!)
                      : const AssetImage('assets/profile.jpg') as ImageProvider,
                ),
                const SizedBox(width: 14),
                // Name + Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.epilogue(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: GoogleFonts.epilogue(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // 2x2 Action Grid
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionBtn(icon: Icons.call_rounded, color: Colors.green, onTap: onCall),
                        const SizedBox(width: 6),
                        _ActionBtn(icon: Icons.chat_bubble_outline_rounded, color: Colors.orange,  onTap: onChat),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionBtn(icon: Icons.assessment_rounded, color: defaultBlue, onTap: onEvaluate),
                        const SizedBox(width: 6),
                        _ActionBtn(icon: Icons.note_add_outlined, color: Colors.purple, onTap: onNote),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
