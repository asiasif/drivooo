import 'package:driving_school/const.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/controller/instructor_controller.dart';
import 'package:driving_school/models/student_skill_model.dart';
import 'package:driving_school/models/session_note_model.dart';
import 'package:driving_school/views/user/widgets/skill_radar_chart.dart';
import 'package:driving_school/views/user/instructor_student_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class MyProgressScreen extends StatelessWidget {
  final String uid;
  const MyProgressScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final controller = Provider.of<UserController>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: 0, right: 0, child: Image.asset('assets/Ellipse 2.png')),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Image.asset('assets/Ellipse 36.png')],
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(EvaIcons.arrow_ios_back_outline),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'My Progress',
                        style: GoogleFonts.epilogue(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Object>>(
                    future: Future.wait([
                      controller.fetchStudentSkills(uid),
                      controller.fetchSkillHistory(uid),
                      Provider.of<InstructorController>(context, listen: false).fetchSessionNotes(uid),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: defaultBlue));
                      }

                      final latestSkills = snapshot.data?[0] as StudentSkillModel?;
                      final history = (snapshot.data?[1] as List<StudentSkillModel>?) ?? [];
                      final sessionNotes = (snapshot.data?[2] as List<SessionNoteModel>?) ?? [];

                      if (latestSkills == null) {
                        return Center(
                          child: Text(
                            'No skill data yet.\nAsk your instructor to evaluate you!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.epilogue(color: Colors.grey),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            // Info banner
                            Container(
                              width: width,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [defaultBlue, Color(0xFF2979FF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.white, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Your driving skill scores are updated by your instructor after each session.',
                                      style: GoogleFonts.epilogue(color: Colors.white, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Radar chart
                            Container(
                              width: width,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: SkillRadarChart(skills: latestSkills),
                            ),
                            const SizedBox(height: 20),
                            // Score breakdown
                            Text('Skill Breakdown', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _SkillTile(label: 'Steering Control', value: latestSkills.steeringControl),
                            _SkillTile(label: 'Parking Accuracy', value: latestSkills.parkingAccuracy),
                            _SkillTile(label: 'Traffic Rule Awareness', value: latestSkills.trafficRuleAwareness),
                            _SkillTile(label: 'Confidence', value: latestSkills.confidence),
                            _SkillTile(label: 'Braking & Acceleration', value: latestSkills.brakingAcceleration),

                            if (latestSkills.lastUpdated.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Center(
                                child: Text(
                                  'Last updated: ${_formatDate(latestSkills.lastUpdated)}',
                                  style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade500),
                                ),
                              ),
                            ],

                            // ---- History Timeline ----
                            if (history.length > 1) ...[
                              const SizedBox(height: 24),
                              Text('Evaluation History', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('All ${history.length} sessions by your instructor', style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 12),
                              ...history.asMap().entries.map((entry) {
                                final i = entry.key;
                                final eval = entry.value;
                                final isLatest = i == 0;
                                return _HistoryTile(eval: eval, isLatest: isLatest);
                              }),
                            ],

                            // ---- Session Notes Section ----
                            if (sessionNotes.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.note_alt_outlined, color: defaultBlue, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Session Notes', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${sessionNotes.length} note${sessionNotes.length == 1 ? '' : 's'} from your instructor', style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 12),
                              ...sessionNotes.map((sNote) => _SessionNoteTile(note: sNote)),
                            ],

                            const SizedBox(height: 80),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Chat FAB – visible only if user has an assigned instructor
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        onPressed: () {
          final userCtrl = Provider.of<UserController>(context, listen: false);
          final instructorName = userCtrl.userModel.selectedInstructor;
          if (instructorName == null || instructorName.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You have no assigned instructor yet.')),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InstructorStudentChatScreen(
                studentId: uid,
                instructorName: instructorName,
              ),
            ),
          );
        },
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: Text('Chat with Instructor', style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

// ---- Sub-widgets ----

class _SkillTile extends StatelessWidget {
  final String label;
  final int value;
  const _SkillTile({required this.label, required this.value});

  Color get _color {
    if (value >= 8) return Colors.green;
    if (value >= 5) return const Color(0xFF2979FF);
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text('$value / 10', style: GoogleFonts.epilogue(fontSize: 13, fontWeight: FontWeight.bold, color: _color)),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final StudentSkillModel eval;
  final bool isLatest;
  const _HistoryTile({required this.eval, required this.isLatest});

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    try {
      final dt = DateTime.parse(eval.lastUpdated);
      dateStr = '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      dateStr = eval.lastUpdated;
    }

    final avg = ((eval.steeringControl + eval.parkingAccuracy + eval.trafficRuleAwareness + eval.confidence + eval.brakingAcceleration) / 5).toStringAsFixed(1);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isLatest ? Colors.blue : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(color: isLatest ? Colors.blue : Colors.grey, width: 2),
                ),
              ),
              Expanded(child: Container(width: 2, color: Colors.grey.shade200)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 5)],
                border: isLatest ? Border.all(color: Colors.blue.withOpacity(0.3)) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr, style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 14)),
                      if (isLatest) Text('Latest', style: GoogleFonts.epilogue(fontSize: 11, color: Colors.blue)),
                    ],
                  ),
                  Text('Avg: $avg/10', style: GoogleFonts.epilogue(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionNoteTile extends StatelessWidget {
  final SessionNoteModel note;
  const _SessionNoteTile({required this.note});

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    try {
      final dt = DateTime.parse(note.date);
      dateStr = '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      dateStr = note.date;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.purple.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple, width: 2),
                ),
              ),
              Expanded(child: Container(width: 2, color: Colors.purple.shade100)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 5)],
                border: Border.all(color: Colors.purple.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            note.instructorName,
                            style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Text(dateStr, style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey.shade400)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.note,
                    style: GoogleFonts.epilogue(fontSize: 13, height: 1.4, color: Colors.black87),
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
