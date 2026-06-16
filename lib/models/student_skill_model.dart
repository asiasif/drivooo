class StudentSkillModel {
  String studentId;
  int steeringControl; // 0-10
  int parkingAccuracy; // 0-10
  int trafficRuleAwareness; // 0-10
  int confidence; // 0-10
  int brakingAcceleration; // 0-10
  String lastUpdated;

  StudentSkillModel({
    required this.studentId,
    required this.steeringControl,
    required this.parkingAccuracy,
    required this.trafficRuleAwareness,
    required this.confidence,
    required this.brakingAcceleration,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'steeringControl': steeringControl,
      'parkingAccuracy': parkingAccuracy,
      'trafficRuleAwareness': trafficRuleAwareness,
      'confidence': confidence,
      'brakingAcceleration': brakingAcceleration,
      'lastUpdated': lastUpdated,
    };
  }

  factory StudentSkillModel.fromMap(Map<String, dynamic> map) {
    return StudentSkillModel(
      studentId: map['studentId'] ?? '',
      steeringControl: map['steeringControl'] ?? 0,
      parkingAccuracy: map['parkingAccuracy'] ?? 0,
      trafficRuleAwareness: map['trafficRuleAwareness'] ?? 0,
      confidence: map['confidence'] ?? 0,
      brakingAcceleration: map['brakingAcceleration'] ?? 0,
      lastUpdated: map['lastUpdated'] ?? '',
    );
  }

  // Factory for empty/initial state
  factory StudentSkillModel.initial(String studentId) {
    return StudentSkillModel(
      studentId: studentId,
      steeringControl: 3,
      parkingAccuracy: 2,
      trafficRuleAwareness: 4,
      confidence: 5,
      brakingAcceleration: 3,
      lastUpdated: DateTime.now().toString(),
    );
  }
}
