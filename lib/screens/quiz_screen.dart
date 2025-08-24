import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/course_model.dart';
import '../models/question_model.dart';
import '../models/score_model.dart';
import '../providers/quiz_provider.dart';
import '../providers/auth_provider.dart';
import 'results_screen.dart';
import '../widgets/timer_widget.dart';
import '../widgets/progress_indicator_widget.dart';

class QuizScreen extends StatefulWidget {
  final CourseModel course;
  final Difficulty difficulty;

  const QuizScreen({super.key, required this.course, required this.difficulty});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizProvider quizProvider;
  late AuthProvider authProvider;
  late int totalQuestions;
  bool isLoading = true;
  bool isSubmitting = false;
  List<QuestionModel> questions = [];
  int currentIndex = 0;
  List<String> userAnswers = [];
  int timerSeconds = 30;
  int timeRemaining = 30;
  Timer? timer;
  // Removed shuffling to fix scoring issues

  @override
  void initState() {
    super.initState();
    quizProvider = context.read<QuizProvider>();
    authProvider = context.read<AuthProvider>();
    _startQuiz();
  }

  Future<void> _startQuiz() async {
    setState(() {
      isLoading = true;
    });
    await quizProvider.startQuiz(
      courseId: widget.course.id,
      difficulty: widget.difficulty,
    );
    questions = List<QuestionModel>.from(quizProvider.questions);

    if (questions.isEmpty) {
      setState(() {
        isLoading = false;
      });
      // Handle no questions available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No questions available for this course.')),
      );
      // Optionally, navigate back or to a different screen
      Navigator.of(context).pop();
      return;
    }

    // Shuffle only questions, keep options in original order for correct scoring
    questions.shuffle(Random());

    totalQuestions = questions.length;
    userAnswers = List.filled(totalQuestions, '');
    currentIndex = 0;
    _startTimer();
    setState(() {
      isLoading = false;
    });
  }

  void _startTimer() {
    timer?.cancel();
    timeRemaining = timerSeconds;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        // When timer expires, automatically move to next question
        _goToNextQuestion();
      }
    });
  }

  void _selectAnswer(String answer) {
    // Store the display letter for UI, but we'll convert to original when scoring
    setState(() {
      userAnswers[currentIndex] = answer; // Store the display letter
    });
    print({
      "Selected Answer (Display)": answer,
      "Original Answer": '',
    });
  }

  void _goToNextQuestion() {
    timer?.cancel();

    if (currentIndex < totalQuestions - 1) {
      setState(() {
        currentIndex++;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    setState(() {
      isSubmitting = true;
    });
    final userId = authProvider.user?.id ?? '';
    // await quizProvider.saveQuizResults(
    //   userId: userId,
    //   courseId: widget.course.id,
    //   difficulty: widget.difficulty,
    // );
    if (mounted) {
      print({
        'courseId': widget.course.id,
        'difficulty': widget.difficulty,
        'userAnswers': userAnswers,
        'score': quizProvider.lastScore,
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            course: widget.course,
            difficulty: widget.difficulty,
            questions: questions,
            userAnswers: userAnswers,
            // score: quizProvider.lastScore!,
            userId: userId,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    // quizProvider.resetQuiz();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF6C63FF),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final question = questions[currentIndex];
    final options = question.options;
    final selectedAnswer = userAnswers[currentIndex];

    // Store the full option text:
    // void _selectOption(int optionIndex) {
    //   final question = quizProvider.currentQuestion!;
    //   final selectedOptionText = question.options[optionIndex];
    //   quizProvider.answerQuestion(selectedOptionText);
    // }

    // // Or if you want to keep storing letters, make sure your QuestionModel
    // // has a method to convert letters back to option text:

    // // Add this method to QuestionModel:
    // String getOptionByLetter(String letter) {
    //   if (letter.length != 1 ||
    //       !RegExp(r'^[A-D]$').hasMatch(letter.toUpperCase())) {
    //     return letter;
    //   }
    //   final index = letter.toUpperCase().codeUnitAt(0) - 65;
    //   if (index >= 0 && index < options.length) {
    //     return options[index];
    //   }
    //   return letter;
    // }

    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.course.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Q${currentIndex + 1}/$totalQuestions',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timer and Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TimerWidget(
                        timeRemaining: timeRemaining,
                        totalTime: timerSeconds,
                      ),
                      ProgressIndicatorWidget(
                        current: currentIndex + 1,
                        total: totalQuestions,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Question
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        question.questionText,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  ...List.generate(options.length, (i) {
                    final opt = options[i];
                    final optionLetter = _optionLetter(i);
                    final isSelected = selectedAnswer == optionLetter;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Material(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : Border.all(
                                    color: const Color(
                                      0xFF6C63FF,
                                    ).withOpacity(0.2),
                                    width: 1,
                                  ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: isSubmitting
                                ? null
                                : () => _selectAnswer(optionLetter),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isSelected
                                        ? Colors.white
                                        : const Color(0xFF6C63FF),
                                    child: Text(
                                      optionLetter,
                                      style: GoogleFonts.poppins(
                                        color: isSelected
                                            ? const Color(0xFF6C63FF)
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      opt,
                                      style: GoogleFonts.poppins(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF2D3748),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),

                  // Next/Finish Button
                  if (!isSubmitting)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedAnswer.isNotEmpty
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          foregroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          elevation: selectedAnswer.isNotEmpty ? 4 : 0,
                        ),
                        onPressed: selectedAnswer.isNotEmpty
                            ? _goToNextQuestion
                            : null,
                        child: Text(
                          currentIndex == totalQuestions - 1
                              ? 'Finish Quiz'
                              : 'Next Question',
                          style: GoogleFonts.poppins(
                            color: selectedAnswer.isNotEmpty
                                ? const Color(0xFF6C63FF)
                                : const Color(0xFF6C63FF).withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  if (isSubmitting)
                    Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            'Submitting your answers...',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32), // Extra space at bottom
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _optionLetter(int index) {
    // Always returns A, B, C, D for 4 options
    return String.fromCharCode(65 + index);
  }
}
