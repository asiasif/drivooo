
class QuestionModel {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String category; // Added

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category, // Added
  });
}
