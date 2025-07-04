enum Difficulty { easy, intermediate, advanced }

class QuestionModel {
  final String id;
  final String courseId;
  final Difficulty difficulty;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final DateTime createdAt;

  QuestionModel({
    required this.id,
    required this.courseId,
    required this.difficulty,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.createdAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      courseId: json['course_id'],
      difficulty: _parseDifficulty(json['difficulty']),
      questionText: json['question_text'],
      options: [
        json['option_a'],
        json['option_b'],
        json['option_c'],
        json['option_d'],
      ],
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
      createdAt: DateTime.parse(json['created_at']),
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

  int get questionCount {
    switch (difficulty) {
      case Difficulty.easy:
        return 15;
      case Difficulty.intermediate:
        return 25;
      case Difficulty.advanced:
        return 50;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'difficulty': difficulty.name,
      'question_text': questionText,
      'option_a': options[0],
      'option_b': options[1],
      'option_c': options[2],
      'option_d': options[3],
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Add this getter to expose the correct option letter (A, B, C, D)
  String get correctOption {
    // final idx = options.indexOf(answer);
    // if (idx >= 0 && idx < 26) {
    //   return String.fromCharCode(65 + idx); // 65 is 'A'
    // }
    return '';
  }
}
