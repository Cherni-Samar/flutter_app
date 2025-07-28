class Task {
  String? id;  // changer en String? au lieu de int?
  String task;
  String day;
  int durationMinutes;
  bool isChecked;
  bool isModified;

  Task({
    this.id,
    required this.task,
    required this.day,
    this.durationMinutes = 60,
    this.isChecked = false,
    this.isModified = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id']?.toString(),  // forcer en String
    task: json['task'],
    day: json['day'],
    durationMinutes: int.tryParse(json['durationMinutes'].toString()) ?? 0,
    isChecked: json['isChecked'] ?? false,
    isModified: json['isModified'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'task': task,
    'day': day,
    'durationMinutes': durationMinutes,
    'isChecked': isChecked,
    'isModified': isModified,
  };
}
