enum ModificationType { original, movedFrom, movedTo }

class Task {
  String task;
  String day;
  int durationMinutes;
  bool isChecked;
  ModificationType modificationType;

  Task({
    required this.task,
    required this.day,
    this.durationMinutes = 60,
    this.isChecked = false,
    this.modificationType = ModificationType.original,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        task: json['task'],
        day: json['day'],
        durationMinutes: json['durationMinutes'] ?? 60,
        isChecked: json['isChecked'] ?? false,
        modificationType: json['modificationType'] != null
            ? ModificationType.values.firstWhere(
                // ignore: prefer_interpolation_to_compose_strings
                (e) => e.toString() == 'ModificationType.' + json['modificationType'],
                orElse: () => ModificationType.original,
              )
            : ModificationType.original,
      );

  Map<String, dynamic> toJson() => {
        'task': task,
        'day': day,
        'durationMinutes': durationMinutes,
        'isChecked': isChecked,
        'modificationType': modificationType.toString().split('.').last,
      };
}
