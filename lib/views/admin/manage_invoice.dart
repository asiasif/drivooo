import 'package:driving_school/controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:driving_school/services/pdf_invoice_service.dart';

class ManageInvoice extends StatefulWidget {
  const ManageInvoice({super.key});

  @override
  State<ManageInvoice> createState() => _ManageInvoiceState();
}

class _ManageInvoiceState extends State<ManageInvoice> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false).fetchAllInvoices();
    });
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
                        'Manage Invoice',
                        style: GoogleFonts.epilogue(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  width: width,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Invoice:',
                        style: GoogleFonts.epilogue(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      Consumer<AdminController>(
                        builder: (context, controller, child) {
                          return Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    controller.filterInvoicesByDate(picked);
                                  }
                                },
                                icon: Icon(
                                  Icons.filter_list_alt,
                                  color: controller.selectedInvoiceDate != null
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                              if (controller.selectedInvoiceDate != null)
                                IconButton(
                                  onPressed: () {
                                    controller.clearInvoiceFilter();
                                  },
                                  icon: const Icon(Icons.close, color: Colors.red),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Consumer<AdminController>(
                    builder: (context, controller, _) {
                  if (controller.selectedInvoiceDate != null) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Filtering by: ${DateFormat('dd MMM yyyy').format(controller.selectedInvoiceDate!)}",
                        style: GoogleFonts.epilogue(fontSize: 14, color: Colors.blue),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                Expanded(
                  child: Consumer<AdminController>(
                      builder: (context, adminInvoiceController, _) {
                    // Check if list is empty (and potentially loading if we had a flag, but for now assumption is empty list means no data or loading)
                    // Better approach: verify if invoiceList is empty too to differentiate "loading" vs "no results". 
                    // But standard approach here is sufficient.
                     return adminInvoiceController.filteredInvoiceList.isEmpty
                                      ? Center(
                                          child: Text(
                                            adminInvoiceController.selectedInvoiceDate != null 
                                            ? 'No Invoices Found for this Date'
                                            : 'No Invoices Data Found',
                                            style: GoogleFonts.epilogue(),
                                          ),
                                        )
                                      : ListView.separated(
                                          itemBuilder: (context, index) {
                                            final invoice = adminInvoiceController
                                                .filteredInvoiceList[index];
                                            return Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                child: ListTile(
                                                  onTap: () async {
                                                     await PdfInvoiceService.generate(invoice);
                                                  },
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
                                                                invoice.invoiceDate,
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
                                                              invoice.invoiceCourseName,
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
                                                  trailing: Image.asset(
                                                      'assets/invoice_tail.png'),
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(
                                                height: 10,
                                              ),
                                          itemCount: adminInvoiceController
                                              .filteredInvoiceList.length);
                        
                  }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
