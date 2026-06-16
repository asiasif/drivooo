import 'package:driving_school/models/booking_model.dart';
import 'package:driving_school/services/file_handle/file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfBookingService {
  static Future<void> generate(BookingModel booking) async {
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
                      pw.Text('BOOKING DETAILS',
                          style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: brandColor)),
                      pw.Text('Booking #${booking.bookingID.substring(0, 8)}',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Booking Info
               pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('USER DETAILS',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.SizedBox(height: 5),
                      pw.Text('Name: ${booking.userName}',
                          style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('User ID: ${booking.userID.substring(0, 8)}',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                   pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('SLOT DETAILS',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.SizedBox(height: 5),
                       pw.Text('Slot ID: ${booking.slotID}',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ]
               ),
              
              pw.SizedBox(height: 30),

              // Table
              pw.Table.fromTextArray(
                headers: ['Date', 'Time Slot', 'Type'],
                data: [
                  [
                    booking.date,
                    booking.timeRange,
                    'Driving Session\nBooking Time: ${booking.bookingTime ?? ''}' // Added time
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
                  2: pw.Alignment.centerLeft,
                },
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              pw.SizedBox(height: 10),

              pw.Spacer(),
              
              // Footer
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Driving School Booking Confirmation',
                        style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
                    pw.Text('This is a computer generated document.',
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

    await FileHandleApi.saveDocument(name: 'booking_${booking.bookingID}.pdf', bytes: await pdf.save());
  }
}
