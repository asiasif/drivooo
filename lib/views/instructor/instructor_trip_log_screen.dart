import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/instructor_controller.dart';
import 'package:driving_school/models/trip_log_model.dart';
import 'package:driving_school/models/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InstructorTripLogScreen extends StatefulWidget {
  const InstructorTripLogScreen({super.key});

  @override
  State<InstructorTripLogScreen> createState() => _InstructorTripLogScreenState();
}

class _InstructorTripLogScreenState extends State<InstructorTripLogScreen> {
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
        title: Text('My Trip Logs', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: StreamBuilder<List<TripLogModel>>(
        stream: instructorCtrl.getInstructorTripLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: defaultBlue));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text('No trips logged yet.', style: GoogleFonts.epilogue(color: Colors.grey)),
                ],
              ),
            );
          }

          final logs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: defaultBlue.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.route, color: defaultBlue, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.destination, style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, fontSize: 16)),
                                Text(log.vehiclePlate, style: GoogleFonts.epilogue(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: defaultBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${log.distanceCovered} km', style: GoogleFonts.epilogue(color: defaultBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date', style: GoogleFonts.epilogue(color: Colors.grey.shade500, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(DateFormat('dd MMM yyyy').format(log.tripDate), style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time', style: GoogleFonts.epilogue(color: Colors.grey.shade500, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text('${log.startTime} - ${log.endTime}', style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Odometer', style: GoogleFonts.epilogue(color: Colors.grey.shade500, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text('${log.startKm} - ${log.endKm}', style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTripLogBottomSheet(context),
        backgroundColor: defaultBlue,
        elevation: 6,
        icon: const Icon(Icons.add_road, color: Colors.white),
        label: Text('Log Trip', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddTripLogBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => const _AddTripLogForm(),
    );
  }
}

class _AddTripLogForm extends StatefulWidget {
  const _AddTripLogForm();

  @override
  State<_AddTripLogForm> createState() => _AddTripLogFormState();
}

class _AddTripLogFormState extends State<_AddTripLogForm> {
  final destCtrl = TextEditingController();
  final startKmCtrl = TextEditingController();
  final endKmCtrl = TextEditingController();
  VehicleModel? selectedVehicle;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isSubmitting = false;

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) startTime = picked;
        else endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Provider.of<AdminController>(context, listen: false);
    final instructorCtrl = Provider.of<InstructorController>(context, listen: false);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20, left: 20, right: 20,
      ),
      child: isSubmitting
          ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: defaultBlue)))
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Log New Trip', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                StreamBuilder<List<VehicleModel>>(
                  stream: adminCtrl.getAllVehicles(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final vehicles = snapshot.data!.where((v) => v.status != 'Out of Service').toList();
                    if (vehicles.isEmpty) return const Text('No active vehicles.', style: TextStyle(color: Colors.red));
                    if (selectedVehicle == null && vehicles.isNotEmpty) selectedVehicle = vehicles.first;
                    
                    return DropdownButtonFormField<VehicleModel>(
                      decoration: InputDecoration(
                        labelText: 'Select Vehicle',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.directions_car),
                      ),
                      value: selectedVehicle,
                      items: vehicles.map((v) => DropdownMenuItem(value: v, child: Text('${v.plateNumber} (${v.modelName})'))).toList(),
                      onChanged: (val) => setState(() => selectedVehicle = val),
                    );
                  },
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: destCtrl,
                  decoration: InputDecoration(
                    labelText: 'Destination / Route',
                    prefixIcon: const Icon(Icons.place),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
                          child: Text(startTime != null ? startTime!.format(context) : 'Start Time', style: GoogleFonts.epilogue()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickTime(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
                          child: Text(endTime != null ? endTime!.format(context) : 'End Time', style: GoogleFonts.epilogue()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startKmCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Start KM',
                          prefixIcon: const Icon(Icons.speed),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: endKmCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'End KM',
                          prefixIcon: const Icon(Icons.flag),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: defaultBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (destCtrl.text.isEmpty || startKmCtrl.text.isEmpty || endKmCtrl.text.isEmpty ||
                          selectedVehicle == null || startTime == null || endTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
                        return;
                      }

                      setState(() => isSubmitting = true);
                      await instructorCtrl.submitTripLog(
                        vehicleId: selectedVehicle!.id,
                        vehiclePlate: selectedVehicle!.plateNumber,
                        destination: destCtrl.text,
                        startKm: startKmCtrl.text,
                        endKm: endKmCtrl.text,
                        startTime: startTime!.format(context),
                        endTime: endTime!.format(context),
                        context: context,
                      );
                      if (mounted) Navigator.pop(context);
                    },
                    child: Text('Submit Trip Log', style: GoogleFonts.epilogue(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
    );
  }
}
