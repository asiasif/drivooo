import 'package:driving_school/controller/admin_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:icons_plus/icons_plus.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<AdminController>(context, listen: false);
      controller.fetchUsers();
      controller.fetchAllInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminController = Provider.of<AdminController>(context);
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
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SizedBox(
                    width: width,
                    height: height / 10,
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
                          'Analytics',
                          style: GoogleFonts.epilogue(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overview',
                          style: GoogleFonts.epilogue(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Students',
                                value: adminController.totalStudents.toString(),
                                icon: Icons.people_outline,
                                color: Colors.blue.shade100,
                                iconColor: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Monthly Revenue',
                                value: '₹${adminController.getCurrentMonthRevenue().toStringAsFixed(0)}',
                                icon: Icons.currency_rupee,
                                color: Colors.green.shade100,
                                iconColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Course Popularity',
                          style: GoogleFonts.epilogue(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildCoursePopularityChart(adminController),
                        const SizedBox(height: 40), // Bottom spacing
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: GoogleFonts.epilogue(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xff1e293b),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: GoogleFonts.epilogue(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursePopularityChart(AdminController controller) {
    var popularity = controller.getCoursePopularity();
    
    if (popularity.isEmpty) {
       return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No purchase data available yet.',
            style: GoogleFonts.epilogue(color: Colors.grey),
          ),
        ),
      );
    }

    // Define a list of pleasing colors
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 4, 
              centerSpaceRadius: 50,
              sections: List.generate(popularity.length, (i) {
                final isTouched = i == touchedIndex;
                final fontSize = isTouched ? 18.0 : 14.0;
                final radius = isTouched ? 65.0 : 55.0;
                final entry = popularity[i];
                
                return PieChartSectionData(
                  color: colors[i % colors.length],
                  value: entry.value.toDouble(),
                  title: '${entry.value}',
                  radius: radius,
                  titleStyle: GoogleFonts.epilogue(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Clean Legend
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(20),
             boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: List.generate(popularity.length, (i) {
              final entry = popularity[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors[i % colors.length],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        entry.key, 
                        style: GoogleFonts.epilogue(
                          color: const Color(0xff1e293b),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      "${entry.value} Sold", 
                      style: GoogleFonts.epilogue(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
