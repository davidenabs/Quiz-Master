import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/course_model.dart';
import '../models/score_model.dart';
import '../services/quiz_service.dart';
import '../services/supabase_service.dart';

class QuizProvider extends ChangeNotifier {
  List<CourseModel> _courses = [];
  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  List<String> _userAnswers = [];
  Timer? _timer;
  int _timeRemaining = 30;
  bool _isLoading = false;
  String? _error;
  ScoreModel? _lastScore;

  // Getters
  List<CourseModel> get courses => _courses;
  List<QuestionModel> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;
  List<String> get userAnswers => _userAnswers;
  int get timeRemaining => _timeRemaining;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ScoreModel? get lastScore => _lastScore;
  bool get isQuizComplete => _currentQuestionIndex >= _questions.length;
  double get progress => _questions.isEmpty
      ? 0.0
      : (_currentQuestionIndex + 1) / _questions.length;

  // Load courses
  bool _hasLoadedCourses = false;

  Future<List<CourseModel>> loadCourses() async {
    // if (_hasLoadedCourses) return;

    _setLoading(true);
    try {
      final coursesData = await SupabaseService.getCourses();
      _courses = coursesData.map((data) => CourseModel.fromJson(data)).toList();
      _hasLoadedCourses = true;
      return _courses;
      // _clearError();
      // notifyListeners();
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Start quiz
  Future<void> startQuiz({
    required String courseId,
    required Difficulty difficulty,
  }) async {
    _setLoading(true);
    try {
      _questions = await QuizService.getQuizQuestions(
        courseId: courseId,
        difficulty: difficulty,
      );

      _currentQuestionIndex = 0;
      _userAnswers = List.filled(_questions.length, '');
      _startTimer();
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Start timer for current question
  void _startTimer() {
    _timer?.cancel();
    _timeRemaining = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _nextQuestion();
      }
    });
  }

  // Answer current question
  void answerQuestion(String answer) {
    if (_currentQuestionIndex < _userAnswers.length) {
      _userAnswers[_currentQuestionIndex] = answer;
      notifyListeners();
    }
  }

  // Move to next question
  void _nextQuestion() {
    _timer?.cancel();
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _startTimer();
    } else {
      _finishQuiz();
    }
    notifyListeners();
  }

  // Submit current answer and move to next
  void submitAnswer(String answer) {
    answerQuestion(answer);
    _nextQuestion();
  }

  // Finish quiz and calculate score
  void _finishQuiz() {
    _timer?.cancel();
    notifyListeners();
  }

  // Save quiz results
  Future<void> saveQuizResults({
    required String userId,
    required String courseId,
    required Difficulty difficulty,
  }) async {
    final score = QuizService.calculateScore(_userAnswers, _questions);

    try {
      _lastScore = await QuizService.saveQuizResult(
        userId: userId,
        courseId: courseId,
        difficulty: difficulty,
        score: score,
        totalQuestions: _questions.length,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Reset quiz state
  void resetQuiz() {
    _timer?.cancel();
    _questions.clear();
    _userAnswers.clear();
    _currentQuestionIndex = 0;
    _timeRemaining = 30;
    _lastScore = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
