import 'package:driving_school/controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class ManageSlot extends StatefulWidget {
  const ManageSlot({super.key});

  @override
  State<ManageSlot> createState() => _ManageSlotState();
}

class _ManageSlotState extends State<ManageSlot> {
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false).fetchTimeSlots();
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
              children: [
                SizedBox(
                  width: width,
                  height: height / 8,
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
                        'Manage Slots',
                        style: GoogleFonts.epilogue(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<AdminController>(
                    builder: (context, controller, child) {
                      if (controller.timeSlotsList.isEmpty) {
                        return const Center(child: Text("No slots added"));
                      }
                      return ListView.separated(
                        itemCount: controller.timeSlotsList.length,
                        padding: const EdgeInsets.only(bottom: 80, top: 10),
                        separatorBuilder: (context, index) => const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final slot = controller.timeSlotsList[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              title: Text(
                                "${slot.startTime} - ${slot.endTime}",
                                style: GoogleFonts.epilogue(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 16
                                ),
                              ),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                                  onPressed: () {
                                    controller.deleteTimeSlot(slot.slotID, context);
                                  },
                                ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSlotDialog(context);
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddSlotDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Time Slot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startController,
                decoration: const InputDecoration(labelText: "Start Time (e.g. 06:00 PM)"),
              ),
              TextField(
                controller: endController,
                decoration: const InputDecoration(labelText: "End Time (e.g. 07:00 PM)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (startController.text.isNotEmpty && endController.text.isNotEmpty) {
                  Provider.of<AdminController>(context, listen: false)
                      .addTimeSlot(startController.text, endController.text, context);
                  startController.clear();
                  endController.clear();
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}

