import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/tasks_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import '../task/add_task_screen.dart';
import '../task/edit_task_screen.dart';
import '../task/task_details_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasksController = Get.put(TasksController());
    final authController  = Get.find<AuthController>();

    final dark   = Theme.of(context).brightness == Brightness.dark;
    final bg     = dark ? const Color(0xFF0D1117) : const Color(0xFFF7F8FF);
    final sub    = dark ? Colors.white38 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: sub),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Obx(() => Row(
              children: [
                _StatCard('Active',    '${tasksController.activeTasksCount}',    const Color(0xFF4F46E5), dark),
                const SizedBox(width: 10),
                _StatCard('Done',      '${tasksController.completedTasksCount}', const Color(0xFF10B981), dark),
                const SizedBox(width: 10),
                _StatCard('Total',     '${tasksController.tasks.length}',        const Color(0xFFF59E0B), dark),
              ],
            )),
          ),

          const SizedBox(height: 12),
          Obx(() => SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['all', 'active', 'completed'].map((s) {
                final sel = tasksController.filterStatus.value == s;
                return GestureDetector(
                  onTap: () => tasksController.setFilterStatus(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: sel ? kAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: sel ? kAccent
                              : (dark ? Colors.white12 : const Color(0xFFE5E7EB))),
                    ),
                    child: Center(
                      child: Text(s.capitalizeFirst!,
                          style: TextStyle(
                              color: sel ? Colors.white : sub,
                              fontSize: 13,
                              fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                    ),
                  ),
                );
              }).toList(),
            ),
          )),

          const SizedBox(height: 8),

          Expanded(
            child: Obx(() {
              if (tasksController.isLoading.value && tasksController.tasks.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: kAccent));
              }
              final list = tasksController.filteredTasks;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: sub),
                      const SizedBox(height: 12),
                      Text('No tasks yet',
                          style: TextStyle(color: sub, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Tap + to add one',
                          style: TextStyle(color: sub.withOpacity(0.6), fontSize: 13)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) =>
                    _TaskTile(list[i], tasksController, dark),
              );
            }),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccent,
        onPressed: () => Get.to(() => const AddTaskScreen()),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool dark;
  const _StatCard(this.label, this.value, this.color, this.dark);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(dark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            child: Text(value,
                style: TextStyle(
                    color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          Text(label,
              style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}
class _TaskTile extends StatelessWidget {
  final TaskModel task;
  final TasksController tc;
  final bool dark;
  const _TaskTile(this.task, this.tc, this.dark);

  Color get _pColor {
    switch (task.priority) {
      case 'high':   return const Color(0xFFEF4444);
      case 'medium': return const Color(0xFFF59E0B);
      default:       return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overdue    = task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
    final cardColor  = dark ? const Color(0xFF161B27) : Colors.white;
    final border     = dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E7EB);
    final textColor  = dark ? Colors.white : const Color(0xFF111827);
    final subColor   = dark ? Colors.white38 : const Color(0xFF6B7280);

    return GestureDetector(
      onTap: () => Get.to(() => TaskDetailsScreen(task: task)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => tc.toggleTaskCompletion(task.id, task.isCompleted),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? kAccent : Colors.transparent,
                  border: task.isCompleted
                      ? null
                      : Border.all(color: subColor, width: 1.5),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? subColor
                              : textColor,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough : null,
                          decorationColor: subColor)),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 6, height: 6,
                            decoration: BoxDecoration(color: _pColor, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(task.priority.capitalizeFirst!,
                            style: TextStyle(color: _pColor, fontSize: 11, fontWeight: FontWeight.w600)),
                      ]),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.schedule_outlined, size: 11,
                            color: overdue ? Colors.redAccent : subColor),
                        const SizedBox(width: 3),
                        Text(
                          overdue ? 'Overdue'
                              : DateFormat('MMM d · h:mm a').format(task.dueDate),
                          style: TextStyle(
                              fontSize: 11,
                              color: overdue ? Colors.redAccent : subColor,
                              fontWeight: overdue ? FontWeight.w700 : FontWeight.w400),
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Column(
              children: [
                _Btn(Icons.edit_outlined, kAccent,
                        () => Get.to(() => EditTaskScreen(task: task))),
                const SizedBox(height: 6),
                _Btn(Icons.delete_outline_rounded, Colors.redAccent,
                        () => _confirmDelete(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF161B27) : Colors.white,
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () { tc.deleteTask(task.id); Navigator.pop(ctx); },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Btn(this.icon, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 15),
    ),
  );
}