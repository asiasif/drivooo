import 'package:driving_school/controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';

class ManageAnnouncements extends StatefulWidget {
  const ManageAnnouncements({super.key});

  @override
  State<ManageAnnouncements> createState() => _ManageAnnouncementsState();
}

class _ManageAnnouncementsState extends State<ManageAnnouncements> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Info';
  String _selectedAudience = 'Both';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false).fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminController = Provider.of<AdminController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(EvaIcons.arrow_ios_back_outline, color: Colors.black),
        ),
        title: Text(
          'Manage Announcements',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add Announcement Form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Post New Notice', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _titleController,
                            style: GoogleFonts.epilogue(fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: GoogleFonts.epilogue(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (v) => v!.isEmpty ? 'Enter Title' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: GoogleFonts.epilogue(fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Message',
                              labelStyle: GoogleFonts.epilogue(color: Colors.grey[500]),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (v) => v!.isEmpty ? 'Enter Message' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Priority Type',
                              labelStyle: GoogleFonts.epilogue(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            items: ['Info', 'Urgent'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(
                                      value == 'Urgent' ? Icons.warning_rounded : Icons.info_outline_rounded,
                                      color: value == 'Urgent' ? Colors.red.shade400 : Colors.blue.shade400,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedType = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedAudience,
                            style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Audience',
                              labelStyle: GoogleFonts.epilogue(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            items: ['Both', 'Users', 'Instructors'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(
                                      value == 'Both' ? Icons.people_outline : (value == 'Users' ? Icons.person_outline : Icons.school_outlined),
                                      color: Colors.grey.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedAudience = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  adminController.addAnnouncement(
                                      _titleController.text, _descriptionController.text, _selectedType, _selectedAudience, context);
                                  _titleController.clear();
                                  _descriptionController.clear();
                                  setState(() {
                                    _selectedType = 'Info';
                                    _selectedAudience = 'Both';
                                  });
                                }
                              },
                              icon: const Icon(Icons.send_rounded, size: 20),
                              label: Text('Post Notice', style: GoogleFonts.epilogue(fontWeight: FontWeight.w600)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Text('Active Announcements',
                          style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${adminController.announcementList.length}',
                          style: GoogleFonts.epilogue(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          adminController.announcementList.isEmpty
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text('No Active Announcements', style: GoogleFonts.epilogue(color: Colors.grey[400])),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notice = adminController.announcementList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[100]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: notice.type == 'Urgent' ? Colors.red.withOpacity(0.08) : Colors.blue.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                notice.type == 'Urgent' ? Icons.warning_rounded : Icons.info_outline_rounded,
                                color: notice.type == 'Urgent' ? Colors.red.shade400 : Colors.blue.shade400,
                                size: 24,
                              ),
                            ),
                            title: Text(notice.title, style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(notice.description, style: GoogleFonts.epilogue(color: Colors.grey[600], height: 1.4)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                                    const SizedBox(width: 4),
                                    Text(notice.date,
                                        style: GoogleFonts.epilogue(
                                            fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(notice.audience, style: GoogleFonts.epilogue(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: Colors.red[300]),
                              onPressed: () {
                                adminController.deleteAnnouncement(notice.id, context);
                              },
                            ),
                          ),
                        );
                      },
                      childCount: adminController.announcementList.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
