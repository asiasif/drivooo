class TimeSlotModel {
  String slotID;
  String startTime;
  String endTime;

  TimeSlotModel({
    required this.slotID,
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlotModel.fromMap(Map<String, dynamic> map) {
    return TimeSlotModel(
      slotID: map['slotID'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slotID': slotID,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
