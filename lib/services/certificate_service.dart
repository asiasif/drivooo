import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class CertificateService {
  static Future<void> generateCertificate({
    required String studentName,
    required String courseName,
    required String date,
  }) async {
    final pdf = pw.Document();

    // Load custom font if available, otherwise use standard
    // Load custom font if available, otherwise use standard
    // Switched to standard fonts to ensure offline reliability
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final fontCursive = pw.Font.helveticaOblique(); // Fallback for signature

    // Load logo or background if we have one. 
    // Using a simple professional layout for now.
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue800, width: 5),
              borderRadius: pw.BorderRadius.circular(20),
            ),
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('CERTIFICATE',
                    style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 40,
                        color: PdfColors.blue800,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('OF COMPLETION',
                    style: pw.TextStyle(
                        font: font,
                        fontSize: 20,
                        letterSpacing: 2,
                        color: PdfColors.grey700)),
                pw.SizedBox(height: 40),
                pw.Text('This is to certify that',
                    style: pw.TextStyle(font: font, fontSize: 18)),
                pw.SizedBox(height: 20),
                pw.Text(studentName,
                    style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 35,
                        color: PdfColors.black,
                        decoration: pw.TextDecoration.underline)),
                pw.SizedBox(height: 20),
                pw.Text('Has successfully completed the driving course:',
                    style: pw.TextStyle(font: font, fontSize: 18)),
                pw.SizedBox(height: 10),
                pw.Text(courseName,
                    style: pw.TextStyle(
                        font: fontBold, fontSize: 28, color: PdfColors.blue700)),
                pw.SizedBox(height: 40),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(date, style: pw.TextStyle(font: font, fontSize: 16)),
                        pw.Container(height: 1, width: 100, color: PdfColors.black),
                        pw.SizedBox(height: 5),
                        pw.Text('Date', style: pw.TextStyle(font: font, fontSize: 14)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('Doctor Driving',
                            style: pw.TextStyle(
                                font: fontCursive, fontSize: 24, color: PdfColors.blue900)),
                         pw.Container(height: 1, width: 150, color: PdfColors.black),
                        pw.SizedBox(height: 5),
                        pw.Text('Authorized Signature',
                            style: pw.TextStyle(font: font, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Certificate_$studentName.pdf',
    );
  }
}
