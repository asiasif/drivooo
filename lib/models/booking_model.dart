class BookingModel {
  String bookingID;
  String userID;
  String userName;
  String date;
  String slotID;
  String timeRange;
  String? bookingTime; // Added bookingTime

  BookingModel({
    required this.bookingID,
    required this.userID,
    required this.userName,
    required this.date,
    required this.slotID,
    required this.timeRange,
    this.bookingTime,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingID: map['bookingID'],
      userID: map['userID'],
      userName: map['userName'],
      date: map['date'],
      slotID: map['slotID'],
      timeRange: map['timeRange'],
      bookingTime: map['bookingTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingID': bookingID,
      'userID': userID,
      'userName': userName,
      'date': date,
      'slotID': slotID,
      'timeRange': timeRange,
      'bookingTime': bookingTime,
    };
  }
}
