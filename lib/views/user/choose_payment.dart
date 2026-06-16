import 'package:driving_school/controller/payment_gateway.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/views/user/payment_successfull.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class ChoosePayment extends StatefulWidget {
  final double price;
  final String userName;
  final String courseName;
  final String invoiceDate;

  const ChoosePayment({
    required this.price,
    required this.userName,
    required this.courseName,
    required this.invoiceDate,
    super.key,
  });

  @override
  State<ChoosePayment> createState() => _ChoosePaymentState();
}

class _ChoosePaymentState extends State<ChoosePayment> {
  @override
  void initState() {
    Provider.of<PaymentGateway>(context, listen: false).getAllApps();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // final adminCourseController = Provider.of<UserController>(context);
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
                          builder: (context, paymentMode, userPaymentController,
                              child) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40.0),
                                child: paymentMode.displayUpiApps(
                                  '9747790366@ibl',
                                  'Fathimath Suhara',
                                  widget.price,
                                  context,
                                  () {
                                    userPaymentController
                                        .saveInvoice(
                                            widget.userName,
                                            widget.courseName,
                                            widget.invoiceDate,
                                            widget.price)
                                        .then(
                                          (value) => userPaymentController
                                              .updateCourse(widget.courseName),
                                        )
                                        .then(
                                      (value) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text(
                                                'Course purchased successfully'),
                                          ),
                                        );
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const PaymentSuccessful(),
                                          ),
                                        );
                                      },
                                    );
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
                // Expanded(
                //   child: ListView.separated(
                //       itemBuilder: (context, index) {
                //         return Card(
                //           child: Padding(
                //             padding: const EdgeInsets.symmetric(vertical: 10),
                //             child: ListTile(
                //               leading: Image.asset('assets/attendance.png'),
                //               title: SizedBox(
                //                 child: Row(
                //                   children: [
                //                     Text(
                //                       'Attendance Date:',
                //                       style: GoogleFonts.epilogue(
                //                           fontWeight: FontWeight.w500,
                //                           fontSize: 15),
                //                     ),
                //                     Expanded(
                //                       child: Text(
                //                         '10/02/2024',
                //                         overflow: TextOverflow.ellipsis,
                //                         style:
                //                             GoogleFonts.fraunces(fontSize: 15),
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           ),
                //         );
                //       },
                //       separatorBuilder: (context, index) => const SizedBox(
                //             height: 10,
                //           ),
                //       itemCount: 5),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
