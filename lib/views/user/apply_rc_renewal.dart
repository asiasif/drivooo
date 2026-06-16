import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/views/user/rc_renewal_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ApplyRcRenewal extends StatefulWidget {
  const ApplyRcRenewal({super.key});

  @override
  State<ApplyRcRenewal> createState() => _ApplyRcRenewalState();
}

class _ApplyRcRenewalState extends State<ApplyRcRenewal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rcNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _engineNumberController = TextEditingController(); // Added
  final TextEditingController _chassisNumberController = TextEditingController(); // Added
  
  String? _selectedVehicleClass;
  XFile? _selectedIdProof;
  XFile? _selectedPollutionCertificate; // Added
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isIdProof) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isIdProof) {
          _selectedIdProof = image;
        } else {
          _selectedPollutionCertificate = image;
        }
      });
    }
  }

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
                          'Apply for RC Renewal',
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
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Vehicle Details',
                              style: GoogleFonts.epilogue(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Name Field
                            _buildTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 15),

                            // Phone Field
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone_android_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Phone Number';
                                }
                                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return 'Phone number must contain only digits';
                                }
                                if (value.length != 10) {
                                  return 'Phone number must be exactly 10 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // RC Number Field
                            _buildTextField(
                              controller: _rcNumberController,
                              label: 'RC Number',
                              icon: Icons.numbers,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter RC Number';
                                }
                                if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                                  return 'Must be alphanumeric (letters & numbers only)';
                                }
                                if (value.length != 10) {
                                  return 'Must be exactly 10 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // Expiry Date Field
                            _buildTextField(
                              controller: _expiryDateController,
                              label: 'RC Expiry Date',
                              icon: Icons.calendar_today_outlined,
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                   String formattedDate = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                   setState(() {
                                     _expiryDateController.text = formattedDate;
                                   });
                                }
                              },
                            ),
                            const SizedBox(height: 15),

                            // Engine Number Field
                            _buildTextField(
                              controller: _engineNumberController,
                              label: 'Engine Number',
                              icon: Icons.engineering,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Engine Number';
                                }
                                if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                                  return 'Must be alphanumeric (letters & numbers only)';
                                }
                                if (value.length != 10) {
                                  return 'Must be exactly 10 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // Chassis Number Field
                            _buildTextField(
                              controller: _chassisNumberController,
                              label: 'Chassis Number',
                              icon: Icons.directions_car_filled_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Chassis Number';
                                }
                                if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                                  return 'Must be alphanumeric (letters & numbers only)';
                                }
                                if (value.length != 10) {
                                  return 'Must be exactly 10 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // Vehicle Class Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedVehicleClass,
                                  hint: Row(
                                    children: [
                                      const Icon(Icons.directions_car_outlined, size: 20, color: Colors.grey),
                                      const SizedBox(width: 12),
                                      Text('Select Vehicle Class', style: GoogleFonts.epilogue(color: Colors.grey.shade600, fontSize: 16)),
                                    ],
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                                  isExpanded: true,
                                  items: ['LMV', 'Bike'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value, style: GoogleFonts.epilogue(fontSize: 16)),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedVehicleClass = newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ID Proof Upload
                            Text(
                              'Identity Proof',
                              style: GoogleFonts.epilogue(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            GestureDetector(
                                onTap: () => _pickImage(true), // Update to use boolean flag
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey.shade300, width: 1),
                                    image: _selectedIdProof != null 
                                      ? DecorationImage(
                                          image: kIsWeb 
                                              ? NetworkImage(_selectedIdProof!.path) 
                                              : FileImage(File(_selectedIdProof!.path)) as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  ),
                                  child: _selectedIdProof == null
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue.shade300),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Tap to upload ID Proof',
                                              style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 14),
                                            ),
                                          ],
                                        )
                                      : Stack(
                                        children: [
                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                                            ),
                                          )
                                        ],
                                      ),
                                ),
                              ),

                              const SizedBox(height: 20),

                             // Pollution Certificate Upload
                            Text(
                              'Pollution Certificate',
                              style: GoogleFonts.epilogue(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            GestureDetector(
                                onTap: () => _pickImage(false), // Pass false for Pollution Certificate
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey.shade300, width: 1),
                                    image: _selectedPollutionCertificate != null 
                                      ? DecorationImage(
                                          image: kIsWeb 
                                              ? NetworkImage(_selectedPollutionCertificate!.path) 
                                              : FileImage(File(_selectedPollutionCertificate!.path)) as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  ),
                                  child: _selectedPollutionCertificate == null
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.green.shade300),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Tap to upload Pollution Certificate',
                                              style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 14),
                                            ),
                                          ],
                                        )
                                      : Stack(
                                        children: [
                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.edit, size: 16, color: Colors.green),
                                            ),
                                          )
                                        ],
                                      ),
                                ),
                              ),


                            const SizedBox(height: 30),

                            // Submit Button
                            SizedBox(
                              width: width,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    if (_selectedVehicleClass == null) {
                                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select vehicle class')));
                                       return;
                                    }
                                    if (_selectedIdProof == null) {
                                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload ID proof')));
                                       return;
                                    }

                                    if (_selectedPollutionCertificate == null) {
                                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload Pollution Certificate')));
                                       return;
                                    }

                                    // Proceed to Payment
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => RCRenewalPaymentScreen(
                                          amount: 500.0, // Fixed amount for now as per logic
                                          name: _nameController.text,
                                          phone: _phoneController.text,
                                          rcNumber: _rcNumberController.text,
                                          expiryDate: _expiryDateController.text,
                                          vehicleClass: _selectedVehicleClass!,
                                          idProofImage: _selectedIdProof,
                                          engineNumber: _engineNumberController.text, // Added
                                          chassisNumber: _chassisNumberController.text, // Added
                                          pollutionCertificate: _selectedPollutionCertificate, // Added
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  'Proceed to Pay  ₹ 500',
                                  style: GoogleFonts.epilogue(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: GoogleFonts.epilogue(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.epilogue(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        return null;
      },
    );
  }
}
