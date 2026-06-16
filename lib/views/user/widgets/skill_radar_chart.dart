import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driving_school/const.dart';
import 'package:driving_school/models/student_skill_model.dart';

class SkillRadarChart extends StatelessWidget {
  final StudentSkillModel skills;

  const SkillRadarChart({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Driving Skill Assessment",
          style: GoogleFonts.epilogue(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Based on Instructor Feedback",
          style: GoogleFonts.epilogue(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        SizedBox(
          height: 250,
          child: RadarChart(
            RadarChartData(
              dataSets: _showingDataSets(),
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(color: Colors.transparent),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle: GoogleFonts.epilogue(
                color: Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              getTitle: (index, angle) {
                switch (index) {
                  case 0:
                    return RadarChartTitle(text: 'Steering\n(${skills.steeringControl}/10)');
                  case 1:
                    return RadarChartTitle(text: 'Parking\n(${skills.parkingAccuracy}/10)');
                  case 2:
                    return RadarChartTitle(text: 'Rules\n(${skills.trafficRuleAwareness}/10)');
                  case 3:
                    return RadarChartTitle(text: 'Confidence\n(${skills.confidence}/10)');
                  case 4:
                    return RadarChartTitle(text: 'Braking\n(${skills.brakingAcceleration}/10)');
                  default:
                    return const RadarChartTitle(text: '');
                }
              },
              tickCount: 1,
              ticksTextStyle: const TextStyle(color: Colors.transparent),
              tickBorderData: const BorderSide(color: Colors.transparent),
              gridBorderData: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            duration: const Duration(milliseconds: 400),
          ),
        ),
        // Legend / Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               _buildLegendIten("Needs Work", Colors.red.shade300),
               const SizedBox(width: 15),
               _buildLegendIten("Excellent", defaultBlue),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildLegendIten(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade700),
        )
      ],
    );
  }

  List<RadarDataSet> _showingDataSets() {
    return [
      RadarDataSet(
        fillColor: defaultBlue.withOpacity(0.25),
        borderColor: defaultBlue,
        // itemRadius: 3, // Deprecated in latest fl_chart
        dataEntries: [
          RadarEntry(value: skills.steeringControl.toDouble()),
          RadarEntry(value: skills.parkingAccuracy.toDouble()),
          RadarEntry(value: skills.trafficRuleAwareness.toDouble()),
          RadarEntry(value: skills.confidence.toDouble()),
          RadarEntry(value: skills.brakingAcceleration.toDouble()),
        ],
        borderWidth: 2,
      ),
      // Placeholder for "Goal" (Perfect Score)
      RadarDataSet(
        fillColor: Colors.transparent,
        borderColor: Colors.grey.withOpacity(0.2),
        // itemRadius: 0, // Deprecated in latest fl_chart
        dataEntries: [
          const RadarEntry(value: 10),
          const RadarEntry(value: 10),
          const RadarEntry(value: 10),
          const RadarEntry(value: 10),
          const RadarEntry(value: 10),
        ],
        borderWidth: 1,
      ),
    ];
  }
}
