import 'package:driving_school/controller/payment_gateway.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/views/user/payment_successfull.dart';
import 'package:driving_school/views/user/retest_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class ApplyRetest extends StatefulWidget {
  const ApplyRetest({super.key});

  @override
  State<ApplyRetest> createState() => _ApplyRetestState();
}

class _ApplyRetestState extends State<ApplyRetest> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _learnersController = TextEditingController();

  bool _isHSelected = false;
  bool _is8Selected = false;
  bool _isLmvRoadSelected = false;
  bool _isBikeRoadSelected = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset('assets/Ellipse 2.png'),
          ),
          Positioned(
            top: 100,
            left: 0,
            child: Image.asset('assets/Ellipse 36.png'),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Custom Header
                  SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(EvaIcons.arrow_ios_back_outline),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Apply for Retest',
                          style: GoogleFonts.epilogue(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            // Logo
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/retest_logo.jpg',
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            Text(
                              'Select Tests:',
                              style: GoogleFonts.epilogue(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Checkboxes as Cards
                            _buildTestOption('H Test', _isHSelected,
                                (val) => setState(() => _isHSelected = val!)),
                            _buildTestOption('8 Test', _is8Selected,
                                (val) => setState(() => _is8Selected = val!)),
                            _buildTestOption('LMV Road Test', _isLmvRoadSelected,
                                (val) => setState(() => _isLmvRoadSelected = val!)),
                            _buildTestOption('Bike Road Test', _isBikeRoadSelected,
                                (val) => setState(() => _isBikeRoadSelected = val!)),

                            const SizedBox(height: 25),

                            // Phone Field
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: const Icon(Icons.phone_android_outlined, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter phone number';
                                } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                  return 'Phone number must be 10 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // Learners Field
                            TextFormField(
                              controller: _learnersController,
                              decoration: InputDecoration(
                                labelText: 'Learners License Number',
                                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter learners number';
                                } else if (!RegExp(r'^[a-zA-Z0-9]{12}$')
                                    .hasMatch(value)) {
                                  return 'Must be 12 alphanumeric characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 30),

                            // Pay Button
                            SizedBox(
                              width: width,
                              height: 55,
                              child: Consumer<PaymentGateway>(
                                builder: (context, paymentMode, child) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        if (!_isHSelected &&
                                            !_is8Selected &&
                                            !_isLmvRoadSelected &&
                                            !_isBikeRoadSelected) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Please select at least one test')),
                                          );
                                          return;
                                        }

                                        // Calculate Amount
                                        double amount = 0;
                                        if (_isHSelected) amount += 500;
                                        if (_is8Selected) amount += 500;
                                        if (_isLmvRoadSelected) amount += 500;
                                        if (_isBikeRoadSelected) amount += 500;

                                        List<String> selectedTests = [];
                                        if (_isHSelected)
                                          selectedTests.add('H');
                                        if (_is8Selected)
                                          selectedTests.add('8');
                                        if (_isLmvRoadSelected)
                                          selectedTests.add('LMV Road');
                                        if (_isBikeRoadSelected)
                                          selectedTests.add('Bike Road');

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RetestPaymentScreen(
                                              amount: amount,
                                              phone: _phoneController.text,
                                              learnersNumber:
                                                  _learnersController.text,
                                              selectedTests: selectedTests,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Pay & Submit',
                                      style: GoogleFonts.epilogue(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
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

  Widget _buildTestOption(String title, bool value, Function(bool?) onChanged) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: CheckboxListTile(
        activeColor: Colors.black,
        title: Text(
          title, 
          style: GoogleFonts.fraunces(
            fontSize: 15,
            fontWeight: FontWeight.w500
          )
        ),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        dense: true,
      ),
    );
  }
}
