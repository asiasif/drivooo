import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school/const.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminFundRequestScreen extends StatefulWidget {
  const AdminFundRequestScreen({super.key});

  @override
  State<AdminFundRequestScreen> createState() => _AdminFundRequestScreenState();
}

class _AdminFundRequestScreenState extends State<AdminFundRequestScreen> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      await _firestore.collection('fund_requests').add({
        'amount': double.parse(_amountController.text.trim()),
        'reason': _reasonController.text.trim(),
        'status': 'Pending',
        'date': date,
        'rejectionNote': '',
      });

      _amountController.clear();
      _reasonController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fund request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit request. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle_rounded;
      case 'Rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Request Funds',
          style: GoogleFonts.epilogue(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: defaultBlue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Form card (never grows, scrolls with keyboard) ──
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 0,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: defaultBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.request_quote_rounded,
                            color: defaultBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'New Fund Request',
                          style: GoogleFonts.epilogue(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Amount field
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.epilogue(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Amount (₹)',
                        labelStyle:
                            GoogleFonts.epilogue(color: Colors.grey[600], fontSize: 13),
                        prefixIcon:
                            const Icon(Icons.currency_rupee, color: defaultBlue, size: 20),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: defaultBlue, width: 2),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Please enter an amount';
                        if (double.tryParse(val.trim()) == null)
                          return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // Reason field
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      style: GoogleFonts.epilogue(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Reason for Request',
                        labelStyle:
                            GoogleFonts.epilogue(color: Colors.grey[600], fontSize: 13),
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.notes_rounded,
                              color: defaultBlue, size: 20),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: defaultBlue, width: 2),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Please enter a reason';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded,
                                color: Colors.white, size: 18),
                        label: Text(
                          _isSubmitting
                              ? 'Submitting...'
                              : 'Submit Request to Super Admin',
                          style: GoogleFonts.epilogue(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: defaultBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Request History Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.history_rounded,
                    color: Colors.black54, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Request History',
                  style: GoogleFonts.epilogue(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // ── Request History List (takes remaining space) ──
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
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
                        Icon(Icons.inbox_rounded,
                            size: 50, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text(
                          'No requests yet',
                          style:
                              GoogleFonts.epilogue(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'Pending';
                    final amount =
                        double.tryParse(data['amount'].toString()) ??
                            0.0;
                    final reason = data['reason'] ?? '';
                    final date = data['date'] ?? '';
                    final rejectionNote = data['rejectionNote'] ?? '';

                    String displayDate = '';
                    try {
                      displayDate = DateFormat('dd MMM yyyy, hh:mm a')
                          .format(DateTime.parse(date));
                    } catch (_) {
                      displayDate = date;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _statusColor(status).withOpacity(0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${amount.toStringAsFixed(0)}',
                                style: GoogleFonts.epilogue(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(status)
                                      .withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_statusIcon(status),
                                        color: _statusColor(status),
                                        size: 13),
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
                          const SizedBox(height: 5),
                          Text(
                            reason,
                            style: GoogleFonts.epilogue(
                                color: Colors.grey[700], fontSize: 13),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            displayDate,
                            style: GoogleFonts.epilogue(
                                color: Colors.grey[500], fontSize: 11),
                          ),
                          if (status == 'Rejected' &&
                              rejectionNote.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                      Icons.info_outline_rounded,
                                      color: Colors.red,
                                      size: 13),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Reason: $rejectionNote',
                                      style: GoogleFonts.epilogue(
                                        color: Colors.red.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
