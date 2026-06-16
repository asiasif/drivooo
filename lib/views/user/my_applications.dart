import 'package:driving_school/const.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyApplications extends StatefulWidget {
  const MyApplications({super.key});

  @override
  State<MyApplications> createState() => _MyApplicationsState();
}

class _MyApplicationsState extends State<MyApplications> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userController = Provider.of<UserController>(context, listen: false);
      userController.fetchUserRcRenewals();
      userController.fetchUserRetestApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Applications',
            style: GoogleFonts.epilogue(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelStyle: GoogleFonts.epilogue(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.epilogue(fontWeight: FontWeight.normal),
            indicatorColor: defaultBlue,
            labelColor: defaultBlue, // Selected color
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'RC Renewal'),
              Tab(text: 'Retest'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RcRenewalList(),
            _RetestList(),
          ],
        ),
      ),
    );
  }
}

class _RcRenewalList extends StatelessWidget {
  const _RcRenewalList();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, controller, child) {
        if (controller.userRcRenewalList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment_outlined, size: 50, color: Colors.grey),
                const SizedBox(height: 10),
                Text('No RC Renewal Applications', style: GoogleFonts.epilogue(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: controller.userRcRenewalList.length,
          itemBuilder: (context, index) {
            final rcData = controller.userRcRenewalList[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('RC Renewal', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16)),
                        _buildStatusTag(rcData.status),
                      ],
                    ),
                    const Divider(),
                    _buildInfoRow('RC Number', rcData.rcNumber),
                    _buildInfoRow('Vehicle', rcData.vehicleClass),
                    _buildInfoRow('Applied On', rcData.applicationDate),
                    const SizedBox(height: 5),
                    if (rcData.expiryDate.isNotEmpty)
                      _buildInfoRow('Expiry Date', rcData.expiryDate, isBold: false),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    switch (status) {
      case 'Success':
      case 'Completed':
        color = Colors.green;
        break;
      case 'Rejected':
        color = Colors.red;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue; 
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: GoogleFonts.epilogue(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: GoogleFonts.epilogue(
              fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _RetestList extends StatelessWidget {
  const _RetestList();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, controller, child) {
        if (controller.userRetestList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_edu, size: 50, color: Colors.grey),
                const SizedBox(height: 10),
                Text('No Retest Applications', style: GoogleFonts.epilogue(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: controller.userRetestList.length,
          itemBuilder: (context, index) {
            final retest = controller.userRetestList[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Retest Application', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                             child: Text(retest.paymentStatus, style: GoogleFonts.epilogue(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildInfoRow('Learner\'s No', retest.learnersNumber),
                    _buildInfoRow('Applied On', retest.date),
                    _buildInfoRow(
                      'Test Date', 
                      retest.testDate.isEmpty ? 'Pending Assignment' : retest.testDate,
                      valueColor: retest.testDate.isEmpty ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(height: 5),
                    Text('Selected Tests:', style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: retest.selectedTests.map((e) => Chip(
                        label: Text(e.toString(), style: GoogleFonts.epilogue(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.blue.shade50,
                      )).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 14)),
          Text(value, style: GoogleFonts.epilogue(fontWeight: FontWeight.w500, fontSize: 14, color: valueColor)),
        ],
      ),
    );
  }
}
