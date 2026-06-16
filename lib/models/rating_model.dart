class RatingModel {
  String ratingID;
  String instructorID;
  String studentID;
  String studentName;
  double score;
  String comment;
  String timestamp;

  RatingModel({
    required this.ratingID,
    required this.instructorID,
    required this.studentID,
    required this.studentName,
    required this.score,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'ratingID': ratingID,
      'instructorID': instructorID,
      'studentID': studentID,
      'studentName': studentName,
      'score': score,
      'comment': comment,
      'timestamp': timestamp,
    };
  }

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      ratingID: map['ratingID'] ?? '',
      instructorID: map['instructorID'] ?? '',
      studentID: map['studentID'] ?? '',
      studentName: map['studentName'] ?? '',
      score: (map['score'] is int) ? (map['score'] as int).toDouble() : map['score'] ?? 0.0,
      comment: map['comment'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }
}
