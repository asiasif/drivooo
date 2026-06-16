import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/models/vehicle_model.dart';
import 'package:driving_school/views/admin/admin_vehicle_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminVehiclesScreen extends StatelessWidget {
  const AdminVehiclesScreen({super.key});

  // Returns color based on how close expiry is
  Color _expiryColor(DateTime? expiry) {
    if (expiry == null) return Colors.grey;
    final daysLeft = expiry.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return Colors.red;
    if (daysLeft <= 30) return Colors.orange;
    return Colors.green;
  }

  Widget _expiryBadge(String label, DateTime? expiry) {
    final color = _expiryColor(expiry);
    final text = expiry == null
        ? '$label: Not Set'
        : '$label: ${DateFormat('dd MMM yy').format(expiry)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 11, color: color),
          const SizedBox(width: 3),
          Text(text, style: GoogleFonts.epilogue(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Provider.of<AdminController>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(EvaIcons.arrow_ios_back_outline),
        ),
        title: Text('Manage Vehicles', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: StreamBuilder<List<VehicleModel>>(
        stream: adminCtrl.getAllVehicles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: defaultBlue));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_filled_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text('No vehicles added yet.', style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final vehicles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              Color statusColor = Colors.green;
              if (vehicle.status == 'Maintenance') statusColor = Colors.orange;
              if (vehicle.status == 'Out of Service') statusColor = Colors.red;

              // Alert icon if any expiry is within 30 days or past
              final anyExpiring = [vehicle.insuranceExpiry, vehicle.pucExpiry]
                  .any((d) => d == null || d.difference(DateTime.now()).inDays <= 30);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => AdminVehicleDetailScreen(vehicle: vehicle))
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: defaultBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.directions_car, color: defaultBlue, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      vehicle.plateNumber,
                                      style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    if (anyExpiring) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                                    ]
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  vehicle.modelName,
                                  style: GoogleFonts.epilogue(fontSize: 14, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    vehicle.status,
                                    style: GoogleFonts.epilogue(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            onSelected: (value) {
                              adminCtrl.updateVehicleStatus(vehicle.id, value, context);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'Active', child: Text('Mark Active')),
                              const PopupMenuItem(value: 'Maintenance', child: Text('Mark Maintenance')),
                              const PopupMenuItem(value: 'Out of Service', child: Text('Mark Out of Service')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _expiryBadge('Ins', vehicle.insuranceExpiry),
                          const SizedBox(width: 8),
                          _expiryBadge('PUC', vehicle.pucExpiry),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVehicleBottomSheet(context),
        backgroundColor: defaultBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Vehicle', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddVehicleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const _AddVehicleForm(),
    );
  }
}

class _AddVehicleForm extends StatefulWidget {
  const _AddVehicleForm();

  @override
  State<_AddVehicleForm> createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<_AddVehicleForm> {
  final plateCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  DateTime? insuranceExpiry;
  DateTime? pucExpiry;

  Future<void> _pickDate(String type) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: 'Select ${type == 'insurance' ? 'Insurance' : 'PUC'} Expiry Date',
    );
    if (picked != null) {
      setState(() {
        if (type == 'insurance') {
          insuranceExpiry = picked;
        } else {
          pucExpiry = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add New Vehicle', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: plateCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Plate Number (e.g. KA-01-AB-1234)',
              prefixIcon: const Icon(Icons.pin),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: modelCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Vehicle Model (e.g. Maruti Swift)',
              prefixIcon: const Icon(Icons.directions_car),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 15),
          // Insurance expiry picker
          _DatePickerTile(
            label: 'Insurance Expiry',
            icon: Icons.shield_outlined,
            selectedDate: insuranceExpiry,
            onTap: () => _pickDate('insurance'),
          ),
          const SizedBox(height: 10),
          // PUC expiry picker
          _DatePickerTile(
            label: 'PUC Expiry',
            icon: Icons.eco_outlined,
            selectedDate: pucExpiry,
            onTap: () => _pickDate('puc'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: defaultBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (plateCtrl.text.isEmpty || modelCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill plate and model fields')),
                  );
                  return;
                }
                Navigator.pop(context);
                final adminCtrl = Provider.of<AdminController>(context, listen: false);
                await adminCtrl.addVehicle(
                  plateNumber: plateCtrl.text.toUpperCase(),
                  modelName: modelCtrl.text,
                  context: context,
                  insuranceExpiry: insuranceExpiry,
                  pucExpiry: pucExpiry,
                );
              },
              child: Text('Add Vehicle', style: GoogleFonts.epilogue(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.icon,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? '$label: ${DateFormat('dd MMM yyyy').format(selectedDate!)}'
                    : '$label: Tap to set (optional)',
                style: GoogleFonts.epilogue(
                  color: selectedDate != null ? Colors.black87 : Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }
}
