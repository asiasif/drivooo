import 'package:driving_school/controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:driving_school/widgets/shimmer_loading.dart';

import 'package:driving_school/services/pdf_booking_service.dart';

import 'package:icons_plus/icons_plus.dart';

class ViewBookings extends StatefulWidget {
  const ViewBookings({super.key});

  @override
  State<ViewBookings> createState() => _ViewBookingsState();
}

class _ViewBookingsState extends State<ViewBookings> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false)
          .fetchBookings()
          .then((_) {
            if(mounted) {
              setState(() {
                isLoading = false;
              });
            }
          });
    });
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
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(EvaIcons.arrow_ios_back_outline),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'View Bookings',
                          style: GoogleFonts.epilogue(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Consumer<AdminController>(
                    builder: (context, controller, child) {
                      if (isLoading) {
                         return Expanded(
                           child: ListView.builder(
                             itemCount: 8,
                             itemBuilder: (context, index) => const ShimmerListTile(),
                           ),
                         );
                      }
                      
                      if (controller.bookingsList.isEmpty) {
                         return Expanded(
                           child: Center(
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.calendar_month_outlined, size: 100, color: Colors.grey.shade300),
                                 const SizedBox(height: 20),
                                 Text("No Bookings Yet", 
                                   style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                                 Text("It looks quiet here.", 
                                   style: GoogleFonts.epilogue(color: Colors.grey)),
                               ],
                             ),
                           ),
                         );
                      }
                       
                      final filteredList = controller.bookingsList.where((booking) {
                         return booking.userName.toLowerCase().contains(searchQuery);
                      }).toList();
            
                      return Expanded(
                        child: Column(
                          children: [
                             Padding(
                               padding: const EdgeInsets.only(bottom: 16.0),
                               child: TextField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    setState(() {
                                       searchQuery = value.toLowerCase();
                                    });
                                  },
                                  decoration: InputDecoration(
                                     hintText: "Search by User Name...",
                                     prefixIcon: const Icon(Icons.search),
                                     border: OutlineInputBorder(
                                       borderRadius: BorderRadius.circular(15),
                                       borderSide: BorderSide.none
                                     ),
                                     filled: true,
                                     fillColor: Colors.white.withOpacity(0.9),
                                     contentPadding: const EdgeInsets.symmetric(horizontal: 10)
                                  ),
                               ),
                             ),
                            Expanded(
                              child: filteredList.isEmpty 
                                  ?  Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                                          const SizedBox(height: 10),
                                          Text("No match found", style: GoogleFonts.epilogue(color: Colors.grey)),
                                        ],
                                      ),
                                    ) 
                                  : ListView.separated(
                                      itemCount: filteredList.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 15),
                                      padding: const EdgeInsets.only(bottom: 20),
                                      itemBuilder: (context, index) {
                                        final booking = filteredList[index];
                                        return Container(
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
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                            onTap: () async {
                                              // Generate and open PDF
                                              await PdfBookingService.generate(booking);
                                            },
                                            title: Text(booking.userName,
                                                style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16)),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                                    const SizedBox(width: 5),
                                                    Text(booking.date, style: GoogleFonts.epilogue(fontSize: 13)),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                 Row(
                                                  children: [
                                                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                                    const SizedBox(width: 5),
                                                    Text(booking.timeRange, style: GoogleFonts.epilogue(fontSize: 13)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            leading: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.bookmark, color: Colors.blue),
                                            ),
                                            trailing: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
