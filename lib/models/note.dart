import 'dart:convert';

/// Data Model representing a single Note in the application.
class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;
  bool isPinned;
  int colorValue;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.colorValue = 0xFFFFFFFF,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
      colorValue: json['colorValue'] as int? ?? 0xFFFFFFFF,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'colorValue': colorValue,
    };
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    int? colorValue,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  static String encodeList(List<Note> notes) {
    return json.encode(notes.map((n) => n.toJson()).toList());
  }

  static List<Note> decodeList(String jsonString) {
    if (jsonString.isEmpty) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.map((item) => Note.fromJson(item as Map<String, dynamic>)).toList();
  }
}
