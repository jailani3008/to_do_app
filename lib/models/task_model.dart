class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      priority: map['priority'] ?? 'Low',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}