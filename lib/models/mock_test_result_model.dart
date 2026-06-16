class MockTestResultModel {
  String testID;
  String studentID;
  String studentName;
  int score;
  int totalQuestions;
  String weakArea;
  String timestamp;

  MockTestResultModel({
    required this.testID,
    required this.studentID,
    required this.studentName,
    required this.score,
    required this.totalQuestions,
    required this.weakArea,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'testID': testID,
      'studentID': studentID,
      'studentName': studentName,
      'score': score,
      'totalQuestions': totalQuestions,
      'weakArea': weakArea,
      'timestamp': timestamp,
    };
  }

  factory MockTestResultModel.fromMap(Map<String, dynamic> map) {
    return MockTestResultModel(
      testID: map['testID'] ?? '',
      studentID: map['studentID'] ?? '',
      studentName: map['studentName'] ?? 'Unknown',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      weakArea: map['weakArea'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }
}
