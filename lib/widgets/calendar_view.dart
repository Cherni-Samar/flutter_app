// lib/features/calendar/widgets/calendar_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../models/task.dart';
import '../../../controllers/task_controller.dart';

// 🔄 Classe renommée pour éviter le conflit avec l'enum CalendarView de Syncfusion
class CustomCalendarView extends StatelessWidget {
  final Function(CalendarTapDetails) onTap;

  CustomCalendarView({super.key, required this.onTap});

  final TaskController taskController = Get.find<TaskController>();

  List<Appointment> _buildAppointments(List<Task> tasks) {
    return tasks.map((task) {
      final start = DateTime.tryParse(task.day);
      if (start == null) return null;
      final end = start.add(Duration(minutes: task.durationMinutes));

      Color color;
      if (task.isChecked) {
        color = Colors.grey[400]!;
      } else {
        color = task.isModified ? Colors.green.withOpacity(0.8) : Colors.blue[700]!;
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

  String _formatHour(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Obx(() {
        final appointments = _buildAppointments(taskController.tasks.toList());
        return SfCalendar(
          view: CalendarView.workWeek, // ✅ correctement reconnu maintenant
          dataSource: TaskDataSource(appointments),
          initialDisplayDate: DateTime.now(),
          onTap: onTap,
          todayHighlightColor: Colors.blue[700],
          headerHeight: 0,
          viewHeaderStyle: ViewHeaderStyle(
            dayTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            dateTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            backgroundColor: Colors.grey[200],
          ),
          timeSlotViewSettings: const TimeSlotViewSettings(
            timeInterval: Duration(minutes: 30),
            timeIntervalHeight: 70,
            timeFormat: 'HH:mm',
            startHour: 6,
            endHour: 20,
            nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
            timeTextStyle: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
          appointmentBuilder: (context, details) {
            final appointment = details.appointments.first as Appointment;
            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: appointment.color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appointment.subject,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatHour(appointment.startTime)} - ${_formatHour(appointment.endTime)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ✅ Pas besoin de changer cette classe
class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Appointment> source) {
    appointments = source;
  }
}
