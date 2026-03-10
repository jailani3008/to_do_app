import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/tasks_controller.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;
  const EditTaskScreen({super.key, required this.task});
  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _priority;

  late TasksController tasksController;

  @override
  void initState() {
    super.initState();
    tasksController    = Get.find<TasksController>();
    _titleController   = TextEditingController(text: widget.task.title);
    _descController    = TextEditingController(text: widget.task.description);
    _selectedDate      = widget.task.dueDate;
    _selectedTime      = TimeOfDay(
        hour: widget.task.dueDate.hour, minute: widget.task.dueDate.minute);
    _priority          = widget.task.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  DateTime get _combined => DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute);

  @override
  Widget build(BuildContext context) {
    final dark   = Theme.of(context).brightness == Brightness.dark;
    final bg     = dark ? const Color(0xFF0D1117) : const Color(0xFFF7F8FF);
    final card   = dark ? const Color(0xFF161B27) : Colors.white;
    final border = dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E7EB);
    final title  = dark ? Colors.white : const Color(0xFF111827);
    final sub    = dark ? Colors.white38 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18,
              color: dark ? Colors.white70 : const Color(0xFF111827)),
          onPressed: () => Get.back(),
        ),
        title: Text('Edit Task', style: TextStyle(color: title)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextFormField(
                controller: _titleController,
                style: TextStyle(color: title, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Task title'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: TextStyle(color: title, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Description (optional)'),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _pickerTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Due Date',
                  value: DateFormat('MMM d, yyyy').format(_selectedDate),
                  card: card, border: border, title: title, sub: sub,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                )),
                const SizedBox(width: 10),
                Expanded(child: _pickerTile(
                  icon: Icons.access_time_outlined,
                  label: 'Due Time',
                  value: _selectedTime.format(context),
                  card: card, border: border, title: title, sub: sub,
                  onTap: () async {
                    final picked = await showTimePicker(
                        context: context, initialTime: _selectedTime);
                    if (picked != null) setState(() => _selectedTime = picked);
                  },
                )),
              ]),

              const SizedBox(height: 20),

              Text('Priority', style: TextStyle(color: sub, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              Row(children: ['low', 'medium', 'high'].map((p) {
                final colors = {
                  'low': const Color(0xFF10B981),
                  'medium': const Color(0xFFF59E0B),
                  'high': const Color(0xFFEF4444),
                };
                final c   = colors[p]!;
                final sel = _priority == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(right: p != 'high' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? c.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sel ? c : (dark ? Colors.white12 : const Color(0xFFE5E7EB))),
                      ),
                      child: Column(children: [
                        Container(width: 8, height: 8,
                            decoration: BoxDecoration(
                                color: sel ? c : sub, shape: BoxShape.circle)),
                        const SizedBox(height: 5),
                        Text(p.capitalizeFirst!,
                            style: TextStyle(
                                color: sel ? c : sub, fontSize: 12,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                      ]),
                    ),
                  ),
                );
              }).toList()),

              const SizedBox(height: 32),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: tasksController.isLoading.value
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      tasksController.updateTask(
                        taskId: widget.task.id,
                        title: _titleController.text.trim(),
                        description: _descController.text.trim(),
                        dueDate: _combined,
                        priority: _priority,
                      );
                      Get.back();
                    }
                  },
                  child: tasksController.isLoading.value
                      ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              )),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: dark ? Colors.white12 : const Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Discard',
                      style: TextStyle(color: sub, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String label, required String value,
    required Color card, required Color border,
    required Color title, required Color sub,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(icon, size: 14, color: kAccent),
              const SizedBox(width: 6),
              Flexible(child: Text(value, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: title, fontSize: 13, fontWeight: FontWeight.w600))),
            ]),
          ]),
        ),
      );
}