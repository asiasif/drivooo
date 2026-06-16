import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:driving_school/views/admin/user_attedance.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

import 'package:driving_school/widgets/shimmer_loading.dart';

class UsersList extends StatefulWidget {
  final bool isReadOnly;

  const UsersList({super.key, this.isReadOnly = false});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
                        'All Users',
                        style: GoogleFonts.epilogue(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() => searchQuery = value.toLowerCase());
                    },
                    decoration: InputDecoration(
                      hintText: "Search by name or email...",
                      hintStyle: GoogleFonts.epilogue(fontSize: 14, color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // User List
                Expanded(
                  child: Consumer<AdminController>(
                    builder: (context, userController, _) {
                      return FutureBuilder(
                        future: userController.fetchUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: 5,
                              itemBuilder: (context, index) => const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: ShimmerCard(),
                              ),
                            );
                          }

                          final filteredList = userController.usersDataList.where((user) {
                            return user.userName.toLowerCase().contains(searchQuery) ||
                                user.userEmail.toLowerCase().contains(searchQuery);
                          }).toList();

                          if (filteredList.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline, size: 70, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text('No Users Found',
                                      style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 18)),
                                  const SizedBox(height: 4),
                                  Text('Registered users will appear here',
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
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.07),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    onTap: widget.isReadOnly ? null : () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => UserAttendance(
                                          userID: user.userID,
                                          userName: user.userName,
                                          userNumber: user.userNumber,
                                          trainerName: user.selectedInstructor ?? "Not available",
                                        ),
                                      ));
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          // Avatar
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundImage: user.userProPic != null
                                                ? NetworkImage(user.userProPic!)
                                                : const AssetImage('assets/profile.jpg') as ImageProvider,
                                          ),
                                          const SizedBox(width: 14),
                                          // Name + Instructor
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user.userName,
                                                  style: GoogleFonts.epilogue(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (!widget.isReadOnly) ...[
                                                  const SizedBox(height: 3),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.school_outlined, size: 13, color: Colors.grey.shade400),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          user.selectedInstructor == null || user.selectedInstructor == 'No Instructor Selected'
                                                              ? 'No instructor'
                                                              : user.selectedInstructor!,
                                                          style: GoogleFonts.epilogue(
                                                            fontSize: 12,
                                                            color: user.selectedInstructor == null || user.selectedInstructor == 'No Instructor Selected'
                                                                ? Colors.red
                                                                : defaultBlue,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          // Action buttons
                                          if (!widget.isReadOnly)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _ActionBtn(
                                                  icon: Icons.call_rounded,
                                                  color: Colors.green,
                                                  onTap: () async {
                                                    final Uri url = Uri(scheme: 'tel', path: user.userNumber.toString());
                                                    if (await canLaunchUrl(url)) {
                                                      await launchUrl(url);
                                                    }
                                                  },
                                                ),
                                                const SizedBox(width: 6),
                                                _ActionBtn(
                                                  icon: Icons.person_add_alt_1_rounded,
                                                  color: defaultBlue,
                                                  onTap: () async {
                                                    await userController.fetchInstructors();
                                                    if (!context.mounted) return;
                                                    _showAssignInstructorDialog(
                                                        context, userController, user.userID, user.selectedInstructor);
                                                  },
                                                ),
                                                const SizedBox(width: 6),
                                                _ActionBtn(
                                                  icon: Icons.delete_outline_rounded,
                                                  color: Colors.red,
                                                  onTap: () {
                                                    _showDeleteDialog(context, userController, user.userID, user.userName);
                                                  },
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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

  void _showAssignInstructorDialog(
      BuildContext context, AdminController userController, String userId, String? currentInstructor) {
    final uniqueInstructors = <String, dynamic>{};
    for (final i in userController.instructorsList) {
      uniqueInstructors[i.instructorName] = i;
    }
    final deduped = uniqueInstructors.values.toList();
    String? selectedInstructorValue = userController.instructorsList
            .any((i) => i.instructorName == currentInstructor)
        ? currentInstructor
        : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Assign Instructor', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        content: deduped.isEmpty
            ? const SizedBox(height: 50, child: Center(child: Text('No instructors found')))
            : DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Instructor',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                value: selectedInstructorValue,
                items: deduped.map<DropdownMenuItem<String>>((instructor) {
                  return DropdownMenuItem<String>(
                    value: instructor.instructorName as String,
                    child: Text(instructor.instructorName as String),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedInstructorValue = val;
                },
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.epilogue(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: defaultBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (selectedInstructorValue != null) {
                userController.assignInstructorToUser(userId, selectedInstructorValue!, context);
              }
              Navigator.pop(context);
            },
            child: Text('Assign', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AdminController userController, String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete User', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete $userName?', style: GoogleFonts.epilogue()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.epilogue(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              userController.deleteUser(userId, context);
            },
            child: Text('Delete', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ---- Action Button Widget ----
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
