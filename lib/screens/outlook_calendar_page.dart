import 'package:flutter/material.dart';
import 'package:flutter_application_1/dialogs/add_task_dialog.dart';
import 'package:flutter_application_1/dialogs/task_list_dialog.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:flutter_application_1/widgets/calendar_header.dart';
import 'package:flutter_application_1/widgets/new_task_fab.dart';
import 'package:flutter_application_1/widgets/calendar_view.dart'; // ✅ Import corrigé
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class OutlookCalendarPage extends StatefulWidget {
  const OutlookCalendarPage({
    super.key,
    required RxList<Task> tasks,
    required Null Function(dynamic updatedTasks) onTasksUpdated,
  });

  @override
  State<OutlookCalendarPage> createState() => _OutlookCalendarPageState();
}

class _OutlookCalendarPageState extends State<OutlookCalendarPage> {
  DateTime? _selectedDate;

  void _onCalendarTapped(CalendarTapDetails details) {
    final date = details.date;
    if (date == null) return;

    setState(() {
      _selectedDate = date;
    });

    if (details.targetElement == CalendarElement.calendarCell) {
      showAddTaskDialog(context, date);
    } else {
      showTaskListDialog(context, date);
    }
  }

  void _onFabPressed() {
    final date = _selectedDate ?? DateTime.now();
    showAddTaskDialog(context, date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const CalendarHeader(),
            Expanded(
              child: CustomCalendarView(
                onTap: _onCalendarTapped,
              ), // ✅ Utilisation du nouveau nom
            ),
          ],
        ),
      ),
      floatingActionButton: NewTaskFab(onPressed: _onFabPressed),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
