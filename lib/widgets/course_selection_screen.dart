import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/screens/quiz_screen.dart';
import '../models/course_model.dart';

class CourseSelectionScreen extends StatelessWidget {
  final CourseModel course;
  const CourseSelectionScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          course.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Card(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.book, color: const Color(0xFF6C63FF), size: 48),
                const SizedBox(height: 16),
                Text(
                  course.title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  course.description ?? 'No description available.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
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
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: Text(
                    'Start Quiz',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () async {
                    // Show difficulty selection dialog
                    final difficulty = await showDialog<Difficulty>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Select Difficulty',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.star_border,
                                color: Color(0xFF6C63FF),
                              ),
                              title: Text(
                                'Easy (15 questions)',
                                style: GoogleFonts.poppins(),
                              ),
                              onTap: () =>
                                  Navigator.of(context).pop(Difficulty.easy),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.star_half,
                                color: Color(0xFF6C63FF),
                              ),
                              title: Text(
                                'Intermediate (25 questions)',
                                style: GoogleFonts.poppins(),
                              ),
                              onTap: () => Navigator.of(
                                context,
                              ).pop(Difficulty.intermediate),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.star,
                                color: Color(0xFF6C63FF),
                              ),
                              title: Text(
                                'Advanced (50 questions)',
                                style: GoogleFonts.poppins(),
                              ),
                              onTap: () => Navigator.of(
                                context,
                              ).pop(Difficulty.advanced),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (difficulty != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            course: course,
                            difficulty: difficulty,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
