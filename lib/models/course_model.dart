class CourseModel {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}