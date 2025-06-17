class Task {
  String task;
  String day;
  bool isChecked;

  Task({required this.task, required this.day, this.isChecked = false});

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    task: json['task'],
    day: json['day'],
    isChecked: json['isChecked'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'task': task,
    'day': day,
    'isChecked': isChecked,
  };
}
