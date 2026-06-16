import 'package:driving_school/const.dart';
import 'package:driving_school/controller/instructor_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class InstructorProfileScreen extends StatefulWidget {
  const InstructorProfileScreen({super.key});

  @override
  State<InstructorProfileScreen> createState() => _InstructorProfileScreenState();
}

class _InstructorProfileScreenState extends State<InstructorProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _upiController;

  @override
  void initState() {
    super.initState();
    final ctrl = Provider.of<InstructorController>(context, listen: false);
    _nameController = TextEditingController(text: ctrl.currentInstructor?.instructorName ?? '');
    _phoneController = TextEditingController(text: ctrl.currentInstructor?.instructorNumber.toString() ?? '');
    _upiController = TextEditingController(text: ctrl.currentInstructor?.upiId ?? '');
    _loadData();
  }

  Future<void> _loadData() async {
    final ctrl = Provider.of<InstructorController>(context, listen: false);
    await ctrl.fetchMyRatings();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Premium Blue header
          Container(
            height: 300,
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [defaultBlue, defaultBlue.withOpacity(0.85)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: defaultBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(EvaIcons.arrow_ios_back_outline, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'My Profile',
                        style: GoogleFonts.epilogue(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() => _isEditing = !_isEditing);
                        },
                        icon: Icon(
                          _isEditing ? Icons.close : Icons.edit_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Profile content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : Consumer<InstructorController>(
                          builder: (context, ctrl, _) {
                            final instructor = ctrl.currentInstructor;
                            if (instructor == null) {
                              return const Center(child: Text('No instructor data'));
                            }

                            return SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  // Avatar
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 54,
                                      backgroundColor: Colors.white,
                                      backgroundImage: instructor.instructorProPic != null
                                          ? NetworkImage(instructor.instructorProPic!)
                                          : const AssetImage('assets/instructor.jpg') as ImageProvider,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (!_isEditing) ...[
                                    Text(
                                      instructor.instructorName,
                                      style: GoogleFonts.epilogue(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      instructor.instructorEmail ?? '',
                                      style: GoogleFonts.epilogue(fontSize: 14, color: Colors.white70),
                                    ),
                                  ],
                                  const SizedBox(height: 24),

                                  // Info / Edit Card
                                  Container(
                                    width: width,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Colors.grey.shade100, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: _isEditing
                                        ? _buildEditForm(ctrl)
                                        : _buildInfoDisplay(instructor),
                                  ),
                                  const SizedBox(height: 24),

                                  // Rating Summary Card
                                  Container(
                                    width: width,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Colors.grey.shade100, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'My Reviews',
                                          style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 12),
                                        if (ctrl.myRatingsList.isEmpty)
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                children: [
                                                  Icon(Icons.star_border, size: 50, color: Colors.grey.shade300),
                                                  const SizedBox(height: 8),
                                                  Text('No reviews yet', style: GoogleFonts.epilogue(color: Colors.grey)),
                                                ],
                                              ),
                                            ),
                                          )
                                        else ...[
                                          // Average rating
                                          Row(
                                            children: [
                                              Text(
                                                ctrl.averageRating.toStringAsFixed(1),
                                                style: GoogleFonts.epilogue(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amber.shade700),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  RatingBarIndicator(
                                                    rating: ctrl.averageRating,
                                                    itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                                    itemCount: 5,
                                                    itemSize: 20,
                                                  ),
                                                  Text(
                                                    '${ctrl.myRatingsList.length} review${ctrl.myRatingsList.length == 1 ? '' : 's'}',
                                                    style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          const Divider(),
                                          // Reviews list
                                          ...ctrl.myRatingsList.map((review) => Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const CircleAvatar(
                                                      radius: 16,
                                                      backgroundColor: defaultBlue,
                                                      child: Icon(Icons.person, color: Colors.white, size: 18),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          RatingBarIndicator(
                                                            rating: review.score,
                                                            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                                            itemCount: 5,
                                                            itemSize: 14,
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            review.comment.isNotEmpty ? review.comment : 'No comment',
                                                            style: GoogleFonts.epilogue(fontSize: 13, color: Colors.grey.shade700),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
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

  Widget _buildInfoDisplay(instructor) {
    return Column(
      children: [
        _infoRow(Icons.person_outline, 'Name', instructor.instructorName),
        const Divider(height: 24),
        _infoRow(Icons.phone_outlined, 'Phone', instructor.instructorNumber.toString()),
        const Divider(height: 24),
        _infoRow(Icons.email_outlined, 'Email', instructor.instructorEmail ?? 'N/A'),
        const Divider(height: 24),
        _infoRow(
          Icons.account_balance_wallet_outlined,
          'UPI ID',
          (instructor.upiId != null && instructor.upiId!.isNotEmpty)
              ? instructor.upiId!
              : 'Not set',
          valueColor: (instructor.upiId != null && instructor.upiId!.isNotEmpty)
              ? Colors.green.shade700
              : Colors.grey,
        ),
        const Divider(height: 24),
        _infoRow(
          Icons.circle,
          'Status',
          instructor.status,
          valueColor: instructor.status == 'Available' ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: defaultBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: defaultBlue, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.epilogue(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(InstructorController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Edit Profile', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _upiController,
          decoration: InputDecoration(
            labelText: 'UPI ID (for salary payment)',
            hintText: 'e.g. yourname@okhdfcbank',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '💡 Your UPI ID will be used by Admin to pay your salary.',
            style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final phone = int.tryParse(_phoneController.text);
              if (_nameController.text.isEmpty || phone == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields correctly'), backgroundColor: Colors.red),
                );
                return;
              }
              await ctrl.updateMyProfile(
                name: _nameController.text.trim(),
                phoneNumber: phone,
                upiId: _upiController.text.trim().isNotEmpty ? _upiController.text.trim() : null,
                context: context,
              );
              setState(() => _isEditing = false);
            },
            child: Text('Save Changes', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
