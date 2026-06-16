import 'package:driving_school/models/salary_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SalaryPdfService {
  static Future<void> generateAndShowSlip(SalaryModel salary) async {
    final pdf = pw.Document();

    final paidDate = salary.paidAt != null
        ? DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.parse(salary.paidAt!))
        : 'N/A';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
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
                      pw.Text('DOCTOR DRIVING SCHOOL',
                          style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800)),
                      pw.SizedBox(height: 4),
                      pw.Text('Instructor Salary Payment Slip',
                          style: pw.TextStyle(
                              fontSize: 14, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green100,
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Text('PAID',
                        style: pw.TextStyle(
                            color: PdfColors.green800,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14)),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Details Card
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(12),
                  color: PdfColors.grey50,
                ),
                child: pw.Column(
                  children: [
                    _buildRow('Instructor Name:', salary.instructorName),
                    pw.Divider(color: PdfColors.grey300),
                    _buildRow('Instructor ID:', salary.instructorId),
                    pw.Divider(color: PdfColors.grey300),
                    _buildRow('UPI ID:', salary.instructorUpiId.isEmpty ? 'N/A' : salary.instructorUpiId),
                    pw.Divider(color: PdfColors.grey300),
                    _buildRow('Payment For:', salary.monthYear),
                    pw.Divider(color: PdfColors.grey300),
                    _buildRow('Payment Date:', paidDate),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Amount
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total Paid:',
                      style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
                  pw.SizedBox(width: 16),
                  pw.Text('Rs. ${salary.amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800)),
                ],
              ),
              pw.SizedBox(height: 50),

              // Footer
              pw.Text('Note: This is a computer-generated salary slip and does not require a physical signature.',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Salary_Slip_${salary.instructorName.replaceAll(" ", "_")}_${salary.monthYear.replaceAll(" ", "_")}',
    );
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: PdfColors.grey800, fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
