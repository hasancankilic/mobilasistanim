import 'package:proje_ilk/constants/task_type.dart';

class Task {
  int? id;
  String username; // Kullanıcı adı bilgisini ekleyin
  String title;
  String description;
  bool isCompleted;
  TaskType type;
  DateTime? dateTime;

  Task({
    this.id,
    required this.username,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.type,
    this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username, // Kullanıcı adını ekle
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'type': type.toString(),
      'date_time': dateTime?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    var typeString = map['type'];
    TaskType type = TaskType.not;
    if (typeString != null) {
      type = TaskType.values.firstWhere((e) => e.toString() == typeString, orElse: () => TaskType.not);
    }

    return Task(
      id: map['id'],
      username: map['username'], // Kullanıcı adını al
      title: map['title'],
      description: map['description'],
      isCompleted: map['is_completed'] == 1,
      type: type,
      dateTime: map['date_time'] != null ? DateTime.parse(map['date_time']) : null,
    );
  }

  Map<String, dynamic> toMapExceptId() {
    return {
      'username': username, // Kullanıcı adını ekle
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'type': type.toString(),
      'date_time': dateTime?.toIso8601String(),
    };
  }
}
