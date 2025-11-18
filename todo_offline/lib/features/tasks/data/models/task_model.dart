import 'package:uuid/uuid.dart';

class TaskModel {
  final String id;
  final String title;
  final bool completed;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final String? serverId;

  TaskModel({
    String? id,
    required this.title,
    this.completed = false,
    this.deleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = true,
    this.serverId,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    print('\n=== TaskModel.fromMap ===');
    print('Raw map keys: ${map.keys.join(', ')}');

    // Log each field with its type
    map.forEach((key, value) {
      print('  $key: $value (${value?.runtimeType})');
    });

    try {
      // Handle different possible types for boolean fields
      bool parseBool(dynamic value) {
        print('\n[parseBool] Parsing: $value (${value?.runtimeType})');
        if (value == null) {
          print('  [parseBool] Value is null, returning false');
          return false;
        }
        if (value is bool) {
          print('  [parseBool] Value is bool: $value');
          return value;
        }
        if (value is int) {
          print('  [parseBool] Value is int: $value, converting to bool');
          return value == 1;
        }
        if (value is String) {
          print('  [parseBool] Value is String: $value, converting to bool');
          return value.toLowerCase() == 'true' || value == '1';
        }
        print('  [parseBool] Warning: Unknown bool type: ${value.runtimeType}');
        return false;
      }

      // Parse each field individually with error handling
      print('\n[Parsing id]');
      final id = map['id']?.toString() ?? const Uuid().v4();
      print('  [id] Parsed: $id');

      print('\n[Parsing title]');
      final title = map['title']?.toString() ?? '';
      print('  [title] Parsed: $title');

      print('\n[Parsing completed]');
      final completed = parseBool(map['completed']);
      print('  [completed] Final value: $completed');

      print('\n[Parsing deleted]');
      final deleted = parseBool(map['deleted']);
      print('  [deleted] Final value: $deleted');

      DateTime parseDateTime(dynamic value) {
        try {
          print('  [parseDateTime] Parsing: $value (${value?.runtimeType})');
          if (value is DateTime) {
            print('    [parseDateTime] Already DateTime: $value');
            return value;
          }
          if (value is String) {
            print('    [parseDateTime] Parsing String to DateTime');
            return DateTime.parse(value);
          }
          if (value is int) {
            print('    [parseDateTime] Converting int to DateTime');
            return DateTime.fromMillisecondsSinceEpoch(value);
          }
          final error = 'Invalid date format: $value (${value?.runtimeType})';
          print('    [parseDateTime] ERROR: $error');
          throw Exception(error);
        } catch (e) {
          print('  [parseDateTime] Error parsing date $value: $e');
          final now = DateTime.now();
          print('  [parseDateTime] Returning current time: $now');
          return now;
        }
      }

      print('\n[Parsing createdAt]');
      final createdAt = parseDateTime(map['createdAt']);
      print('  [createdAt] Final value: $createdAt');

      print('\n[Parsing updatedAt]');
      final updatedAt = parseDateTime(map['updatedAt']);
      print('  [updatedAt] Final value: $updatedAt');

      print('\n[Parsing isSynced]');
      final isSynced = parseBool(map['isSynced'] ?? true);
      print('  [isSynced] Final value: $isSynced');

      print('\n[Parsing serverId]');
      final serverId = map['serverId']?.toString();
      print('  [serverId] Final value: $serverId');

      return TaskModel(
        id: id,
        title: title,
        completed: completed,
        deleted: deleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isSynced: isSynced,
        serverId: serverId,
      );
    } catch (e, stackTrace) {
      print('\n!!! ERROR in TaskModel.fromMap !!!');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('Map data: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed ? 1 : 0,
      'deleted': deleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'serverId': serverId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    bool? completed,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? serverId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      serverId: serverId ?? this.serverId,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      TaskModel.fromMap(json);
}
