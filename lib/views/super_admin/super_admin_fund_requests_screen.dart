import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SuperAdminFundRequestsScreen extends StatelessWidget {
  const SuperAdminFundRequestsScreen({super.key});

  Future<void> _approveRequest(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('fund_requests')
        .doc(docId)
        .update({'status': 'Approved', 'rejectionNote': ''});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request approved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectRequest(BuildContext context, String docId) async {
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject Request',
            style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please provide a reason for rejection:',
              style: GoogleFonts.epilogue(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              style: GoogleFonts.epilogue(),
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                hintStyle: GoogleFonts.epilogue(color: Colors.grey[400]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
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
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final note = noteController.text.trim();
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('fund_requests')
                  .doc(docId)
                  .update({
                'status': 'Rejected',
                'rejectionNote': note.isEmpty ? 'No reason provided' : note,
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request rejected.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Reject', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved': return Colors.green;
      case 'Rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Approved': return Icons.check_circle_rounded;
      case 'Rejected': return Icons.cancel_rounded;
      default: return Icons.hourglass_empty_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Fund Requests',
          style: GoogleFonts.epilogue(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fund_requests')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'No fund requests yet',
                    style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final pendingCount = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['status'] == 'Pending';
          }).length;

          return Column(
            children: [
              if (pendingCount > 0)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pending_actions_rounded, color: Colors.orange),
                      const SizedBox(width: 10),
                      Text(
                        '$pendingCount pending request${pendingCount > 1 ? 's' : ''} need your attention',
                        style: GoogleFonts.epilogue(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'Pending';
                    final amount = double.tryParse(data['amount'].toString()) ?? 0.0;
                    final reason = data['reason'] ?? '';
                    final date = data['date'] ?? '';
                    final rejectionNote = data['rejectionNote'] ?? '';
                    final isPending = status == 'Pending';

                    String displayDate = '';
                    try {
                      displayDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(date));
                    } catch (_) {
                      displayDate = date;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _statusColor(status).withOpacity(0.25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.07),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: amount + status chip
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${amount.toStringAsFixed(0)}',
                                style: GoogleFonts.epilogue(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_statusIcon(status), color: _statusColor(status), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      status,
                                      style: GoogleFonts.epilogue(
                                        color: _statusColor(status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Reason
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.notes_rounded, size: 15, color: Colors.grey[500]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: GoogleFonts.epilogue(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Date
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 13, color: Colors.grey[400]),
                              const SizedBox(width: 5),
                              Text(
                                displayDate,
                                style: GoogleFonts.epilogue(
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          // Rejection note
                          if (status == 'Rejected' && rejectionNote.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                'Note: $rejectionNote',
                                style: GoogleFonts.epilogue(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                          // Action buttons (only for pending)
                          if (isPending) ...[
                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _rejectRequest(context, doc.id),
                                    icon: const Icon(Icons.close_rounded, color: Colors.red, size: 18),
                                    label: Text(
                                      'Reject',
                                      style: GoogleFonts.epilogue(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _approveRequest(context, doc.id),
                                    icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                                    label: Text(
                                      'Approve',
                                      style: GoogleFonts.epilogue(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
