import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/task.dart'; // Assurez-vous d'importer vos propres modèles

// NOTE: J'ajoute ces modèles pour que le code soit exécutable.


class OutlookCalendarPage extends StatefulWidget {
  final List<Task> tasks;
  final Function(List<Task>) onTasksUpdated;

  const OutlookCalendarPage({
    required this.tasks,
    required this.onTasksUpdated,
    Key? key,
  }) : super(key: key);

  @override
  _OutlookCalendarPageState createState() => _OutlookCalendarPageState();
}

class _OutlookCalendarPageState extends State<OutlookCalendarPage> {
  late List<Appointment> _appointments;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _appointments = _buildAppointments(widget.tasks);
  }

  // --- Toute votre logique reste INCHANGÉE ---
  List<Appointment> _buildAppointments(List<Task> tasks) {
    return tasks.map((task) {
      final start = DateTime.tryParse(task.day);
      if (start == null) return null;
      final end = start.add(Duration(minutes: task.durationMinutes));

      Color color;
      if (task.isChecked) {
        color = Colors.grey[400]!;
      } else {
        switch (task.modificationType) {
          case ModificationType.movedFrom:
            color = Colors.red.withOpacity(0.8);
            break;
          case ModificationType.movedTo:
            color = Colors.green.withOpacity(0.8);
            break;
          case ModificationType.original:
          default:
            color = Colors.blue[700]!;
        }
      }

      return Appointment(
        startTime: start,
        endTime: end,
        subject: task.task,
        color: color,
        isAllDay: false,
      );
    }).whereType<Appointment>().toList();
  }

  void _addTaskForDate(DateTime startTime) async {
    final TextEditingController controller = TextEditingController();
    int selectedDuration = 60;
    ModificationType selectedModType = ModificationType.original;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Nouvelle tâche",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: controller,
                    decoration: InputDecoration(
                        hintText: 'Nom de la tâche',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.grey[100])),
                const SizedBox(height: 16),
                Row(children: [
                  const Text("Durée: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<int>(
                      value: selectedDuration,
                      items: [30, 60, 90, 120]
                          .map((d) => DropdownMenuItem(
                              value: d, child: Text('$d min')))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedDuration = val ?? 60))
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  const Text("Type: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<ModificationType>(
                      value: selectedModType,
                      items: ModificationType.values
                          .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.toString().split('.').last)))
                          .toList(),
                      onChanged: (val) => setState(() {
                            if (val != null) selectedModType = val;
                          }))
                ]),
                const SizedBox(height: 8),
                Text('Début à ${_formatHour(startTime)}',
                    style: const TextStyle(
                        fontSize: 14, fontStyle: FontStyle.italic))
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    const Text("Annuler", style: TextStyle(color: Colors.blue))),
            ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text("Ajouter",
                    style: TextStyle(color: Colors.white)))
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final newStart = startTime;
      final newEnd = newStart.add(Duration(minutes: selectedDuration));
      final conflict = _appointments.any(
          (a) => newStart.isBefore(a.endTime) && newEnd.isAfter(a.startTime));
      if (conflict) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("⛔ Conflit : une tâche existe déjà à ce créneau."),
            backgroundColor: Colors.red));
        return;
      }
      final task = Task(
          task: controller.text.trim(),
          day: newStart.toIso8601String(),
          isChecked: false,
          durationMinutes: selectedDuration,
          modificationType: selectedModType);
      setState(() {
        widget.tasks.add(task);
        _appointments = _buildAppointments(widget.tasks);
      });
      widget.onTasksUpdated(widget.tasks);
    }
  }

  String _formatHour(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  String _formatDate(DateTime date) =>
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  List<Task> _tasksForSelectedDate() {
    if (_selectedDate == null) return [];
    final selectedDayString =
        _selectedDate!.toIso8601String().substring(0, 10);
    return widget.tasks
        .where((t) => t.day.startsWith(selectedDayString))
        .toList();
  }

  void _showTaskPopup(DateTime date) async {
    final tasks = _tasksForSelectedDate()..sort((a, b) => a.day.compareTo(b.day));
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text('Tâches pour ${_formatDate(date)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SizedBox(
                width: double.maxFinite,
                child: tasks.isEmpty
                    ? const Center(
                        child: Text('Aucune tâche pour ce jour.',
                            style: TextStyle(fontStyle: FontStyle.italic)))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              title: Text(task.task,
                                  style: const TextStyle(fontSize: 16)),
                              subtitle: Text(task.modificationType
                                  .toString()
                                  .split('.')
                                  .last),
                              trailing: Checkbox(
                                  value: task.isChecked,
                                  activeColor: Colors.blue[700],
                                  onChanged: (val) {
                                    setState(() {
                                      task.isChecked = val ?? false;
                                      _appointments =
                                          _buildAppointments(widget.tasks);
                                      widget.onTasksUpdated(widget.tasks);
                                    });
                                    Navigator.pop(context);
                                  }));
                        })),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Fermer",
                      style: TextStyle(color: Colors.blue)))
            ]));
  }
  // --- Fin de la logique inchangée ---

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    if (widget.tasks.isEmpty) {
      widget.tasks.addAll([
        Task(
            task: "Cours principal",
            day: "2025-06-20T10:00:00Z",
            durationMinutes: 60,
            modificationType: ModificationType.original),
        Task(
            task: "Séance de rattrapage",
            day: "2025-06-20T11:00:00Z",
            durationMinutes: 30,
            modificationType: ModificationType.movedTo),
      ]);
      _appointments = _buildAppointments(widget.tasks);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.blue[700],
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ]),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Aujourd\'hui: ${_formatDate(now)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))
                    ])),
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: SfCalendar(
                  view: CalendarView.workWeek,
                  dataSource: TaskDataSource(_appointments),
                  initialDisplayDate: now,
                  showDatePickerButton: false,
                  showNavigationArrow: false,
                  todayHighlightColor: Colors.blue[700],
                  headerStyle:
                      const CalendarHeaderStyle(textStyle: TextStyle(fontSize: 0)),
                  viewHeaderStyle: ViewHeaderStyle(
                      dayTextStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                      dateTextStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                      backgroundColor: Colors.grey[200]),
                  timeSlotViewSettings: const TimeSlotViewSettings(
                      timeInterval: Duration(minutes: 30),
                      timeIntervalHeight: 70,
                      timeFormat: 'HH:mm',
                      startHour: 6,
                      endHour: 20,
                      timeTextStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500)),
                  
                  // ====================== DÉBUT DE LA CORRECTION ======================
                  // La correction est appliquée uniquement ici, dans la partie visuelle.
                  appointmentBuilder: (context, details) {
                    final appointment = details.appointments.first;
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: appointment.color,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          // FIX : Le SingleChildScrollView est la solution pour l'erreur d'overflow.
                          // Il permet au contenu de défiler si l'espace est insuffisant,
                          // sans changer la logique.
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  appointment.subject,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatHour(appointment.startTime)} - ${_formatHour(appointment.endTime)}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  // ======================= FIN DE LA CORRECTION =======================

                  onTap: (details) {
                    final date = details.date;
                    if (date != null) {
                      setState(() => _selectedDate = date);
                      if (details.targetElement ==
                          CalendarElement.calendarCell) {
                        _addTaskForDate(date);
                      } else {
                        _showTaskPopup(date);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final date = _selectedDate ?? DateTime.now();
          _addTaskForDate(date);
        },
        label: const Text("Nouvelle tâche",
            style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue[700],
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Appointment> source) {
    appointments = source;
  }
}