import 'package:driving_school/views/admin/admin_login.dart';
import 'package:driving_school/views/super_admin/branch_details.dart';
import 'package:driving_school/views/super_admin/super_admin_announcements.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuperAdminHome extends StatelessWidget {
  const SuperAdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final branches = [
      {'name': 'Kottakkal Branch', 'isReal': true, 'location': 'Downtown'},
      {'name': 'Kozhikode Branch', 'isReal': false, 'location': 'North Side'},
      {'name': 'Kottayam Branch', 'isReal': false, 'location': 'East End'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Franchise Dashboard', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.black87,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_rounded, color: Colors.white),
            tooltip: 'Post Admin Notice',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SuperAdminAnnouncements()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AdminLogin()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned(top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Positioned(bottom: 0, left: 0, child: Opacity(opacity: 0.5, child: Image.asset('assets/Ellipse 36.png'))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Text('Manage Branches', style: GoogleFonts.epilogue(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text('Select a branch to view analytics and transfer funds.', style: GoogleFonts.epilogue(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF3D6DFF).withAlpha(25),
                        child: const Icon(Icons.business, color: Color(0xFF3D6DFF)),
                      ),
                      title: Text(branch['name'] as String, style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(branch['location'] as String, style: GoogleFonts.epilogue(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BranchDetails(
                          branchName: branch['name'] as String,
                          isRealBranch: branch['isReal'] as bool,
                        )));
                      },
                    ),
                  );
                },
              ),
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
