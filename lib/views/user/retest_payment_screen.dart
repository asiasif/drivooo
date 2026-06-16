import 'package:driving_school/controller/payment_gateway.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/views/user/payment_successfull.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class RetestPaymentScreen extends StatefulWidget {
  final double amount;
  final String phone;
  final String learnersNumber;
  final List<String> selectedTests;

  const RetestPaymentScreen({
    required this.amount,
    required this.phone,
    required this.learnersNumber,
    required this.selectedTests,
    super.key,
  });

  @override
  State<RetestPaymentScreen> createState() => _RetestPaymentScreenState();
}

class _RetestPaymentScreenState extends State<RetestPaymentScreen> {
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
                    // crossAxisAlignment: CrossAxisAlignment.end,
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
                        'Payment',
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
                                    userController.applyForRetest(
                                        phone: widget.phone,
                                        learnersNumber: widget.learnersNumber,
                                        selectedTests: widget.selectedTests,
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
