import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/models/user_model.dart';
import 'package:driving_school/views/admin/admin_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:icons_plus/icons_plus.dart';

class AdminChatList extends StatelessWidget {
  const AdminChatList({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the AdminController, but we will mostly use the stream directly
    final adminController = Provider.of<AdminController>(context, listen: false);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
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
                children: [
                   // Custom Header
                  SizedBox(
                    width: width,
                    height: height / 8, 
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(EvaIcons.arrow_ios_back_outline),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'Student Messages',
                          style: GoogleFonts.epilogue(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: StreamBuilder<List<UserModel>>(
                      stream: adminController.getChatUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                                const SizedBox(height: 10),
                                Text(
                                  'No messages yet',
                                  style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }

                        final users = snapshot.data!;
                        return ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 15),
                          padding: const EdgeInsets.only(bottom: 20),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: user.userProPic != null 
                                      ? NetworkImage(user.userProPic!) 
                                      : const AssetImage('assets/man 1.png') as ImageProvider,
                                ),
                                title: Text(
                                  user.userName,
                                  style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                subtitle: Text(
                                  user.userEmail,
                                  style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (user.hasUnreadMessages == true)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'New',
                                          style: GoogleFonts.epilogue(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                                onTap: () {
                                  // Mark messages as read when opening chat
                                  adminController.markMessagesAsRead(user.userID);
                                  
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminChatScreen(
                                        userId: user.userID,
                                        userName: user.userName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
