// File: lib/data/models/person.model.dart
class Person {
  final int? id;
  final String name;
  final String embedding; // JSON string of List<double>
  final String? thumbnailPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double confidenceThreshold;

  Person({
    this.id,
    required this.name,
    required this.embedding,
    this.thumbnailPath,
    required this.createdAt,
    required this.updatedAt,
    this.confidenceThreshold = 0.7,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'embedding': embedding,
      'thumbnail_path': thumbnailPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'confidence_threshold': confidenceThreshold,
    };
  }

  // Create Person from Map (database result)
  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      embedding: map['embedding'] ?? '',
      thumbnailPath: map['thumbnail_path'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      confidenceThreshold: map['confidence_threshold']?.toDouble() ?? 0.7,
    );
  }

  // Create copy with updated fields
  Person copyWith({
    int? id,
    String? name,
    String? embedding,
    String? thumbnailPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? confidenceThreshold,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      embedding: embedding ?? this.embedding,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
    );
  }

  @override
  String toString() {
    return 'Person(id: $id, name: $name, createdAt: $createdAt)';
  }
}
