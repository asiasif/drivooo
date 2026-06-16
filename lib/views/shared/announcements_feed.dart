import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class AnnouncementsFeed extends StatefulWidget {
  const AnnouncementsFeed({super.key});

  @override
  State<AnnouncementsFeed> createState() => _AnnouncementsFeedState();
}

class _AnnouncementsFeedState extends State<AnnouncementsFeed> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false).fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(EvaIcons.arrow_ios_back_outline, color: Colors.black),
        ),
        title: Text(
          'Announcements',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AdminController>(
        builder: (context, controller, child) {
          if (controller.announcementList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No Announcements Yet',
                    style: GoogleFonts.epilogue(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for updates from the admin.',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: controller.announcementList.length,
            itemBuilder: (context, index) {
              final announcement = controller.announcementList[index];
              final isUrgent = announcement.type == 'Urgent';

              final Color bgColor = isUrgent ? Colors.red.shade50 : const Color(0xFFF0F6FF);
              final Color borderColor = isUrgent ? Colors.red.shade200 : Colors.blue.shade200;
              final Color iconColor = isUrgent ? Colors.red.shade600 : Colors.blue.shade700;
              final Color titleColor = isUrgent ? Colors.red.shade900 : Colors.blue.shade900;
              final Color descColor = isUrgent ? Colors.red.shade700 : Colors.blue.shade800;
              final IconData icon = isUrgent ? Icons.warning_amber_rounded : Icons.campaign_rounded;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: isUrgent ? Colors.red.withOpacity(0.05) : Colors.blue.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon styling
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUrgent ? Colors.red.shade100 : Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  announcement.title,
                                  style: GoogleFonts.epilogue(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: titleColor,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              if (announcement.date.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    announcement.date,
                                    style: GoogleFonts.epilogue(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: iconColor,
                                    ),
                                  ),
                                )
                              ]
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            announcement.description,
                            style: GoogleFonts.epilogue(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: descColor,
                              height: 1.4,
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
    );
  }
}
