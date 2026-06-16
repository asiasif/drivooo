import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/models/maintenance_receipt_model.dart';
import 'package:driving_school/models/trip_log_model.dart';
import 'package:driving_school/models/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminVehicleDetailScreen extends StatefulWidget {
  final VehicleModel vehicle;
  const AdminVehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<AdminVehicleDetailScreen> createState() => _AdminVehicleDetailScreenState();
}

class _AdminVehicleDetailScreenState extends State<AdminVehicleDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    if (status == 'Maintenance') return Colors.orange;
    if (status == 'Out of Service') return Colors.red;
    return Colors.green;
  }

  Color _expiryColor(DateTime? expiry) {
    if (expiry == null) return Colors.grey;
    final daysLeft = expiry.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return Colors.red;
    if (daysLeft <= 30) return Colors.orange;
    return Colors.green;
  }

  String _expiryLabel(DateTime? expiry) {
    if (expiry == null) return 'Not Set';
    final daysLeft = expiry.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return 'Expired ${(-daysLeft)} days ago';
    if (daysLeft == 0) return 'Expires Today!';
    return '${DateFormat('dd MMM yyyy').format(expiry)} (${daysLeft}d left)';
  }

  Future<void> _editExpiryDates(BuildContext context) async {
    final adminCtrl = Provider.of<AdminController>(context, listen: false);
    DateTime? insExpiry = widget.vehicle.insuranceExpiry;
    DateTime? pucExpiry = widget.vehicle.pucExpiry;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _EditExpirySheet(
        initialInsurance: insExpiry,
        initialPuc: pucExpiry,
        onSave: (ins, puc) async {
          await adminCtrl.updateVehicleExpiry(widget.vehicle.id, ins, puc, context);
        },
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
        title: Text(widget.vehicle.plateNumber, style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: defaultBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: defaultBlue,
          labelStyle: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Maintenance'),
            Tab(text: 'Trip Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ---- TAB 1: Overview (Expiry Info) ----
          _buildOverviewTab(context),

          // ---- TAB 2: Maintenance History ----
          StreamBuilder<List<MaintenanceReceiptModel>>(
            stream: adminCtrl.getMaintenanceByVehicle(widget.vehicle.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: defaultBlue));
              }
              final receipts = snapshot.data ?? [];
              if (receipts.isEmpty) {
                return Center(
                  child: Text('No repair bills submitted for this vehicle.',
                      style: GoogleFonts.epilogue(color: Colors.grey)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: receipts.length,
                itemBuilder: (context, index) => _buildReceiptCard(context, receipts[index], adminCtrl),
              );
            },
          ),

          // ---- TAB 3: Trip Logs ----
          StreamBuilder<List<TripLogModel>>(
            stream: adminCtrl.getTripLogsByVehicle(widget.vehicle.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: defaultBlue));
              }
              final trips = snapshot.data ?? [];
              if (trips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.route_outlined, size: 70, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text('No trips logged yet.', style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                );
              }

              // Compute total km
              final totalKm = trips.fold<int>(0, (sum, t) => sum + t.distanceCovered);

              return Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Trips: ${trips.length}',
                            style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
                        Text('Total Distance: ${totalKm} km',
                            style: GoogleFonts.epilogue(color: defaultBlue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: trips.length,
                      itemBuilder: (context, index) => _buildTripCard(trips[index]),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Vehicle header
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: defaultBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_car, size: 40, color: defaultBlue),
                ),
                const SizedBox(height: 15),
                Text(
                  widget.vehicle.modelName,
                  style: GoogleFonts.epilogue(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.vehicle.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.vehicle.status,
                    style: GoogleFonts.epilogue(
                        color: _getStatusColor(widget.vehicle.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Expiry section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Document Expiry', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _editExpiryDates(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text('Edit', style: GoogleFonts.epilogue()),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildExpiryCard(
                  'Insurance',
                  Icons.shield_outlined,
                  widget.vehicle.insuranceExpiry,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildExpiryCard(
                  'PUC Certificate',
                  Icons.eco_outlined,
                  widget.vehicle.pucExpiry,
                  Colors.teal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildExpiryCard(String label, IconData icon, DateTime? expiry, Color baseColor) {
    final color = _expiryColor(expiry);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: baseColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  _expiryLabel(expiry),
                  style: GoogleFonts.epilogue(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              expiry == null
                  ? 'Not Set'
                  : expiry.isBefore(DateTime.now())
                      ? 'EXPIRED'
                      : expiry.difference(DateTime.now()).inDays <= 30
                          ? 'EXPIRING'
                          : 'VALID',
              style: GoogleFonts.epilogue(
                  color: color, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, MaintenanceReceiptModel receipt, AdminController adminCtrl) {
    Color statusColor = Colors.orange;
    if (receipt.status == 'Approved') statusColor = Colors.green;
    if (receipt.status == 'Rejected') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        shape: const Border(),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            receipt.imageUrl,
            width: 50, height: 50, fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Container(
              width: 50, height: 50, color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, color: Colors.grey, size: 20),
            ),
          ),
        ),
        title: Text('₹${receipt.amount.toStringAsFixed(0)}',
            style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(receipt.description,
            style: GoogleFonts.epilogue(fontSize: 13, color: Colors.grey.shade700),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Logged by', style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 13)),
                  Text(receipt.instructorName, style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Date', style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 13)),
                  Text(DateFormat('dd MMM yyyy').format(receipt.date),
                      style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
                const SizedBox(height: 15),
                if (receipt.status == 'Pending') ...[
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                        onPressed: () => adminCtrl.updateMaintenanceReceiptStatus(receipt.id, 'Rejected', context),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => adminCtrl.updateMaintenanceReceiptStatus(receipt.id, 'Approved', context),
                        child: const Text('Approve', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ])
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text('Status: ${receipt.status}',
                          style: GoogleFonts.epilogue(color: statusColor, fontWeight: FontWeight.bold)),
                    ),
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTripCard(TripLogModel trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.route_outlined, color: defaultBlue, size: 18),
                const SizedBox(width: 6),
                Text(trip.destination,
                    style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 15)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: defaultBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${trip.distanceCovered} km',
                    style: GoogleFonts.epilogue(color: defaultBlue, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(trip.instructorName,
                style: GoogleFonts.epilogue(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(width: 16),
            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(DateFormat('dd MMM yyyy').format(trip.tripDate),
                style: GoogleFonts.epilogue(color: Colors.grey.shade600, fontSize: 13)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.speed_outlined, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text('${trip.startKm} → ${trip.endKm} km',
                style: GoogleFonts.epilogue(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(width: 16),
            Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text('${trip.startTime} – ${trip.endTime}',
                style: GoogleFonts.epilogue(color: Colors.grey.shade600, fontSize: 13)),
          ]),
        ],
      ),
    );
  }
}

// Bottom sheet for editing expiry dates
class _EditExpirySheet extends StatefulWidget {
  final DateTime? initialInsurance;
  final DateTime? initialPuc;
  final Future<void> Function(DateTime? ins, DateTime? puc) onSave;

  const _EditExpirySheet({required this.initialInsurance, required this.initialPuc, required this.onSave});

  @override
  State<_EditExpirySheet> createState() => _EditExpirySheetState();
}

class _EditExpirySheetState extends State<_EditExpirySheet> {
  DateTime? insuranceExpiry;
  DateTime? pucExpiry;

  @override
  void initState() {
    super.initState();
    insuranceExpiry = widget.initialInsurance;
    pucExpiry = widget.initialPuc;
  }

  Future<void> _pickDate(String type) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (type == 'insurance' ? insuranceExpiry : pucExpiry) ??
          DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (type == 'insurance') insuranceExpiry = picked;
        else pucExpiry = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20, left: 20, right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update Expiry Dates', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildDateTile('Insurance Expiry', Icons.shield_outlined, insuranceExpiry, () => _pickDate('insurance')),
          const SizedBox(height: 12),
          _buildDateTile('PUC Expiry', Icons.eco_outlined, pucExpiry, () => _pickDate('puc')),
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
                Navigator.pop(context);
                await widget.onSave(insuranceExpiry, pucExpiry);
              },
              child: Text('Save', style: GoogleFonts.epilogue(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile(String label, IconData icon, DateTime? date, VoidCallback onTap) {
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
                date != null
                    ? '$label: ${DateFormat('dd MMM yyyy').format(date)}'
                    : '$label: Tap to set',
                style: GoogleFonts.epilogue(
                    color: date != null ? Colors.black87 : Colors.grey.shade500, fontSize: 14),
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }
}
