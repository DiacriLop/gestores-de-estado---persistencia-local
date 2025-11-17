class TaskModel {
  final int? id;
  final String title;
  final String createdAt;
  final String updatedAt;
  final bool completed;
  final bool deleted;

  TaskModel({
    this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.completed = false,
    this.deleted = false,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      completed: map['completed'] == 1,
      deleted: map['deleted'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'completed': completed ? 1 : 0,
      'deleted': deleted ? 1 : 0,
    };
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? createdAt,
    String? updatedAt,
    bool? completed,
    bool? deleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completed: completed ?? this.completed,
      deleted: deleted ?? this.deleted,
    );
  }
}
