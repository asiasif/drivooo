class SessionNoteModel {
  String id;
  String studentId;
  String instructorName;
  String note;
  String date;

  SessionNoteModel({
    required this.id,
    required this.studentId,
    required this.instructorName,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'instructorName': instructorName,
      'note': note,
      'date': date,
    };
  }

  factory SessionNoteModel.fromMap(Map<String, dynamic> map) {
    return SessionNoteModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      instructorName: map['instructorName'] ?? '',
      note: map['note'] ?? '',
      date: map['date'] ?? '',
    );
  }
}
