import 'package:driving_school/models/invoice_model.dart';
import 'package:driving_school/services/file_handle/file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfInvoiceService {
  static Future<void> generate(InvoiceModel invoice) async {
    final pdf = pw.Document();

    final PdfColor brandColor = PdfColor.fromInt(0xFF1E88E5); // Blue color

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Driving School',
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Professional Driving Education',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE',
                          style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: brandColor)),
                      pw.Text('#${invoice.invoiceID}',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Billing Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL FROM',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.SizedBox(height: 5),
                      pw.Text('Driving School', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('123 Driving Street', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Kerala, India', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('contact@drivingschool.com',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Phone: +91 9876543210',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL TO',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.SizedBox(height: 5),
                      pw.Text(invoice.invoiceUserName,
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 10),
                      pw.Text('Invoice Date: ${invoice.invoiceDate}',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Due Date: ${invoice.dueDate}',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Table
              pw.Table.fromTextArray(
                headers: ['Course', 'AMOUNT'],
                data: [
                  [
                    invoice.invoiceCourseName,
                    '${invoice.invoicePrice.toStringAsFixed(2)}'
                  ],
                ],
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                },
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              pw.SizedBox(height: 10),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(children: [
                        pw.Text('Total Amount: ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        pw.Text('${invoice.invoicePrice.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                                color: brandColor)),
                      ]),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(5),
                        color: PdfColors.grey100,
                        child: pw.Text('Payment Terms: Due upon receipt',
                            style: pw.TextStyle(
                                fontStyle: pw.FontStyle.italic, fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Thank you for your business!',
                        style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
                    pw.Text('For any queries, contact: support@drivingschool.com',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  ]),
                 pw.Text('Generated on ${DateTime.now().toString().split(' ')[0]}',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ]
              ),
            ],
          );
        },
      ),
    );

    await FileHandleApi.saveDocument(name: 'invoice_${invoice.invoiceID}.pdf', bytes: await pdf.save());
  }
}
