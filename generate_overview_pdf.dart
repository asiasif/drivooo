import 'dart:io';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (pw.Context context) => [
        pw.Header(
          level: 0,
          child: pw.Text('DRIVO Project Overview', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 20),
        
        pw.Header(level: 1, child: pw.Text('1. Project Architecture & State Management', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
        pw.Bullet(text: 'Architecture: The project follows a clean MVC (Model-View-Controller) / Service-based architecture consisting of models, views, controller, and services.'),
        pw.Bullet(text: 'State Management: The app uses Provider for robust and scalable state management.'),
        pw.SizedBox(height: 20),

        pw.Header(level: 1, child: pw.Text('2. Core Modules (User Roles)', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
        pw.Bullet(text: 'Super Admin Module: Highest level of control. Oversees multiple branches, monitors analytics/revenue across branches, approves Admin fund requests, and handles cross-branch communication.'),
        pw.Bullet(text: 'Admin Module (Branch Admin): Manages a specific driving school branch. Key features include adding instructors/vehicles, approving student bookings, tracking expenses/fuel/maintenance, managing student skills, and requesting funds.'),
        pw.Bullet(text: 'Instructor Module: Dedicated to the driving teachers. Features include tracking allocated students, marking trip logs, managing their own attendance/leaves, and viewing their salary slips/reports.'),
        pw.Bullet(text: 'Student (User) Module: Dedicated to the learners. Includes course booking, scheduling time slots, learning theory (Mock tests), tracking practical skills progress, and raising queries/ratings.'),
        pw.SizedBox(height: 20),

        pw.Header(level: 1, child: pw.Text('3. Functional Sub-Modules', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
        pw.Bullet(text: 'Financial & Accounting Module: Handles Invoices, Instructor Salaries, Maintenance Receipts, Fuel Receipts, and internal Fund Transfers.'),
        pw.Bullet(text: 'Fleet Management Module: Manages vehicle assignments, RC renewals/expiries, and Trip Logs.'),
        pw.Bullet(text: 'Learning & Assessment Module: Contains Courses, Mock Tests, Questions, Retests, and Student Skill tracking.'),
        pw.Bullet(text: 'Scheduling Module: Manages automated Time Slots, Waitlists, Session Notes, and Bookings.'),
        pw.Bullet(text: 'Communication Module: Real-time Chat/Messages, Global Announcements, and Review/Rating systems.'),
        pw.SizedBox(height: 20),

        pw.Header(level: 1, child: pw.Text('4. Third-Party APIs & Core Packages Used', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
        pw.Text('Backend & Database APIs:'),
        pw.Bullet(text: 'Firebase Authentication: Used for secure user login, including OTP/Phone verification.'),
        pw.Bullet(text: 'Google Sign-In API: For quick OAuth-based user registration.'),
        pw.Bullet(text: 'Firebase Cloud Firestore: NoSQL database used for all CRUD operations and real-time data syncing.'),
        pw.Bullet(text: 'Firebase Cloud Messaging (FCM): For real-time push notifications across all user roles.'),
        pw.Bullet(text: 'Cloudinary API: Used to upload and serve images securely.'),
        pw.SizedBox(height: 10),
        
        pw.Text('Specialized Services & APIs:'),
        pw.Bullet(text: 'Google ML Kit Text Recognition API: Machine learning OCR integration used for the Document Scanner Service.'),
        pw.Bullet(text: 'UPI Payment Gateway integration: Used to launch UPI apps securely for seamless fee payments.'),
        pw.SizedBox(height: 10),

        pw.Text('Utility & UI Packages:'),
        pw.Bullet(text: 'PDF Generation & Printing: Dynamically generates PDF documents (Invoices, Salary slips, etc.).'),
        pw.Bullet(text: 'Data Visualization: Used to build dynamic Pie Charts and Graphs.'),
        pw.Bullet(text: 'Calendar & Scheduling: Interactive UI for booking course dates and tracking time slots.'),
        pw.Bullet(text: 'UI/UX Enhancements: Loading/shimmer effects, animations, and modern input interfaces.'),
        pw.SizedBox(height: 20),

        pw.Header(level: 1, child: pw.Text('Viva Key Talking Points', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
        pw.Bullet(text: 'Payments: We use a custom UPI gateway integration via the upi_india package, hooking directly into any installed UPI app securely.'),
        pw.Bullet(text: 'Reports: The app uses the pdf package to dynamically render Flutter widgets into PDF byte streams, which are then shared or saved locally.'),
        pw.Bullet(text: 'Advanced Features: We integrated Google ML Kit for Text Recognition, allowing the app to scan physical documents to extract information computationally.'),
      ],
    ),
  );

  final file = File('C:/Users/USER/Desktop/DRIVO_Project_Overview.pdf');
  await file.writeAsBytes(await pdf.save());
  print('PDF generated successfully at \${file.absolute.path}');
}
