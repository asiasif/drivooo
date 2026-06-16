import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school/models/mock_test_result_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1e293b),
      appBar: AppBar(
        title: Text(
          "Leaderboard",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('mock_test_results')
            .orderBy('score', descending: true)
            .limit(10)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(
               child: Padding(
                 padding: const EdgeInsets.all(20.0),
                 child: Text(
                   "Error loading leaderboard:\n${snapshot.error}",
                   style: GoogleFonts.poppins(color: Colors.redAccent),
                   textAlign: TextAlign.center,
                 ),
               ),
             );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No tests taken yet!",
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }

          final results = snapshot.data!.docs
              .map((doc) => MockTestResultModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final result = results[index];
              return Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xff334155),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: index == 0 ? Colors.amber : Colors.white10,
                    width: index == 0 ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Rank Badge
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getRankColor(index),
                      ),
                      child: Text(
                        "#${index + 1}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    
                    // Name and Weak Area
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.studentName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            result.weakArea != "None" ? "Weakness: ${result.weakArea}" : "Perfect Score!",
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${result.score}/${result.totalQuestions}",
                        style: GoogleFonts.poppins(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return Colors.amber; // Gold
    if (index == 1) return Colors.grey; // Silver
    if (index == 2) return Colors.brown; // Bronze
    return Colors.white24;
  }
}
