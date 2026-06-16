class AnnouncementModel {
  String id;
  String title;
  String description;
  String date;
  String type; // 'Info' or 'Urgent'
  String audience; // 'Both', 'Users', 'Instructors'

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.type = 'Info',
    this.audience = 'Both',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'type': type,
      'audience': audience,
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      type: map['type'] ?? 'Info', // Safe fallback for old announcements
      audience: map['audience'] ?? 'Both',
    );
  }
}
