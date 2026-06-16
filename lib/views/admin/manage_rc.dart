import 'package:driving_school/const.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:icons_plus/icons_plus.dart';

class ManageRC extends StatefulWidget {
  const ManageRC({super.key});

  @override
  State<ManageRC> createState() => _ManageRCState();
}

class _ManageRCState extends State<ManageRC> {
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserController>(context, listen: false).fetchRcRenewals();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: now.subtract(const Duration(days: 30)), 
        end: now
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: defaultBlue,
            colorScheme: ColorScheme.light(primary: defaultBlue),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
           // Background Elements
          Positioned(
              top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Image.asset('assets/Ellipse 36.png')]),

          // Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Custom Header
                SizedBox(
                  width: width,
                  height: height / 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(EvaIcons.arrow_ios_back_outline),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Manage RC Renewals',
                            style: GoogleFonts.epilogue(
                              fontSize: 18, // Slightly smaller to fit if actions exist
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // Actions
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.filter_alt_outlined, 
                              color: _selectedDateRange != null ? defaultBlue : Colors.black
                            ),
                            onPressed: () => _selectDateRange(context),
                            tooltip: 'Filter by Application Date',
                          ),
                          if (_selectedDateRange != null)
                             IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedDateRange = null;
                                });
                              },
                              tooltip: 'Clear Filter',
                            ),
                        ],
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: Consumer<UserController>(
                    builder: (context, controller, child) {
                      // Filter Logic
                      final filteredList = controller.rcRenewalList.where((rc) {
                        if (_selectedDateRange == null) return true;
                        try {
                          DateTime appDate = DateFormat("dd-MM-yyyy").parse(rc.applicationDate);
                          DateTime rangeStart = _selectedDateRange!.start.subtract(const Duration(seconds: 1));
                          DateTime rangeEnd = _selectedDateRange!.end.add(const Duration(days: 1)); 
                          return appDate.isAfter(rangeStart) && appDate.isBefore(rangeEnd);
                        } catch (e) {
                          print("Date parsing error for ${rc.applicationDate}: $e");
                          return true; 
                        }
                      }).toList();


                      if (filteredList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               const Icon(Icons.date_range, size: 50, color: Colors.grey),
                               const SizedBox(height: 10),
                               Text(
                                _selectedDateRange != null 
                                  ? 'No applications in selected range.' 
                                  : 'No RC Renewal Data Available',
                                style: GoogleFonts.epilogue(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20, top: 0),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final rcData = filteredList[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          rcData.userName,
                                          style: GoogleFonts.epilogue(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: rcData.status == 'Pending' ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          rcData.status,
                                          style: GoogleFonts.epilogue(
                                            color: rcData.status == 'Pending' ? Colors.orange : Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(thickness: 1, color: Colors.grey),
                                  const SizedBox(height: 5),
                                  _buildInfoRow(Icons.phone, 'Phone:', rcData.phoneNumber),
                                  const SizedBox(height: 5),
                                  _buildInfoRow(Icons.numbers, 'RC Number:', rcData.rcNumber),
                                  const SizedBox(height: 5),
                                  _buildInfoRow(Icons.calendar_today, 'Expiry Date:', rcData.expiryDate),
                                  const SizedBox(height: 5),
                                  _buildInfoRow(Icons.directions_car, 'Vehicle Class:', rcData.vehicleClass),
                                  const SizedBox(height: 5),
                                  _buildInfoRow(Icons.engineering, 'Engine No:', rcData.engineNumber),
                                  const SizedBox(height: 5),
                                  _buildInfoRow(Icons.confirmation_number, 'Chassis No:', rcData.chassisNumber),
                                  const SizedBox(height: 5),
                                  _buildInfoRow(Icons.payment, 'Amount:', '₹ ${rcData.amount}'),
                                  const SizedBox(height: 5),
                                  _buildInfoRow(Icons.date_range, 'Applied On:', rcData.applicationDate),
                                  
                                  const SizedBox(height: 15),
                                  
                                    if (rcData.idProofUrl.isNotEmpty)            
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () async {
                                          final Uri url = Uri.parse(rcData.idProofUrl);
                                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch Image URL')));
                                          }
                                        },
                                        icon: const Icon(Icons.image, color: Colors.white, size: 18),
                                        label: Text('View ID Proof', style: GoogleFonts.epilogue(color: Colors.white)),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    if (rcData.pollutionCertificateUrl.isNotEmpty)            
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () async {
                                          final Uri url = Uri.parse(rcData.pollutionCertificateUrl);
                                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch Image URL')));
                                          }
                                        },
                                        icon: const Icon(Icons.nature, color: Colors.white, size: 18),
                                        label: Text('View Pollution Cert.', style: GoogleFonts.epilogue(color: Colors.white)),
                                      ),
                                    ),
                                     const SizedBox(height: 10),
                                    
                                    // Action Button
                                    if (rcData.status == 'Pending')
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {
                                          _showConfirmationDialog(context, controller, rcData.id);
                                        },
                                         icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                        label: Text('Mark as Completed', style: GoogleFonts.epilogue(color: Colors.white)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.epilogue(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.epilogue(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context, UserController controller, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Action', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to mark this renewal as success/completed?', style: GoogleFonts.epilogue()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.epilogue(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: defaultBlue),
            onPressed: () {
              Navigator.pop(context);
              controller.updateRcRenewalStatus(docId, 'Success', context);
            },
            child: Text('Confirm', style: GoogleFonts.epilogue(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
