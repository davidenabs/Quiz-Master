import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
  @override
  void initState() {
    super.initState();

    // Schedule after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = context.read<QuizProvider>();
      final leaderboardProvider = context.read<LeaderboardProvider>();

      if (quizProvider.courses.isEmpty && !quizProvider.isLoading) {
        quizProvider.loadCourses();
      }

      if (leaderboardProvider.globalLeaderboard.isEmpty &&
          !leaderboardProvider.isLoading) {
        leaderboardProvider.loadGlobalLeaderboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final quizProvider = context.watch<QuizProvider>();
    final leaderboardProvider = context.watch<LeaderboardProvider>();

    // Load courses if not loaded
    // if (quizProvider.courses.isEmpty && !quizProvider.isLoading) {
    //   quizProvider.loadCourses();
    // }

    // // Load leaderboard if not loaded
    // if (leaderboardProvider.globalLeaderboard.isEmpty &&
    //     !leaderboardProvider.isLoading) {
    //   leaderboardProvider.loadGlobalLeaderboard();
    // }

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
              // Optionally, navigate to login screen
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await quizProvider.loadCourses();
            await leaderboardProvider.loadGlobalLeaderboard();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome
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

                if (quizProvider.isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (quizProvider.error != null)
                  Center(
                    child: Text(
                      quizProvider.error!,
                      style: GoogleFonts.poppins(color: Colors.redAccent),
                    ),
                  )
                else if (quizProvider.courses.isEmpty)
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
                    itemCount: quizProvider.courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final course = quizProvider.courses[index];
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

                // Leaderboard Preview
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
