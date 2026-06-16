import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question_model.dart';
import '../models/mock_test_result_model.dart'; // Added

class MockTestController extends ChangeNotifier {
  // Pool of all available questions
  final List<QuestionModel> _allQuestions = [
    QuestionModel(
      question: "What does ESP (Electronic Stability Program) do?",
      options: [
        "Improves fuel economy",
        "Prevents skids and loss of control",
        "Adjusts suspension height"
      ],
      correctAnswer: "Prevents skids and loss of control",
      category: "Vehicle Maintenance",
    ),
    QuestionModel(
      question: "When are you allowed to overtake from the left side?",
      options: [
        "Never",
        "On one-way roads when the vehicle in front turns right",
        "At intersections only"
      ],
      correctAnswer: "On one-way roads when the vehicle in front turns right",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "What should you do at a STOP sign?",
      options: [
        "Slow down and proceed",
        "Stop completely and proceed when safe",
        "Honk and proceed"
      ],
      correctAnswer: "Stop completely and proceed when safe",
      category: "Road Signs",
    ),
    QuestionModel(
      question: "What is the legal age for driving a car in India?",
      options: ["16", "18", "21"],
      correctAnswer: "18",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "What does a red traffic light indicate?",
      options: ["Stop", "Go", "Slow down"],
      correctAnswer: "Stop",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "When can you use the horn?",
      options: ["To greet a friend", "To warn other road users of danger", "To show impatience"],
      correctAnswer: "To warn other road users of danger",
      category: "Safety",
    ),
    QuestionModel(
      question: "What is the meaning of a continuous yellow line in the center of the road?",
      options: ["Overtaking allowed", "Overtaking prohibited", "Parking allowed"],
      correctAnswer: "Overtaking prohibited",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "What should you do when you hear an ambulance siren?",
      options: ["Speed up", "Stop immediately", "Give way by pulling over to the side"],
      correctAnswer: "Give way by pulling over to the side",
      category: "Safety",
    ),
    QuestionModel(
      question: "What does a flashing yellow signal mean?",
      options: ["Stop", "Slow down and proceed with caution", "Go fast"],
      correctAnswer: "Slow down and proceed with caution",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "Which lane is for overtaking?",
      options: ["Left lane", "Right lane", "Any lane"],
      correctAnswer: "Right lane",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "What must you carry while driving?",
      options: ["Driving License, RC, Insurance, PUC", "Only Driving License", "Only Insurance"],
      correctAnswer: "Driving License, RC, Insurance, PUC",
      category: "Legal",
    ),
    QuestionModel(
      question: "What is the speed limit near a school?",
      options: ["60 km/h", "25 km/h", "40 km/h"],
      correctAnswer: "25 km/h",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "What does a 'Narrow Bridge' sign indicate?",
      options: ["Bridge ahead is wide", "Bridge ahead is narrow", "Bridge is closed"],
      correctAnswer: "Bridge ahead is narrow",
      category: "Road Signs",
    ),
    QuestionModel(
      question: "When a vehicle approaches a railway crossing, what should the driver do?",
      options: ["Speed up to cross quickly", "Stop, look, and listen for trains before crossing", "Honk and cross"],
      correctAnswer: "Stop, look, and listen for trains before crossing",
      category: "Safety",
    ),
    QuestionModel(
      question: "What is the validity of a learner's license?",
      options: ["3 months", "6 months", "1 year"],
      correctAnswer: "6 months",
      category: "Legal",
    ),
    QuestionModel(
      question: "On a road designated as 'No Parking', you can:",
      options: ["Park for a short time", "Stop to pick up passengers", "Not park at all"],
      correctAnswer: "Stop to pick up passengers",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "Pedestrians should cross the road at:",
      options: ["Anywhere", "Zebra crossings", "Near corners"],
      correctAnswer: "Zebra crossings",
      category: "Safety",
    ),
    QuestionModel(
      question: "Driving under the influence of alcohol is:",
      options: ["Allowed at night", "Prohibited", "Allowed in moderation"],
      correctAnswer: "Prohibited",
      category: "Legal",
    ),
    QuestionModel(
      question: "Rear view mirrors are used for:",
      options: ["Checking your face", "Watching traffic behind", "Looking at passengers"],
      correctAnswer: "Watching traffic behind",
      category: "Vehicle Maintenance",
    ),
    QuestionModel(
      question: "When turning left, you should be in:",
      options: ["The right lane", "The left lane", "The center lane"],
      correctAnswer: "The left lane",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "Handbrake is used for:",
      options: ["Reducing speed", "Parking", "Sudden braking"],
      correctAnswer: "Parking",
      category: "Vehicle Maintenance",
    ),
    QuestionModel(
      question: "What should you do if your tire bursts while driving?",
      options: ["Brake hard", "Hold the steering firmly and slow down gradually", "Accelerate"],
      correctAnswer: "Hold the steering firmly and slow down gradually",
      category: "Emergency",
    ),
    QuestionModel(
      question: "High beam is used when:",
      options: ["Driving in city", "Driving on highways with no oncoming traffic", "It is raining"],
      correctAnswer: "Driving on highways with no oncoming traffic",
      category: "Safety",
    ),
    QuestionModel(
      question: "Mobile phones should not be used while driving because:",
      options: ["It drains battery", "It distracts the driver", "It is illegal only in cities"],
      correctAnswer: "It distracts the driver",
      category: "Safety",
    ),
    QuestionModel(
      question: "What does the 'Slippery Road' sign mean?",
      options: ["Road works ahead", "Road surface is slippery", "Winding road"],
      correctAnswer: "Road surface is slippery",
      category: "Road Signs",
    ),
    QuestionModel(
      question: "Minimum age for obtaining a license for transport vehicle is:",
      options: ["18 years", "20 years", "21 years"],
      correctAnswer: "20 years",
      category: "Legal",
    ),
    QuestionModel(
      question: "You are overtaking a car at night. You must ensure that:",
      options: ["You flash your headlights", "You do not dazzle the other driver", "You honk continuously"],
      correctAnswer: "You do not dazzle the other driver",
      category: "Safety",
    ),
    QuestionModel(
      question: "The color of the number plate for private vehicles is:",
      options: ["Yellow with black letters", "White with black letters", "Black with yellow letters"],
      correctAnswer: "White with black letters",
      category: "Legal",
    ),
    QuestionModel(
      question: "The color of the number plate for commercial vehicles is:",
      options: ["Yellow with black letters", "White with black letters", "Black with yellow letters"],
      correctAnswer: "Yellow with black letters",
      category: "Legal",
    ),
    QuestionModel(
      question: "Tailgating (driving too close behind another vehicle) is:",
      options: ["Safe", "Dangerous", "Allowed in traffic"],
      correctAnswer: "Dangerous",
      category: "Safety",
    ),
    QuestionModel(
      question: "When approaching a roundabout, give way to:",
      options: ["Traffic on your left", "Traffic on your right", "Traffic entering"],
      correctAnswer: "Traffic on your right",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "What is the maximum speed limit for motorcycles in cities?",
      options: ["40 km/h", "50 km/h", "60 km/h"],
      correctAnswer: "50 km/h",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "Which of the following is prohibited on an expressway?",
      options: ["Cars", "Buses", "Pedestrians and slow-moving vehicles"],
      correctAnswer: "Pedestrians and slow-moving vehicles",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "When parking your vehicle facing uphill on a road with a curb, you should turn your wheels:",
      options: ["Towards the curb", "Away from the curb", "Straight"],
      correctAnswer: "Away from the curb",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "What should you do if your brakes fail?",
      options: ["Panic", "Pump the brake pedal and shift to a lower gear", "Jump out"],
      correctAnswer: "Pump the brake pedal and shift to a lower gear",
      category: "Emergency",
    ),
    QuestionModel(
      question: "Before starting the engine, you should check:",
      options: ["Tire pressure", "Fuel level", "All of the above"],
      correctAnswer: "All of the above",
      category: "Vehicle Maintenance",
    ),
    QuestionModel(
      question: "What does a 'Yield' sign mean?",
      options: ["Stop completely", "Slow down and give way to traffic", "Speed up"],
      correctAnswer: "Slow down and give way to traffic",
      category: "Road Signs",
    ),
    QuestionModel(
      question: "You should not overtake when:",
      options: ["The road is clear", "Approaching a bend or hill", "The driver in front signals you to"],
      correctAnswer: "Approaching a bend or hill",
      category: "Safety",
    ),
    QuestionModel(
      question: "What is the meaning of a yellow oscillating traffic light?",
      options: ["Stop", "Go", "Drive with caution"],
      correctAnswer: "Drive with caution",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "If a vehicle is following you too closely, what should you do?",
      options: ["Brake suddenly", "Speed up", "Slow down and allow them to pass"],
      correctAnswer: "Slow down and allow them to pass",
      category: "Safety",
    ),
    QuestionModel(
      question: "When driving in fog, you should use:",
      options: ["High beam headlights", "Low beam headlights", "Parking lights"],
      correctAnswer: "Low beam headlights",
      category: "Safety",
    ),
    QuestionModel(
      question: "A driver involved in an accident causing injury must report to the police within:",
      options: ["12 hours", "24 hours", "48 hours"],
      correctAnswer: "24 hours",
      category: "Legal",
    ),
    QuestionModel(
      question: "What is the 2-second rule used for?",
      options: ["Checking engine oil", "Keeping a safe following distance", "Checking tire pressure"],
      correctAnswer: "Keeping a safe following distance",
      category: "Safety",
    ),
    QuestionModel(
      question: "When are high beam headlights unsafe?",
      options: ["On a dark highway", "When there is oncoming traffic", "In a tunnel"],
      correctAnswer: "When there is oncoming traffic",
      category: "Safety",
    ),
    QuestionModel(
      question: "What does a white broken line in the center of the road mean?",
      options: ["Lane change allowed if safe", "Lane change prohibited", "Stop line"],
      correctAnswer: "Lane change allowed if safe",
      category: "Road Signs",
    ),
    QuestionModel(
      question: "Using a mobile phone while driving can result in:",
      options: ["Better concentration", "A fine and penalty", "Improved navigation"],
      correctAnswer: "A fine and penalty",
      category: "Legal",
    ),
    QuestionModel(
      question: "What should you do if you miss your exit on a highway?",
      options: ["Reverse back", "Make a U-turn", "Go to the next exit"],
      correctAnswer: "Go to the next exit",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "Ideally, where should you hold the steering wheel (clock position)?",
      options: ["10 and 2", "9 and 3", "12 and 6"],
      correctAnswer: "9 and 3",
      category: "Safety",
    ),
    QuestionModel(
      question: "Which vehicles have right of way at uncontrolled intersections?",
      options: ["Vehicles coming from the left", "Vehicles coming from the right", "Larger vehicles"],
      correctAnswer: "Vehicles coming from the right",
      category: "Traffic Rules",
    ),
    QuestionModel(
      question: "What is the primary cause of road accidents?",
      options: ["Mechanical failure", "Human error", "Bad roads"],
      correctAnswer: "Human error",
      category: "Safety",
    ),
    QuestionModel(
      question: "Seat belts are mandatory for:",
      options: ["Driver only", "Front passenger only", "All occupants"],
      correctAnswer: "All occupants",
      category: "Legal",
    ),
  ];

  // Current session questions
  List<QuestionModel> _questions = [];
  List<QuestionModel> get questions => _questions;

  int _questionIndex = 0;
  int get questionIndex => _questionIndex;

  bool _isAnswered = false;
  bool get isAnswered => _isAnswered;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedAnswer = "";
  String get selectedAnswer => _selectedAnswer;

  int _score = 0;
  int get score => _score;

  // Gamification & Analytics
  Timer? _timer;
  int _timeLeft = 30; // 30 seconds per question
  int get timeLeft => _timeLeft;

  Map<String, int> _categoryScores = {};
  Map<String, int> _categoryCounts = {};

  MockTestController() {
    // UI components are expected to handle fetching via startQuiz() explicitly now, but starting a default random test just in case.
    _initializeDefaultQuiz();
  }

  void _initializeDefaultQuiz() {
    _questionIndex = 0;
    _isAnswered = false;
    _selectedAnswer = "";
    _score = 0;
    _categoryScores = {};
    _categoryCounts = {};
    
    var randomizedList = List<QuestionModel>.from(_allQuestions)..shuffle();
    _questions = randomizedList.take(10).toList();
    
    for (var q in _questions) {
        _categoryCounts[q.category] = (_categoryCounts[q.category] ?? 0) + 1;
        _categoryScores[q.category] = (_categoryScores[q.category] ?? 0) + 0;
    }
  }

  Future<String?> _fetchRecentWeakArea() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final snapshot = await FirebaseFirestore.instance
          .collection('mock_test_results')
          .where('studentID', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        String weakArea = data['weakArea'] ?? "None";
        if (weakArea != "None" && weakArea.isNotEmpty) {
          return weakArea;
        }
      }
    } catch (e) {
      print("Error fetching recent weak area: $e");
    }
    return null;
  }

  Future<void> startQuiz() async {
    _isLoading = true;
    notifyListeners();

    _questionIndex = 0;
    _isAnswered = false;
    _selectedAnswer = "";
    _score = 0;
    _categoryScores = {};
    _categoryCounts = {};
    
    // Fetch user's weakness for adaptive testing
    String? assignedWeakArea = await _fetchRecentWeakArea();
    
    List<QuestionModel> finalizedTestQuestions = [];
    var allQuestionsCopy = List<QuestionModel>.from(_allQuestions)..shuffle();
    
    if (assignedWeakArea != null) {
        // AI Adaptive Selection: Pick 5 questions from weak area
        var weakAreaQuestions = allQuestionsCopy.where((q) => q.category.toLowerCase().contains(assignedWeakArea.toLowerCase())).toList();
        var otherQuestions = allQuestionsCopy.where((q) => !q.category.toLowerCase().contains(assignedWeakArea.toLowerCase())).toList();
        
        // Take up to 5 questions from weak area
        int numWeakQuestions = weakAreaQuestions.length >= 5 ? 5 : weakAreaQuestions.length;
        finalizedTestQuestions.addAll(weakAreaQuestions.take(numWeakQuestions));
        
        // Fill the rest (up to 10 total) with random questions
        int remainingSlots = 10 - finalizedTestQuestions.length;
        finalizedTestQuestions.addAll(otherQuestions.take(remainingSlots));
        finalizedTestQuestions.shuffle(); // Shuffle the final mixed list
        
        print('-- AI SMART TEST GENERATED -- Weak Area: $assignedWeakArea. (Allocated ${numWeakQuestions} targeted questions)');
    } else {
        // Normal random selection if no weak area exists
        finalizedTestQuestions = allQuestionsCopy.take(10).toList();
        print('-- RANDOM TEST GENERATED -- No specific weak area detected.');
    }

    _questions = finalizedTestQuestions;
    
    // Initialize Category Counts for this session
    for (var q in _questions) {
        _categoryCounts[q.category] = (_categoryCounts[q.category] ?? 0) + 1;
        _categoryScores[q.category] = (_categoryScores[q.category] ?? 0) + 0;
    }

    _isLoading = false;
    notifyListeners();
    startTimer();
  }

  void startTimer() {
    _timeLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        // Time's up!
        stopTimer();
        // Mark as answered (skipped/wrong) and move to next or show answer
        if (!_isAnswered) {
          checkAnswer(""); // Empty answer means skipped/wrong
        }
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void checkAnswer(String answer) {
    if (_isAnswered) return;

    _selectedAnswer = answer;
    _isAnswered = true;
    stopTimer(); // specific time for this question

    final currentQuestion = _questions[_questionIndex];
    if (answer == currentQuestion.correctAnswer) {
      _score++;
      _categoryScores[currentQuestion.category] = (_categoryScores[currentQuestion.category] ?? 0) + 1;
    }
    notifyListeners();
  }

  void nextQuestion(BuildContext context) {
    if (_questionIndex < _questions.length - 1) {
      _questionIndex++;
      _isAnswered = false;
      _selectedAnswer = "";
      notifyListeners();
      startTimer(); // Restart timer for next question
    } else {
      // End of quiz
      stopTimer();
      showResultDialog(context);
    }
  }

  String _getAnalysis() {
    if (_categoryScores.isEmpty) return "No data available.";
    
    String weakArea = "";
    double lowestPercentage = 101.0;

    _categoryScores.forEach((category, score) {
       int total = _categoryCounts[category] ?? 1;
       double percentage = (score / total) * 100;
       
       if (percentage < lowestPercentage) {
          lowestPercentage = percentage;
          weakArea = category;
       }
    });
    
    // If they got everything right
    if (lowestPercentage == 100.0) return "Great job! You mastered all areas.";
    
    return "Weak Area: $weakArea (${_categoryScores[weakArea]}/${_categoryCounts[weakArea]} Correct)";
  }
  
  Future<void> saveTestResult() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Fetch User Name (Optional, could pass it in or fetch here)
      // For speed, I'll fetch it from the 'users' collection or use a placeholder if name isn't critical immediately
      // Better to fetch it properly.
      String studentName = "Student";
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        // Fix: Use 'userName' instead of 'name' as defined in UserModel
        final data = userDoc.data() as Map<String, dynamic>?;
        studentName = data?['userName'] ?? "Student";
      }

      String weakArea = _getAnalysis().split('(').first.replaceAll('Weak Area: ', '').trim();
      if (weakArea.startsWith("Great job")) weakArea = "None";
      if (weakArea.startsWith("No data")) weakArea = "None";

      MockTestResultModel result = MockTestResultModel(
        testID: DateTime.now().millisecondsSinceEpoch.toString(),
        studentID: user.uid,
        studentName: studentName,
        score: _score,
        totalQuestions: _questions.length,
        weakArea: weakArea,
        timestamp: DateTime.now().toString(),
      );

      await FirebaseFirestore.instance.collection('mock_test_results').add(result.toMap());
      print("Test Result Saved Successfully!");
    } catch (e) {
      print("Error saving test result: $e");
    }
  }

  void showResultDialog(BuildContext context) {
      // Save result when showing dialog
      saveTestResult();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Quiz Completed"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("You scored $_score / ${_questions.length}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: Text(_getAnalysis(), style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              ),
              if (_score < 5)
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "You need to improve!",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
              child: const Text("Exit"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                startQuiz(); // Restart quiz with new questions
              },
              child: const Text("Retake Test"),
            ),
          ],
        ),
      );
  }
  
  void resetQuiz() {
    startQuiz();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
