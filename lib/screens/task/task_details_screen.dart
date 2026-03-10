import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/tasks_controller.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import 'edit_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;
  const TaskDetailsScreen({Key? key, required this.task}) : super(key: key);
  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TasksController tasksController;
  late TaskModel _currentTask;

  @override
  void initState() {
    super.initState();
    tasksController = Get.find<TasksController>();
    _currentTask    = widget.task;
  }
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':   return const Color(0xFFEF4444);
      case 'medium': return const Color(0xFFF59E0B);
      case 'low':    return const Color(0xFF10B981);
      default:       return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark   = Theme.of(context).brightness == Brightness.dark;
    final bg     = dark ? const Color(0xFF0D1117) : const Color(0xFFF7F8FF);
    final card   = dark ? const Color(0xFF161B27) : Colors.white;
    final border = dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E7EB);
    final title  = dark ? Colors.white : const Color(0xFF111827);
    final sub    = dark ? Colors.white38 : const Color(0xFF6B7280);
    final pColor = _getPriorityColor(_currentTask.priority);
    final overdue = _currentTask.dueDate.isBefore(DateTime.now()) && !_currentTask.isCompleted;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18,
              color: dark ? Colors.white70 : const Color(0xFF111827)),
          onPressed: () => Get.back(),
        ),
        title: Text('Task Details', style: TextStyle(color: title)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: kAccent, size: 20),
            onPressed: () => Get.to(() => EditTaskScreen(task: _currentTask)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent, size: 20),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(card, border, dark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      tasksController.toggleTaskCompletion(
                          _currentTask.id, _currentTask.isCompleted);
                      setState(() => _currentTask = _currentTask.copyWith(
                          isCompleted: !_currentTask.isCompleted));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentTask.isCompleted ? kAccent : Colors.transparent,
                            border: _currentTask.isCompleted
                                ? null : Border.all(color: sub, width: 1.5),
                          ),
                          child: _currentTask.isCompleted
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentTask.isCompleted ? 'Completed' : 'In Progress',
                          style: TextStyle(
                              color: _currentTask.isCompleted
                                  ? const Color(0xFF10B981) : sub,
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_currentTask.title,
                      style: TextStyle(
                          color: title, fontSize: 20, fontWeight: FontWeight.w800,
                          decoration: _currentTask.isCompleted
                              ? TextDecoration.lineThrough : null,
                          decorationColor: sub)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_currentTask.priority.toUpperCase()} PRIORITY',
                      style: TextStyle(color: pColor, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            _card(card, border, dark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description',
                      style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    _currentTask.description.isEmpty
                        ? 'No description provided.'
                        : _currentTask.description,
                    style: TextStyle(
                        color: _currentTask.description.isEmpty ? sub : title,
                        fontSize: 14, height: 1.5,
                        fontStyle: _currentTask.description.isEmpty
                            ? FontStyle.italic : FontStyle.normal),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            _card(card, border, dark,
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.calendar_today_outlined, color: kAccent, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Due Date & Time',
                            style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEE, MMM d yyyy  ·  h:mm a').format(_currentTask.dueDate),
                          style: TextStyle(color: title, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (overdue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: const Text('Overdue',
                          style: TextStyle(color: Colors.redAccent,
                              fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            _card(card, border, dark,
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.access_time_outlined,
                        color: Color(0xFF10B981), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Created',
                          style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(DateFormat('MMM d, yyyy').format(_currentTask.createdAt),
                          style: TextStyle(color: title, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Color cardColor, Color border, bool dark, {required Widget child}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: dark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 6, offset: const Offset(0, 2))
          ],
        ),
        child: child,
      );

  void _showDeleteConfirmation(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF161B27) : Colors.white,
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              tasksController.deleteTask(_currentTask.id);
              Navigator.pop(ctx);
              Get.back();
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}