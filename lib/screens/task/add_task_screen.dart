import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/tasks_controller.dart';
import '../../theme/app_theme.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController  = TextEditingController();
  final _formKey         = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _priority       = 'medium';

  final tasksController = Get.find<TasksController>();

  DateTime get _combined => DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute);

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark   = Theme.of(context).brightness == Brightness.dark;
    final bg     = dark ? const Color(0xFF0D1117) : const Color(0xFFF7F8FF);
    final card   = dark ? const Color(0xFF161B27) : Colors.white;
    final border = dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E7EB);
    final title  = dark ? Colors.white : const Color(0xFF111827);
    final sub    = dark ? Colors.white38 : const Color(0xFF6B7280);
    final accentColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18,
              color: dark ? Colors.white70 : const Color(0xFF111827)),
          onPressed: () => Get.back(),
        ),
        title: Text('New Task', style: TextStyle(color: title, fontWeight: FontWeight.bold)),
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
                decoration: const InputDecoration(hintText: 'What needs to be done?'),
                validator: (v) => (v == null || v.isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: TextStyle(color: title, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Add some details... (optional)'),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _pickerTile(
                  context: context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Due Date',
                  value: DateFormat('MMM d, yyyy').format(_selectedDate),
                  card: card, border: border, title: title, sub: sub, accent: accentColor,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                )),
                const SizedBox(width: 12),
                Expanded(child: _pickerTile(
                  context: context,
                  icon: Icons.access_time_outlined,
                  label: 'Due Time',
                  value: _selectedTime.format(context),
                  card: card, border: border, title: title, sub: sub, accent: accentColor,
                  onTap: () async {
                    final picked = await showTimePicker(
                        context: context, initialTime: _selectedTime);
                    if (picked != null) setState(() => _selectedTime = picked);
                  },
                )),
              ]),
              const SizedBox(height: 24),
              Text('Priority', style: TextStyle(color: sub, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: sel ? c.withOpacity(0.12) : card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sel ? c : border),
                      ),
                      child: Column(children: [
                        Container(width: 8, height: 8,
                            decoration: BoxDecoration(
                                color: sel ? c : sub.withOpacity(0.3), shape: BoxShape.circle)),
                        const SizedBox(height: 6),
                        Text(p.capitalizeFirst!,
                            style: TextStyle(
                                color: sel ? c : sub, fontSize: 13,
                                fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                      ]),
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 40),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: tasksController.isLoading.value
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      tasksController.addTask(
                        title: _titleController.text.trim(),
                        description: _descController.text.trim(),
                        dueDate: _combined,
                        priority: _priority,
                      );
                      Get.back();
                    }
                  },
                  child: tasksController.isLoading.value
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5
                    ),
                  )
                      : const Text(
                    'Create Task',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerTile({
    required BuildContext context,
    required IconData icon,
    required String label, required String value,
    required Color card, required Color border,
    required Color title, required Color sub,
    required Color accent,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(children: [
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 8),
              Flexible(child: Text(value, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: title, fontSize: 13, fontWeight: FontWeight.w600))),
            ]),
          ]),
        ),
      );
}