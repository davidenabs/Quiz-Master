import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/screens/splash_screen.dart';

import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../models/course_model.dart';
import '../widgets/course_card.dart';
import '../widgets/course_selection_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    final quizProvider = context.read<QuizProvider>();
    final leaderboardProvider = context.read<LeaderboardProvider>();

    quizProvider.loadCourses().then((data) {
      setState(() {
        _courses = data;
        _isLoading = false;
        _error = quizProvider.error;
      });
    });

    // leaderboardProvider.loadGlobalLeaderboard();
  }

  Future<void> _refresh() async {
    final quizProvider = context.read<QuizProvider>();
    final leaderboardProvider = context.read<LeaderboardProvider>();

    final courses = await quizProvider.loadCourses();
    await leaderboardProvider.loadGlobalLeaderboard();

    setState(() {
      _courses = courses;
      _error = quizProvider.error;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final leaderboardProvider = context.watch<LeaderboardProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Quiz Master',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard, color: Colors.white),
            tooltip: 'Leaderboard',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
                // show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You have been signed out.')),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${authProvider.user?.username ?? 'User'} 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to test your knowledge?\nSelect a course to begin!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),

                // Courses Section
                Text(
                  'Available Courses',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (_error != null)
                  Center(
                    child: Text(
                      _error!,
                      style: GoogleFonts.poppins(color: Colors.redAccent),
                    ),
                  )
                else if (_courses.isEmpty)
                  Center(
                    child: Text(
                      'No courses available.',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CourseSelectionScreen(course: course),
                            ),
                          );
                        },
                        child: CourseCard(course: course),
                      );
                    },
                  ),

                const SizedBox(height: 32),

                Text(
                  'Top Learners',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                leaderboardProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : leaderboardProvider.globalLeaderboard.isEmpty
                    ? Text(
                        'No leaderboard data.',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: leaderboardProvider.getTopUsers(3).length,
                        itemBuilder: (context, index) {
                          final item = leaderboardProvider.getTopUsers(
                            3,
                          )[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Text(
                                '${item.rank}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6C63FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              item.username,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Text(
                              '${item.totalPoints} pts',
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),
                          );
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
