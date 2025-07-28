class CatchUpTask {
  final String? id;  // Optionnel, si généré côté backend
  final String taskName;
  final String catchUpDay;
  final int durationMinutes;
  final bool isChecked;
  final String originalTaskId;

  CatchUpTask({
    this.id,
    required this.taskName,
    required this.catchUpDay,
    required this.durationMinutes,
    required this.isChecked,
    required this.originalTaskId,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'taskName': taskName,
        'catchUpDay': catchUpDay,
        'durationMinutes': durationMinutes,
        'isChecked': isChecked,
        'originalTaskId': originalTaskId,
      };

  factory CatchUpTask.fromJson(Map<String, dynamic> json) => CatchUpTask(
        id: json['id'],
        taskName: json['taskName'],
        catchUpDay: json['catchUpDay'],
        durationMinutes: json['durationMinutes'],
        isChecked: json['isChecked'],
        originalTaskId: json['originalTaskId'],
      );
}
