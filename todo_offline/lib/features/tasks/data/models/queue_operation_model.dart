import 'dart:convert';

enum OperationType { create, update, delete }

class QueueOperationModel {
  final String id;
  final String entity;
  final String entityId;
  final OperationType operation;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attemptCount;
  final String? lastError;
  final DateTime? nextRetryAt;

  QueueOperationModel({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    this.attemptCount = 0,
    this.lastError,
    this.nextRetryAt,
  });

  factory QueueOperationModel.fromMap(Map<String, dynamic> map) {
    return QueueOperationModel(
      id: map['id'],
      entity: map['entity'],
      entityId: map['entityId'],
      operation: _operationFromString(map['operation']),
      payload: json.decode(map['payload']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      attemptCount: map['attemptCount'],
      lastError: map['lastError'],
      nextRetryAt: map['nextRetryAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['nextRetryAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity': entity,
      'entityId': entityId,
      'operation': _operationToString(operation),
      'payload': json.encode(payload),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'attemptCount': attemptCount,
      'lastError': lastError,
      'nextRetryAt': nextRetryAt?.millisecondsSinceEpoch,
    };
  }

  QueueOperationModel copyWith({
    String? id,
    String? entity,
    String? entityId,
    OperationType? operation,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? attemptCount,
    String? lastError,
    DateTime? nextRetryAt,
  }) {
    return QueueOperationModel(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }

  static OperationType _operationFromString(String value) {
    return OperationType.values.firstWhere(
      (e) => e.toString() == 'OperationType.${value.toLowerCase()}',
      orElse: () => throw ArgumentError('Invalid operation type: $value'),
    );
  }

  static String _operationToString(OperationType operation) {
    return operation.toString().split('.').last;
  }
}
