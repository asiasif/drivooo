import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/models/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SlotBooking extends StatefulWidget {
  const SlotBooking({super.key});

  @override
  State<SlotBooking> createState() => _SlotBookingState();
}

class _SlotBookingState extends State<SlotBooking> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false).fetchTimeSlots();
      Provider.of<UserController>(context, listen: false).fetchBookedSlots(
          DateFormat('yyyy-MM-dd').format(selectedDate));
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Image.asset('assets/Ellipse 36.png')]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width,
                  height: height / 6,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(EvaIcons.arrow_ios_back_outline),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Slot Booking',
                        style: GoogleFonts.epilogue(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/slot_booking.jpg',
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),
                // Date Picker
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                      // Fetch blocked slots for new date
                      Provider.of<UserController>(context, listen: false)
                          .fetchBookedSlots(
                              DateFormat('yyyy-MM-dd').format(selectedDate));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selected Date",
                              style: GoogleFonts.epilogue(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEE, dd MMM yyyy').format(selectedDate),
                              style: GoogleFonts.epilogue(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.calendar_month_outlined, color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Available Slots",
                  style: GoogleFonts.epilogue(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 15),
                Consumer<UserController>(
                  builder: (context, userCtrl, _) {
                    if (userCtrl.myBookingId != null) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check_circle_outline, color: Colors.green.shade800, size: 20),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Booking Confirmed",
                                    style: GoogleFonts.epilogue(
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "You have a slot for today.",
                                    style: GoogleFonts.epilogue(
                                        color: Colors.green.shade700,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _showCancelDialog(context, userCtrl);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.epilogue(
                                  color: Colors.red.shade400,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Expanded(
                  child: Consumer2<AdminController, UserController>(
                    builder: (context, adminCtrl, userCtrl, _) {
                      if (adminCtrl.timeSlotsList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy, size: 50, color: Colors.grey.shade300),
                              const SizedBox(height: 10),
                              Text("No slots available", style: GoogleFonts.epilogue(color: Colors.grey)),
                            ],
                          ),
                        );
                      }
                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.4, // Make cards taller for better layout
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: adminCtrl.timeSlotsList.length,
                        itemBuilder: (context, index) {
                          final slot = adminCtrl.timeSlotsList[index];
                          final isFull = (userCtrl.slotBookingCounts[slot.slotID] ?? 0) >= 2;
                          final isMySlot = userCtrl.myBookedSlotId == slot.slotID;
                          final hasBooking = userCtrl.myBookingId != null;
                          final isWaitlisted = userCtrl.myWaitlistStatus[slot.slotID] == true;

                          // Check if slot is in the past or within cutoff
                          bool isPast = false;
                          String? timeRemaining;
                          
                          if (DateFormat('yyyy-MM-dd').format(selectedDate) ==
                              DateFormat('yyyy-MM-dd').format(DateTime.now())) {
                            try {
                              DateTime now = DateTime.now();
                              DateTime? slotTime;
                              
                              // Clean the string
                              String rawTime = slot.startTime.trim();
                              
                              // List of formats to try
                              final formats = [
                                DateFormat("h:mm a"), // 6:00 PM
                                DateFormat("hh:mm a"), // 06:00 PM
                                DateFormat("H:mm"),   // 18:00
                                DateFormat("h:mma"),  // 6:00PM
                                DateFormat("h a"),    // 6 PM
                              ];

                              for (final format in formats) {
                                try {
                                  slotTime = format.parse(rawTime);
                                  break; // Success
                                } catch (_) {}
                              }
                              
                              if (slotTime != null) {
                                // Combine selectedDate with slotTime's hour/minute
                                DateTime slotDateTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  slotTime.hour,
                                  slotTime.minute,
                                );
                                
                                // Calculate closing time (10 minutes before start)
                                DateTime closingTime = slotDateTime.subtract(const Duration(minutes: 10));
                                
                                if (now.isAfter(closingTime)) {
                                  isPast = true;
                                } else {
                                  // Calculate time remaining until booking closes
                                  Duration diff = closingTime.difference(now);
                                  if (diff.inHours == 0 && diff.inMinutes >= 0) {
                                    timeRemaining = "${diff.inMinutes + 1}m left";
                                  }
                                }
                              } else {
                                debugPrint("Could not parse time: '$rawTime'");
                              }
                            } catch (e) {
                              debugPrint("Error parsing slot time outer: $e");
                            }
                          }

                          // Determine Card Style
                          Color cardColor = Colors.white;
                          Color borderColor = Colors.transparent;
                          Color textColor = Colors.black87;
                          String statusText = "";
                          Color statusColor = Colors.grey;

                          if (isMySlot) {
                            cardColor = Colors.green.shade50;
                            borderColor = Colors.green;
                            textColor = Colors.green.shade900;
                            statusText = "Booked";
                            statusColor = Colors.green;
                          } else if (isWaitlisted) {
                            // NEW: Waitlisted Style
                            cardColor = Colors.amber.shade50;
                            borderColor = Colors.amber;
                            textColor = Colors.amber.shade900;
                            statusText = "Waitlisted";
                            statusColor = Colors.amber;
                          } else if (isPast) {
                            cardColor = Colors.grey.shade50;
                            textColor = Colors.grey.shade400;
                            statusText = "Closed";
                            statusColor = Colors.grey;
                          } else if (isFull) {
                            cardColor = Colors.red.shade50;
                            borderColor = Colors.red.shade100;
                            textColor = Colors.red.shade900;
                            statusText = "Full (Join Waitlist)";
                            statusColor = Colors.red;
                          } else {
                            statusText = "Available";
                            statusColor = Colors.blue;
                          }

                          return InkWell(
                            onTap: () {
                                if (isPast) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Booking closed for this slot")));
                                } else if (isMySlot) {
                                   // Already handled by top banner, but optional here
                                } else if (isWaitlisted) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("You are already on the waitlist for this slot.")));
                                } else if (isFull) {
                                   // NEW: Join Waitlist Dialog
                                   _showWaitlistDialog(context, slot, userCtrl);
                                } else if (hasBooking) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("You already booked a slot today. Cancel it to book another.")));
                                } else {
                                   _showBookingDialog(context, slot, userCtrl);
                                }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                border: Border.all(
                                  color: isMySlot || isWaitlisted ? borderColor : Colors.grey.shade200,
                                  width: (isMySlot || isWaitlisted) ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  if (!isPast)
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${slot.startTime}",
                                    style: GoogleFonts.epilogue(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "to ${slot.endTime}",
                                    style: GoogleFonts.epilogue(
                                      color: textColor.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isMySlot ? "Reserved" : 
                                      (isWaitlisted ? "On Waitlist" : 
                                      (isFull ? "Full" : 
                                      (isPast ? "Closed" : "${userCtrl.slotBookingCounts[slot.slotID] ?? 0}/2 Filled"))),
                                      style: GoogleFonts.epilogue(
                                        color: statusColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  
                                  if (timeRemaining != null && !isFull && !isMySlot && !isPast && !isWaitlisted)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        timeRemaining!,
                                        style: GoogleFonts.epilogue(
                                          color: Colors.redAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(
      BuildContext context, slot, UserController userCtrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Booking"),
          content: Text(
              "Book slot ${slot.startTime} - ${slot.endTime} on ${DateFormat('yyyy-MM-dd').format(selectedDate)}?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                userCtrl.bookSlot(
                  slot.slotID,
                  "${slot.startTime} - ${slot.endTime}",
                  DateFormat('yyyy-MM-dd').format(selectedDate),
                  userCtrl.userModel.userName, // Assuming user model is loaded
                  context,
                );
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
  void _showCancelDialog(BuildContext context, UserController userCtrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancel Booking"),
          content: const Text("Are you sure you want to cancel your slot for today?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Keep")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                userCtrl.cancelSlot(
                  userCtrl.myBookingId!,
                  DateFormat('yyyy-MM-dd').format(selectedDate),
                  context,
                );
              },
              child: const Text("Cancel Booking", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showWaitlistDialog(BuildContext context, slot, UserController userCtrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Join Waitlist?"),
          content: const Text(
              "This slot is currently full. Would you like to join the waitlist and get notified if a spot opens up?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                userCtrl.joinWaitlist(
                  slot.slotID,
                  DateFormat('yyyy-MM-dd').format(selectedDate),
                  context,
                );
              },
              child: const Text("Notify Me", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}
