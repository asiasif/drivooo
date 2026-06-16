import 'package:image_picker/image_picker.dart';

import 'package:driving_school/controller/payment_gateway.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class RCRenewalPaymentScreen extends StatefulWidget {
  final double amount;
  final String name;
  final String phone;
  final String rcNumber;
  final String expiryDate;
  final String vehicleClass;
  final XFile? idProofImage;
  final String engineNumber;
  final String chassisNumber;
  final XFile? pollutionCertificate;

  const RCRenewalPaymentScreen({
    super.key,
    required this.amount,
    required this.name,
    required this.phone,
    required this.rcNumber,
    required this.expiryDate,
    required this.vehicleClass,
    required this.idProofImage,
    required this.engineNumber,
    required this.chassisNumber,
    required this.pollutionCertificate,
  });

  @override
  State<RCRenewalPaymentScreen> createState() => _RCRenewalPaymentScreenState();
}

class _RCRenewalPaymentScreenState extends State<RCRenewalPaymentScreen> {
  @override
  void initState() {
    Provider.of<PaymentGateway>(context, listen: false).getAllApps();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          ////////////////////////////////////////////////////////
          Positioned(
              top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Image.asset('assets/Ellipse 36.png')]),
          ///////////////////////////////////////////////////
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: width,
                  height: height / 6,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(EvaIcons.arrow_ios_back_outline),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Confirm Payment',
                        style: GoogleFonts.epilogue(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                         Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text("Total Amount", style: GoogleFonts.epilogue(fontSize: 14, color: Colors.grey)),
                                const SizedBox(height: 5),
                                Text(
                                  "₹ ${widget.amount}", 
                                  style: GoogleFonts.epilogue(fontSize: 28, fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 10),
                                const Divider(),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Service:", style: GoogleFonts.epilogue(fontWeight: FontWeight.w500)),
                                    Text("RC Renewal", style: GoogleFonts.epilogue()),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Vehicle Class:", style: GoogleFonts.epilogue(fontWeight: FontWeight.w500)),
                                    Text(widget.vehicleClass, style: GoogleFonts.epilogue()),
                                  ],
                                ),
                                
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        Consumer2<PaymentGateway, UserController>(
                          builder: (context, paymentMode, userController, child) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: paymentMode.displayUpiApps(
                                  '9747790366@ibl',
                                  'Fathimath Suhara',
                                  widget.amount,
                                  context,
                                  () {
                                    userController.applyForRcRenewal(
                                        name: widget.name,
                                        phone: widget.phone,
                                        rcNumber: widget.rcNumber,
                                        expiryDate: widget.expiryDate,
                                        vehicleClass: widget.vehicleClass,
                                        idProofImage: widget.idProofImage,
                                        engineNumber: widget.engineNumber,
                                        chassisNumber: widget.chassisNumber,
                                        pollutionCertificate: widget.pollutionCertificate,
                                        amount: widget.amount,
                                        context: context);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
