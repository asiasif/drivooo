
import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/services/pdf_retest_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:icons_plus/icons_plus.dart';

class TestManagement extends StatefulWidget {
  const TestManagement({super.key});

  @override
  State<TestManagement> createState() => _TestManagementState();
}

class _TestManagementState extends State<TestManagement> {
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false).fetchRetestApplications();
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                   // Custom Header
                  SizedBox(
                    width: width,
                    height: height / 8, // Adjusted height
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
                              'Test Management',
                              style: GoogleFonts.epilogue(
                                fontSize: 18, 
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
                              tooltip: 'Filter by Date',
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
                    child: Consumer<AdminController>(
                      builder: (context, controller, child) {
                        
                        final filteredList = controller.retestList.where((retest) {
                          if (_selectedDateRange == null) return true;
                          try {
                            DateTime? appDate;
                             try {
                              appDate = DateFormat("dd-MM-yyyy").parse(retest.date);
                            } catch (_) {
                               try {
                                appDate = DateFormat("yyyy-MM-dd").parse(retest.date);
                              } catch (__) {
                                 // Fallback or skip
                              }
                            }
                            
                            if (appDate == null) return true; // Show if date can't be parsed
              
                            // Extend end date to end of day
                            DateTime rangeStart = _selectedDateRange!.start.subtract(const Duration(seconds: 1));
                            DateTime rangeEnd = _selectedDateRange!.end.add(const Duration(days: 1)); 
              
                            return appDate.isAfter(rangeStart) && appDate.isBefore(rangeEnd);
                          } catch (e) {
                            return true; 
                          }
                        }).toList();
              
              
                        if (filteredList.isEmpty) {
                           return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                 const Icon(Icons.event_busy, size: 50, color: Colors.grey),
                                 const SizedBox(height: 10),
                                 Text(
                                  _selectedDateRange != null 
                                    ? 'No applications in selected range.' 
                                    : 'No retest applications found',
                                  style: GoogleFonts.epilogue(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: filteredList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 15),
                          padding: const EdgeInsets.only(bottom: 20),
                          itemBuilder: (context, index) {
                            final retest = filteredList[index];
                            return InkWell(
                              onTap: () async {
                                await PdfRetestService.generate(retest);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(retest.userName,
                                              style: GoogleFonts.epilogue(
                                                  fontWeight: FontWeight.bold, fontSize: 18)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text("₹${retest.amount}",
                                            style: GoogleFonts.epilogue(
                                                fontWeight: FontWeight.bold, color: Colors.green)),
                                          )
                                        ],
                                      ),
                                      const Divider(height: 20),
                                      _buildInfoRow(Icons.description, "Learners #:", retest.learnersNumber),
                                      const SizedBox(height: 5),
                                      _buildInfoRow(Icons.phone, "Phone:", retest.phoneNumber),
                                      const SizedBox(height: 5),
                                      _buildInfoRow(Icons.calendar_today, "Applied Date:", retest.date),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: _buildInfoRow(
                                              Icons.event_available, 
                                              "Test Date:", 
                                              retest.testDate.isEmpty ? 'Not Assigned' : retest.testDate,
                                              valueColor: retest.testDate.isEmpty ? Colors.red : Colors.green,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () async {
                                              final selectedDate = await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: ThemeData.light().copyWith(
                                                      primaryColor: defaultBlue,
                                                      colorScheme: ColorScheme.light(primary: defaultBlue),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );
                                              if (selectedDate != null) {
                                                String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                                                Provider.of<AdminController>(context, listen: false).assignTestDate(retest.id, formattedDate, context);
                                              }
                                            },
                                            icon: const Icon(Icons.edit_calendar, size: 16),
                                            label: Text(retest.testDate.isEmpty ? 'Assign' : 'Change', style: GoogleFonts.epilogue(fontSize: 12)),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text("Selected Tests:", style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 14)),
                                      const SizedBox(height: 5),
                                      Wrap(
                                        spacing: 8.0,
                                        runSpacing: 4.0,
                                        children: retest.selectedTests.map((test) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: defaultBlue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: defaultBlue.withOpacity(0.3))
                                          ),
                                          child: Text(test.toString(), style: GoogleFonts.epilogue(fontSize: 13, color: defaultBlue)),
                                        )).toList(),
                                      ),
                                       const SizedBox(height: 10),
                                       Align(
                                         alignment: Alignment.centerRight,
                                         child: Row(
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                             Icon(Icons.picture_as_pdf, color: Colors.red.withOpacity(0.8), size: 18),
                                             const SizedBox(width: 5),
                                             Text("Download PDF", style: GoogleFonts.epilogue(color: Colors.red.withOpacity(0.8), fontSize: 12)),
                                           ],
                                         ),
                                       )
                                    ],
                                  ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
         Icon(icon, size: 16, color: Colors.grey),
         const SizedBox(width: 8),
         Text(label, style: GoogleFonts.epilogue(color: Colors.grey)),
         const SizedBox(width: 5),
         Expanded(child: Text(value, style: GoogleFonts.epilogue(fontWeight: FontWeight.w500, color: valueColor))),
      ],
    );
  }
}
