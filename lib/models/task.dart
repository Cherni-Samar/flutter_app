class Task {
  String task;
  String day; // date+heure iso8601
  int durationMinutes;
  bool isChecked;

  Task({
    required this.task,
    required this.day,
    this.durationMinutes = 60,
    this.isChecked = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        task: json['task'],
        day: json['day'],
        durationMinutes: json['durationMinutes'] ?? 60,
        isChecked: json['isChecked'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'task': task,
        'day': day,
        'durationMinutes': durationMinutes,
        'isChecked': isChecked,
      };
}
