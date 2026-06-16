import 'package:driving_school/const.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/models/student_skill_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class StudentEvaluation extends StatefulWidget {
  final String userID;
  final String userName;

  const StudentEvaluation({
    super.key,
    required this.userID,
    required this.userName,
  });

  @override
  State<StudentEvaluation> createState() => _StudentEvaluationState();
}

class _StudentEvaluationState extends State<StudentEvaluation> {
  StudentSkillModel? skills;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  void _loadSkills() async {
    final controller = Provider.of<UserController>(context, listen: false);
    final fetchedSkills = await controller.fetchStudentSkills(widget.userID);
    setState(() {
      skills = fetchedSkills;
      isLoading = false;
    });
  }

  void _saveSkills() async {
    final controller = Provider.of<UserController>(context, listen: false);
    if (skills != null) {
      skills!.lastUpdated = DateTime.now().toString();
      await controller.updateStudentSkills(skills!, context);
    }
  }

  Widget _buildSkillSlider(String label, int value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.epilogue(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\$value / 10',
              style: GoogleFonts.epilogue(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: defaultBlue,
              ),
            )
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: defaultBlue,
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Image.asset('assets/Ellipse 36.png')]),
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: height / 8,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(EvaIcons.arrow_ios_back_outline),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Evaluate \${widget.userName}',
                                  style: GoogleFonts.epilogue(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Update the student's driving skills based on their recent performance. This will reflect on their radar chart.",
                          style: GoogleFonts.epilogue(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 3)
                              )
                            ]
                          ),
                          child: Column(
                            children: [
                              _buildSkillSlider('Steering Control', skills!.steeringControl, (val) {
                                setState(() => skills!.steeringControl = val.toInt());
                              }),
                              _buildSkillSlider('Parking Accuracy', skills!.parkingAccuracy, (val) {
                                setState(() => skills!.parkingAccuracy = val.toInt());
                              }),
                              _buildSkillSlider('Traffic Rules', skills!.trafficRuleAwareness, (val) {
                                setState(() => skills!.trafficRuleAwareness = val.toInt());
                              }),
                              _buildSkillSlider('Confidence', skills!.confidence, (val) {
                                setState(() => skills!.confidence = val.toInt());
                              }),
                              _buildSkillSlider('Braking & Accel.', skills!.brakingAcceleration, (val) {
                                setState(() => skills!.brakingAcceleration = val.toInt());
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                              )
                            ),
                            onPressed: _saveSkills,
                            child: Text(
                              'Save Evaluation',
                              style: GoogleFonts.epilogue(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
