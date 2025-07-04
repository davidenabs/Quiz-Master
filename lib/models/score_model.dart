import 'package:quiz_app/models/question_model.dart';

class ScoreModel {
  final String id;
  final String userId;
  final String courseId;
  final Difficulty difficulty;
  final int score;
  final int totalQuestions;
  final int pointsEarned;
  final DateTime completedAt;

  ScoreModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.pointsEarned,
    required this.completedAt,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      difficulty: _parseDifficulty(json['difficulty']),
      score: json['score'],
      totalQuestions: json['total_questions'],
      pointsEarned: json['points_earned'],
      completedAt: DateTime.parse(json['completed_at']),
    );
  }

  static Difficulty _parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Difficulty.easy;
      case 'intermediate':
        return Difficulty.intermediate;
      case 'advanced':
        return Difficulty.advanced;
      default:
        return Difficulty.easy;
    }
  }

  double get percentage => (score / totalQuestions) * 100;
  bool get isPassed => percentage >= 70;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'difficulty': difficulty.name,
      'score': score,
      'total_questions': totalQuestions,
      'points_earned': pointsEarned,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}