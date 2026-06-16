import 'dart:io';
import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/instructor_controller.dart';
import 'package:driving_school/models/fuel_receipt_model.dart';
import 'package:driving_school/models/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class InstructorFuelScreen extends StatefulWidget {
  const InstructorFuelScreen({super.key});

  @override
  State<InstructorFuelScreen> createState() => _InstructorFuelScreenState();
}

class _InstructorFuelScreenState extends State<InstructorFuelScreen> {
  @override
  Widget build(BuildContext context) {
    final instructorCtrl = Provider.of<InstructorController>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(EvaIcons.arrow_ios_back_outline),
        ),
        title: Text('My Fuel Logs', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: StreamBuilder<List<FuelReceiptModel>>(
        stream: instructorCtrl.getInstructorFuelReceipts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_gas_station_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text('No fuel logs submitted yet.', style: GoogleFonts.epilogue(color: Colors.grey)),
                ],
              ),
            );
          }

          final receipts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              Color statusColor = Colors.orange;
              if (receipt.status == 'Approved') statusColor = Colors.green;
              if (receipt.status == 'Rejected') statusColor = Colors.red;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          receipt.receiptImageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.local_gas_station_outlined, color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${receipt.amount}',
                                  style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.black87),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    receipt.status,
                                    style: GoogleFonts.epilogue(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${receipt.liters} L • ${receipt.vehiclePlate}',
                              style: GoogleFonts.epilogue(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(receipt.date),
                              style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade400),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFuelLogBottomSheet(context),
        backgroundColor: defaultBlue,
        elevation: 6,
        icon: const Icon(Icons.local_gas_station_rounded, color: Colors.white),
        label: Text('Log Fuel', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  void _showAddFuelLogBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _AddFuelLogForm(),
    );
  }
}

class _AddFuelLogForm extends StatefulWidget {
  const _AddFuelLogForm();

  @override
  State<_AddFuelLogForm> createState() => _AddFuelLogFormState();
}

class _AddFuelLogFormState extends State<_AddFuelLogForm> {
  final amountCtrl = TextEditingController();
  final litersCtrl = TextEditingController();
  VehicleModel? selectedVehicle;
  XFile? receiptImage;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Provider.of<AdminController>(context, listen: false);
    final instructorCtrl = Provider.of<InstructorController>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: isSubmitting
          ? const Padding(
              padding: EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: defaultBlue),
                  SizedBox(height: 20),
                  Text('Uploading Receipt...'),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Log Fuel Refill', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                StreamBuilder<List<VehicleModel>>(
                  stream: adminCtrl.getAllVehicles(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final vehicles = snapshot.data!.where((v) => v.status != 'Out of Service').toList();
                    if (vehicles.isEmpty) {
                      return const Text('No active vehicles found.', style: TextStyle(color: Colors.red));
                    }
                    if (selectedVehicle == null && vehicles.isNotEmpty) {
                      selectedVehicle = vehicles.first;
                    }
                    return DropdownButtonFormField<VehicleModel>(
                      decoration: InputDecoration(
                        labelText: 'Select Vehicle',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.directions_car),
                      ),
                      value: selectedVehicle,
                      items: vehicles.map((v) {
                        return DropdownMenuItem(
                          value: v,
                          child: Text('${v.plateNumber} (${v.modelName})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => selectedVehicle = val);
                      },
                    );
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount (₹)',
                          prefixIcon: const Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: litersCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Liters',
                          prefixIcon: const Icon(Icons.water_drop),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () async {
                    final img = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
                    if (img != null) setState(() => receiptImage = img);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: receiptImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                              const SizedBox(height: 5),
                              Text('Tap to capture receipt', style: GoogleFonts.epilogue(color: Colors.grey)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(receiptImage!.path), fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: defaultBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 5,
                      shadowColor: defaultBlue.withOpacity(0.4),
                    ),
                    onPressed: () async {
                      if (amountCtrl.text.isEmpty || litersCtrl.text.isEmpty || selectedVehicle == null || receiptImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all fields and upload receipt.')),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);
                      await instructorCtrl.submitFuelReceipt(
                        vehicleId: selectedVehicle!.id,
                        vehiclePlate: selectedVehicle!.plateNumber,
                        amount: amountCtrl.text,
                        liters: litersCtrl.text,
                        receiptImage: receiptImage!,
                        context: context,
                      );
                      if (mounted) Navigator.pop(context); // Close bottom sheet
                    },
                    child: Text('Submit Fuel Log', style: GoogleFonts.epilogue(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
