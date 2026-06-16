import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driving_school/views/user/leaderboard_screen.dart'; // Added
import '../../controller/mock_test_controller.dart';
import '../../models/question_model.dart'; // Adjust path if needed

class MockTestScreen extends StatelessWidget {
  const MockTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1e293b), // Dark background as per design
      appBar: AppBar(
        title: Text(
          "Mock Test",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
            IconButton(
                onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen()));
                },
                icon: const Icon(Icons.leaderboard, color: Colors.amber),
                tooltip: "Leaderboard",
            )
        ],
      ),
      body: Consumer<MockTestController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }
          if (controller.questions.isEmpty) {
            return const Center(child: Text("Initializing Quiz...", style: TextStyle(color: Colors.white)));
          }
          if (controller.questionIndex >= controller.questions.length) {
            return const Center(child: Text("Quiz Completed", style: TextStyle(color: Colors.white))); // Fallback
          }
          final QuestionModel question = controller.questions[controller.questionIndex];
          
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timer
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: controller.timeLeft <= 10 ? Colors.red : Colors.green),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer, color: controller.timeLeft <= 10 ? Colors.red : Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "${controller.timeLeft}s",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Progress Bar or Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Question ${controller.questionIndex + 1} of ${controller.questions.length}",
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      "${((controller.questionIndex + 1) / controller.questions.length * 100).toInt()}%",
                      style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (controller.questionIndex + 1) / controller.questions.length,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 30),

                // Question Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff334155),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${controller.questionIndex + 1}",
                        style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        question.question,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Options
                Expanded(
                  child: ListView.separated(
                    itemCount: question.options.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      final isSelected = controller.selectedAnswer == option;
                      final isCorrect = option == question.correctAnswer;
                      final isWrong = isSelected && !isCorrect;
                      
                      // Determination for coloring
                      Color borderColor = Colors.white24;
                      Color backgroundColor = Colors.transparent;
                      
                      if (controller.isAnswered) {
                         if (isCorrect) {
                           borderColor = Colors.green;
                           backgroundColor = Colors.green.withOpacity(0.1);
                         } else if (isSelected) { // Wrong answer selected
                           borderColor = Colors.red;
                           backgroundColor = Colors.red.withOpacity(0.1);
                         }
                      }

                      return GestureDetector(
                        onTap: () => controller.checkAnswer(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white10,
                                ),
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C...
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  option,
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Next Button
                if (controller.isAnswered)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.nextQuestion(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        controller.questionIndex == controller.questions.length - 1 ? "Finish" : "Next Question",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
