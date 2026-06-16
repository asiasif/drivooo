import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

class SuperAdminAnnouncements extends StatefulWidget {
  const SuperAdminAnnouncements({super.key});

  @override
  State<SuperAdminAnnouncements> createState() => _SuperAdminAnnouncementsState();
}

class _SuperAdminAnnouncementsState extends State<SuperAdminAnnouncements> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Info';
  bool _isPosting = false;

  final _db = FirebaseFirestore.instance;

  Future<void> _postNotice() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPosting = true);
    try {
      final doc = _db.collection('super_admin_notices').doc();
      await doc.set({
        'id': doc.id,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'type': _selectedType,
        'date': DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
      });
      _titleController.clear();
      _descController.clear();
      setState(() => _selectedType = 'Info');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice posted to Admin!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isPosting = false);
  }

  Future<void> _deleteNotice(String id) async {
    await _db.collection('super_admin_notices').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notice deleted'), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Admin Notices',
          style: GoogleFonts.epilogue(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.campaign_rounded, color: Colors.deepPurple, size: 22),
                              ),
                              const SizedBox(width: 10),
                              Text('Post New Notice to Admin', style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _titleController,
                            style: GoogleFonts.epilogue(fontWeight: FontWeight.w500),
                            decoration: _inputDecoration('Title'),
                            validator: (v) => v!.isEmpty ? 'Enter Title' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descController,
                            maxLines: 3,
                            style: GoogleFonts.epilogue(fontWeight: FontWeight.w500),
                            decoration: _inputDecoration('Message'),
                            validator: (v) => v!.isEmpty ? 'Enter Message' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, color: Colors.black87),
                            decoration: _inputDecoration('Priority Type'),
                            items: ['Info', 'Urgent'].map((val) {
                              return DropdownMenuItem(
                                value: val,
                                child: Row(
                                  children: [
                                    Icon(
                                      val == 'Urgent' ? Icons.warning_rounded : Icons.info_outline_rounded,
                                      color: val == 'Urgent' ? Colors.red.shade400 : Colors.blue.shade400,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(val),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedType = v!),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isPosting ? null : _postNotice,
                              icon: _isPosting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.send_rounded, size: 20),
                              label: Text('Post Notice', style: GoogleFonts.epilogue(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text('Active Notices', style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('super_admin_notices').orderBy('date', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text('No Active Notices', style: GoogleFonts.epilogue(color: Colors.grey[400])),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final isUrgent = data['type'] == 'Urgent';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isUrgent ? Colors.red.shade100 : Colors.grey[100]!),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUrgent ? Colors.red.withOpacity(0.08) : Colors.deepPurple.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isUrgent ? Icons.warning_rounded : Icons.campaign_rounded,
                              color: isUrgent ? Colors.red.shade400 : Colors.deepPurple,
                              size: 24,
                            ),
                          ),
                          title: Text(data['title'] ?? '', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(data['description'] ?? '', style: GoogleFonts.epilogue(color: Colors.grey[600], height: 1.4)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(data['date'] ?? '', style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey[400])),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('Admin Only', style: GoogleFonts.epilogue(fontSize: 10, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: Colors.red[300]),
                            onPressed: () => _deleteNotice(data['id']),
                          ),
                        ),
                      );
                    },
                    childCount: docs.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.epilogue(color: Colors.grey[500]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurple)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
