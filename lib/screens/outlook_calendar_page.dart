import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/task.dart';

class OutlookCalendarPage extends StatefulWidget {
  final List<Task> tasks;
  final Function(List<Task>) onTasksUpdated;

  const OutlookCalendarPage({
    required this.tasks,
    required this.onTasksUpdated,
    Key? key,
  }) : super(key: key);

  @override
  State<OutlookCalendarPage> createState() => _OutlookCalendarPageState();
}

class _OutlookCalendarPageState extends State<OutlookCalendarPage> {
  late List<Appointment> _appointments;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _appointments = _buildAppointments(widget.tasks);
  }

  List<Appointment> _buildAppointments(List<Task> tasks) {
    return tasks
        .map((task) {
          final start = DateTime.tryParse(task.day);
          if (start == null) return null;

          final end = start.add(Duration(minutes: task.durationMinutes));
          return Appointment(
            startTime: start,
            endTime: end,
            subject: task.task,
            color: task.isChecked ? Colors.grey.withOpacity(0.5) : Colors.blue,
            isAllDay: false,
            
          );
        })
        .whereType<Appointment>()
        .toList();
  }

  void _addTaskForDate(DateTime startTime) async {
    final TextEditingController controller = TextEditingController();
    int selectedDuration = 60;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            "Nouvelle tâche - ${_formatDate(startTime)} à ${_formatHour(startTime)}",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Nom de la tâche'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Durée: "),
                  DropdownButton<int>(
                    value: selectedDuration,
                    items: [15, 30, 45, 60, 90, 120].map((duration) {
                      return DropdownMenuItem(
                        value: duration,
                        child: Text("$duration min"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedDuration = val);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text("Ajouter"),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final task = Task(
        task: controller.text.trim(),
        day: startTime.toIso8601String(),
        isChecked: false,
        durationMinutes: selectedDuration, // <-- Ici !
      );

      setState(() {
        widget.tasks.add(task);
        _appointments = _buildAppointments(widget.tasks);
      });

      widget.onTasksUpdated(widget.tasks);
    }
  }

  String _formatHour(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  List<Task> _tasksForSelectedDate() {
    if (_selectedDate == null) return [];
    final selectedDayString = _selectedDate!.toIso8601String().substring(0, 10);
    return widget.tasks
        .where((t) => t.day.startsWith(selectedDayString))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final tasksForDay = _tasksForSelectedDate();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 6,
        centerTitle: true,
        title: const Text(
          'Emploi du temps',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SfCalendar(
              view: CalendarView.week,
              dataSource: TaskDataSource(_appointments),
              showDatePickerButton: true,
              showWeekNumber: true,
              todayHighlightColor: const Color.fromARGB(255, 33, 28, 163),
              timeSlotViewSettings: const TimeSlotViewSettings(
                timeInterval: Duration(minutes: 60),
                timeIntervalHeight: 60,
                timeFormat: 'HH:mm',
                startHour: 1,
                endHour: 24,
                dateFormat: 'd',
              ),
              onTap: (calendarTapDetails) {
                if (calendarTapDetails.targetElement ==
                    CalendarElement.calendarCell) {
                  final date = calendarTapDetails.date;
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                    _addTaskForDate(date);
                  }
                }
              },
              appointmentBuilder: (context, details) {
                final Appointment appointment = details.appointments.first;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: appointment.color,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        offset: const Offset(1, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          appointment.subject,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        appointment.color == Colors.grey.withOpacity(0.5)
                            ? Icons.check_circle_outline
                            : Icons.circle_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              border: Border(top: BorderSide(color: Colors.indigo, width: 1.5)),
            ),
            height: 160,
            child: tasksForDay.isEmpty
                ? Center(
                    child: Text(
                      _selectedDate == null
                          ? 'Sélectionnez un jour pour voir les tâches'
                          : 'Aucune tâche pour le ${_formatDate(_selectedDate!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.indigo,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: tasksForDay.length,
                    itemBuilder: (context, index) {
                      final task = tasksForDay[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(task.task),
                          trailing: Checkbox(
                            value: task.isChecked,
                            activeColor: Colors.indigo,
                            onChanged: (val) {
                              setState(() {
                                task.isChecked = val ?? false;
                                _appointments = _buildAppointments(
                                  widget.tasks,
                                );
                                widget.onTasksUpdated(widget.tasks);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final date = _selectedDate ?? DateTime.now();
          _addTaskForDate(date);
        },
        label: const Text("Nouvelle tâche"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Appointment> source) {
    appointments = source;
  }
}
