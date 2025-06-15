class TimeCapsule {
  String id;
  String title;
  String description;
  String unlockDate;
  String imagepath;
  String userID;

  TimeCapsule({
    required this.id,
    required this.title,
    required this.description,
    required this.unlockDate,
    required this.imagepath,
    required this.userID,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'unlockDate': unlockDate,
      'imagepath': imagepath,
      'userID': userID,
    };
  }

  factory TimeCapsule.fromMap(Map<dynamic, dynamic> map) {
    return TimeCapsule(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      unlockDate: map['unlockDate'] ?? '',
      imagepath: map['imagepath'] ?? '',
      userID: map['userID'] ?? '',
    );
  }
}