import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school/const.dart';
import 'package:driving_school/models/instructor_model.dart';
import 'package:driving_school/models/salary_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
class AdminSalaryScreen extends StatefulWidget {
  final bool isReadOnly;
  const AdminSalaryScreen({super.key, this.isReadOnly = false});

  @override
  State<AdminSalaryScreen> createState() => _AdminSalaryScreenState();
}

class _AdminSalaryScreenState extends State<AdminSalaryScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<InstructorModel> _instructors = [];

  @override
  void initState() {
    super.initState();
    _fetchInstructors();
  }

  Future<void> _fetchInstructors() async {
    try {
      final snap = await _db.collection('instructors').get();
      setState(() {
        _instructors = snap.docs.map((doc) {
          final data = doc.data();
          data['instructorID'] = doc.id;
          return InstructorModel.fromMap(data);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Stream<List<SalaryModel>> _salaryStream(String instructorId) {
    return _db
        .collection('salaries')
        .where('instructorId', isEqualTo: instructorId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SalaryModel.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) => b.monthYear.compareTo(a.monthYear)));
  }

  void _showPayDialog(InstructorModel instructor, {bool isExtra = false}) {
    final amountController = TextEditingController(text: isExtra ? '' : '15000');
    final now = DateTime.now();
    final currentMonth = DateFormat('MMMM yyyy').format(now);
    final monthYearStr = isExtra ? 'Extra Classes - $currentMonth' : currentMonth;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isExtra ? 'Pay Extra Classes' : 'Pay Monthly Salary', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogInfoRow(Icons.person, 'Instructor', instructor.instructorName),
            const SizedBox(height: 8),
            _dialogInfoRow(
              Icons.account_balance_wallet_outlined,
              'UPI ID',
              (instructor.upiId != null && instructor.upiId!.isNotEmpty)
                  ? instructor.upiId!
                  : '⚠️ Not set by instructor',
              valueColor: (instructor.upiId != null && instructor.upiId!.isNotEmpty)
                  ? Colors.green.shade700
                  : Colors.orange,
            ),
            const SizedBox(height: 8),
            _dialogInfoRow(isExtra ? Icons.more_time : Icons.calendar_month, 'For', monthYearStr),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isExtra ? 'Extra Amount (₹)' : 'Salary Amount (₹)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.epilogue(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: defaultBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            label: Text('Pay Now', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid amount'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx);
              _runDemoPayment(instructor, amount, monthYearStr);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _runDemoPayment(InstructorModel instructor, double amount, String monthYear) async {
    // Show processing overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentProcessingDialog(
        instructorName: instructor.instructorName,
        upiId: instructor.upiId ?? 'N/A',
        amount: amount,
      ),
    );

    // Simulate 3-second processing
    await Future.delayed(const Duration(seconds: 3));

    // Save to Firestore
    try {
      final docRef = _db.collection('salaries').doc();
      final salary = SalaryModel(
        id: docRef.id,
        instructorId: instructor.instructorID,
        instructorName: instructor.instructorName,
        instructorUpiId: instructor.upiId ?? '',
        amount: amount,
        monthYear: monthYear,
        status: 'Paid',
        paidAt: DateTime.now().toIso8601String(),
      );
      await docRef.set(salary.toMap());
    } catch (_) {}

    if (mounted) Navigator.pop(context); // Close processing dialog

    // Show success
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => _PaymentSuccessDialog(
          instructorName: instructor.instructorName,
          amount: amount,
          monthYear: monthYear,
        ),
      );
    }
  }

  Widget _dialogInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: defaultBlue),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.epilogue(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(color: Colors.grey)),
                TextSpan(
                  text: value,
                  style: TextStyle(fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header gradient
          Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [defaultBlue, defaultBlue.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(color: defaultBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(EvaIcons.arrow_ios_back_outline, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Salary Management',
                        style: GoogleFonts.epilogue(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Pay and track instructor salaries via UPI',
                    style: GoogleFonts.epilogue(fontSize: 13, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 24),
                // Instructor list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _instructors.isEmpty
                          ? Center(
                              child: Text('No instructors found.',
                                  style: GoogleFonts.epilogue(color: Colors.grey)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              itemCount: _instructors.length,
                              itemBuilder: (context, i) {
                                return _buildInstructorCard(_instructors[i]);
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

  Widget _buildInstructorCard(InstructorModel instructor) {
    return StreamBuilder<List<SalaryModel>>(
      stream: _salaryStream(instructor.instructorID),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];
        final currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
        final isPaidThisMonth = records.any((r) => r.monthYear == currentMonth && r.status == 'Paid');

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: defaultBlue.withOpacity(0.1),
                backgroundImage: instructor.instructorProPic != null
                    ? NetworkImage(instructor.instructorProPic!)
                    : const AssetImage('assets/instructor.jpg') as ImageProvider,
              ),
              title: Text(
                instructor.instructorName,
                style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 13,
                          color: (instructor.upiId != null && instructor.upiId!.isNotEmpty)
                              ? Colors.green
                              : Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (instructor.upiId != null && instructor.upiId!.isNotEmpty)
                              ? instructor.upiId!
                              : 'UPI ID not set',
                          style: GoogleFonts.epilogue(
                            fontSize: 12,
                            color: (instructor.upiId != null && instructor.upiId!.isNotEmpty)
                                ? Colors.green.shade700
                                : Colors.orange,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPaidThisMonth)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text('Paid ✅', style: GoogleFonts.epilogue(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  else if (widget.isReadOnly)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text('Pending ❌', style: GoogleFonts.epilogue(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: defaultBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () => _showPayDialog(instructor, isExtra: false),
                      child: Text('Pay', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  if (!widget.isReadOnly) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade50,
                        foregroundColor: Colors.orange.shade800,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.orange.shade200),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _showPayDialog(instructor, isExtra: true),
                      child: Text('Extra', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ],
              ),
              // Salary history
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (records.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('No salary records yet.',
                        style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 13)),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      Text('Payment History',
                          style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...records.map((r) => _buildHistoryRow(r)),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryRow(SalaryModel r) {
    final isPaid = r.status == 'Paid';
    final paidDate = r.paidAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(r.paidAt!))
        : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid ? Colors.green.shade100 : Colors.orange.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(isPaid ? Icons.check_circle : Icons.pending,
              color: isPaid ? Colors.green : Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.monthYear,
                    style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 13)),
                if (paidDate.isNotEmpty)
                  Text(paidDate,
                      style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            '₹${r.amount.toStringAsFixed(0)}',
            style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 15,
                color: isPaid ? Colors.green.shade700 : Colors.orange),
          ),
        ],
      ),
    );
  }
}

// ─── Demo Processing Dialog ───────────────────────────────────────────────────

class _PaymentProcessingDialog extends StatefulWidget {
  final String instructorName;
  final String upiId;
  final double amount;

  const _PaymentProcessingDialog({
    required this.instructorName,
    required this.upiId,
    required this.amount,
  });

  @override
  State<_PaymentProcessingDialog> createState() => _PaymentProcessingDialogState();
}

class _PaymentProcessingDialogState extends State<_PaymentProcessingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _step = 0;
  final List<String> _steps = [
    'Connecting to UPI Network...',
    'Verifying UPI ID...',
    'Initiating Transfer...',
    'Processing Payment...',
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (_step < _steps.length - 1) {
        setState(() => _step++);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Google Pay-style logo area
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.currency_rupee, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            Text('Processing UPI Payment',
                style: GoogleFonts.epilogue(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              '₹${widget.amount.toStringAsFixed(0)} → ${widget.upiId}',
              style: GoogleFonts.epilogue(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Animated steps
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _steps[_step],
                key: ValueKey(_step),
                style: GoogleFonts.epilogue(fontSize: 13, color: defaultBlue, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFE8F0FE),
              color: defaultBlue,
              minHeight: 5,
            ),
            const SizedBox(height: 8),
            Text('Please do not close the app',
                style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ─── Success Dialog ───────────────────────────────────────────────────────────

class _PaymentSuccessDialog extends StatelessWidget {
  final String instructorName;
  final double amount;
  final String monthYear;

  const _PaymentSuccessDialog({
    required this.instructorName,
    required this.amount,
    required this.monthYear,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade200, width: 2),
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Payment Successful!',
                style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
            const SizedBox(height: 8),
            Text(
              '₹${amount.toStringAsFixed(0)} has been sent to $instructorName\nfor $monthYear salary.',
              style: GoogleFonts.epilogue(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Record saved in Salary History ✓',
                style: GoogleFonts.epilogue(fontSize: 12, color: Colors.green.shade700),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Done', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
