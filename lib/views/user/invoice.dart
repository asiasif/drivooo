import 'package:driving_school/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:driving_school/services/pdf_invoice_service.dart';
import 'package:provider/provider.dart';

class Invoice extends StatelessWidget {
  const Invoice({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // final userInvoiceController = Provider.of<UserController>(context);
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
                        'Invoice',
                        style: GoogleFonts.epilogue(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  width: width,
                  height: 50,
                  child: Text(
                    'Download Invoice:',
                    style: GoogleFonts.epilogue(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Consumer<UserController>(
                    builder: (context, userInvoiceController, _) {
                      return FutureBuilder(
                        future: userInvoiceController.fetchInvoices(),
                        builder: (context, snapshot) {
                          return snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : snapshot.hasError
                                  ? Center(
                                      child: Text(
                                        snapshot.error.toString(),
                                      ),
                                    )
                                  : userInvoiceController.invoiceList.isEmpty
                                      ? const Center(
                                          child: Text('No Invoices Found'),
                                        )
                                      : ListView.separated(
                                          itemBuilder: (context, index) {
                                            return Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                child: ListTile(
                                                  leading: Image.asset(
                                                      'assets/invoice_lead.png'),
                                                  title: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Payment Date:',
                                                              style: GoogleFonts
                                                                  .epilogue(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                userInvoiceController
                                                                    .invoiceList[
                                                                        index]
                                                                    .invoiceDate,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: GoogleFonts
                                                                    .fraunces(
                                                                        fontSize:
                                                                            15),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Course:',
                                                            style: GoogleFonts
                                                                .epilogue(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        15),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              userInvoiceController
                                                                  .invoiceList[
                                                                      index]
                                                                  .invoiceCourseName,
                                                              style: GoogleFonts
                                                                  .epilogue(
                                                                      fontSize:
                                                                          15),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: InkWell(
                                                    onTap: () async {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Generating PDF...')),
                                                      );
                                                      try {
                                                        final invoice = userInvoiceController.invoiceList[index];
                                                        await PdfInvoiceService.generate(invoice);
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Error generating PDF: $e')),
                                                        );
                                                      }
                                                    },
                                                    child: Image.asset(
                                                        'assets/invoice_tail.png'),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(
                                                height: 10,
                                              ),
                                          itemCount: userInvoiceController
                                              .invoiceList.length);
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
