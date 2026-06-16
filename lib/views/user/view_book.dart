import 'package:driving_school/data/learning_test_questions.dart';
import 'package:driving_school/data/traffic_signs_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewBook extends StatelessWidget {
  const ViewBook({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Study Material',
            style: GoogleFonts.epilogue(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            labelStyle: GoogleFonts.epilogue(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.epilogue(fontWeight: FontWeight.normal),
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Q&A"),
              Tab(text: "Traffic Signs"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Q&A List
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: learningTestQuestions.length,
              itemBuilder: (context, index) {
                final q = learningTestQuestions[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    title: Text(
                      "Q${index + 1}. ${q.question}",
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: q.options.map((option) {
                            final isCorrect = option == q.correctAnswer;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: isCorrect ? Border.all(color: Colors.green) : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: GoogleFonts.epilogue(
                                        fontSize: 14,
                                        fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                        color: isCorrect ? Colors.green[800] : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isCorrect)
                                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                ],
                              ),
                            );
                          }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),

            // Tab 2: Traffic Signs Grid
            GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.8,
              ),
              itemCount: trafficSigns.length,
              itemBuilder: (context, index) {
                final sign = trafficSigns[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            sign.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          sign.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.epilogue(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                        child: Text(
                          sign.description,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.epilogue(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
