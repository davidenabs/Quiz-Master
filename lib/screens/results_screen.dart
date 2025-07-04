import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course_model.dart';
import '../models/question_model.dart';
import '../models/score_model.dart';
import '../widgets/progress_indicator_widget.dart';

class ResultsScreen extends StatelessWidget {
  final CourseModel course;
  final Difficulty difficulty;
  final List<QuestionModel> questions;
  final List<String> userAnswers;
  final ScoreModel? score;

  const ResultsScreen({
    super.key,
    required this.course,
    required this.difficulty,
    required this.questions,
    required this.userAnswers,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    final int correctCount = 0; //score.correctAnswers;
    final int total = questions.length;
    final double percent = correctCount / total;
    final bool passed = percent >= 0.7;

    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Results',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Score Summary
              Text(
                'Quiz Completed!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$correctCount / $total correct',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ProgressIndicatorWidget(current: correctCount, total: total),
              const SizedBox(height: 24),

              // Congratulatory Message & Badge
              if (passed) ...[
                Icon(Icons.emoji_events, color: Colors.amber, size: 64),
                const SizedBox(height: 8),
                Text(
                  'Congratulations!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You passed the quiz and earned a trophy!',
                  style: GoogleFonts.poppins(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ] else ...[
                Icon(
                  Icons.sentiment_dissatisfied,
                  color: Colors.white70,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep Practicing!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Detailed Breakdown
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Question Breakdown',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final q = questions[index];
                  final userAns = userAnswers[index];
                  final correctAns = q.correctOption;
                  final isCorrect = userAns == correctAns;
                  return Card(
                    color: isCorrect ? Colors.white : Colors.red[50],
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}: ${q.questionText}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Your answer: ',
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                userAns.isEmpty
                                    ? 'No answer'
                                    : _optionText(q, userAns),
                                style: GoogleFonts.poppins(
                                  color: isCorrect
                                      ? Colors.green
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (!isCorrect) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Correct answer: ',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  _optionText(q, correctAns),
                                  style: GoogleFonts.poppins(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (q.explanation != null &&
                              q.explanation!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Explanation:',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              q.explanation!,
                              style: GoogleFonts.poppins(color: Colors.black87),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(Icons.home, color: Colors.white),
                label: Text(
                  'Back to Home',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _optionText(QuestionModel q, String letter) {
    // Map option letter (A, B, C, D) to option text
    if (letter.length != 1 || !RegExp(r'^[A-D]$').hasMatch(letter)) {
      return letter; // Return as is if not a valid option letter
    }
    final idx = letter.codeUnitAt(0) - 65;
    if (idx >= 0 && idx < q.options.length) {
      return '${letter}. ${q.options[idx]}';
    }
    return letter;
  }
}
