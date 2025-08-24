import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/quiz_provider.dart';
import '../models/course_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leaderboardProvider = context.read<LeaderboardProvider>();
      final authProvider = context.read<AuthProvider>();
      final quizProvider = context.read<QuizProvider>();

      // Load leaderboard
      if (leaderboardProvider.globalLeaderboard.isEmpty &&
          !leaderboardProvider.isLoading) {
        leaderboardProvider.loadGlobalLeaderboard();
      }

      // Load user stats
      if (authProvider.user != null) {
        leaderboardProvider.loadUserCoursePoints(authProvider.user!.id);
      }

      // Load courses
      if (quizProvider.courses.isEmpty && !quizProvider.isLoading) {
        quizProvider.loadCourses();
      }

      // Optional: Refresh data
      leaderboardProvider.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = context.watch<LeaderboardProvider>();
    final authProvider = context.watch<AuthProvider>();
    final quizProvider = context.watch<QuizProvider>();
    final user = authProvider.user;
    
    // Calculate total points from leaderboard data if user exists
    dynamic totalPoints = user?.totalPoints ?? 0;
    if (user != null && leaderboardProvider.globalLeaderboard.isNotEmpty) {
      final userLeaderboardItem = leaderboardProvider.globalLeaderboard
          .where((item) => item.username == user.username)
          .firstOrNull;
      if (userLeaderboardItem != null) {
        totalPoints = userLeaderboardItem.totalPoints;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Leaderboard',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await leaderboardProvider.refresh();
            if (user != null) {
              await leaderboardProvider.loadUserCoursePoints(user.id);
            }
            if (quizProvider.courses.isEmpty) {
              await quizProvider.loadCourses();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // INDIVIDUAL LEADERBOARD
                Text(
                  'Your Stats',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                if (user == null)
                  Text(
                    'Login to see your stats.',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  )
                else
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Points: $totalPoints',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Points by Course:',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...quizProvider.courses.map((course) {
                            final points =
                                leaderboardProvider.userCoursePoints[course
                                    .id] ??
                                0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.book,
                                    size: 18,
                                    color: const Color(0xFF6C63FF),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      course.title,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$points pts',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),

                // GLOBAL LEADERBOARD
                Text(
                  'Global Leaderboard',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
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
                        itemCount: leaderboardProvider.globalLeaderboard.length,
                        itemBuilder: (context, index) {
                          final item =
                              leaderboardProvider.globalLeaderboard[index];
                          final isTop3 = index < 3;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isTop3
                                  ? [
                                      const Color(0xFFFFD700), // Gold
                                      const Color(0xFFC0C0C0), // Silver
                                      const Color(0xFFCD7F32), // Bronze
                                    ][index]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                if (isTop3)
                                  BoxShadow(
                                    color: [
                                      const Color(0xFFFFD700).withOpacity(0.3),
                                      const Color(0xFFC0C0C0).withOpacity(0.3),
                                      const Color(0xFFCD7F32).withOpacity(0.3),
                                    ][index],
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: ListTile(
                              leading: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: isTop3
                                        ? [
                                            const Color(0xFFFFD700),
                                            const Color(0xFFC0C0C0),
                                            const Color(0xFFCD7F32),
                                          ][index]
                                        : const Color(0xFF6C63FF),
                                    child: isTop3
                                        ? Icon(
                                            [
                                              Icons.emoji_events,
                                              Icons.emoji_events,
                                              Icons.emoji_events,
                                            ][index],
                                            color: Colors.white,
                                            size: 28,
                                          )
                                        : Text(
                                            '${item.rank}',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                  ),
                                  if (user != null &&
                                      item.username == user.username)
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(
                                item.username,
                                style: GoogleFonts.poppins(
                                  color: isTop3
                                      ? Colors.white
                                      : const Color(0xFF6C63FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: Text(
                                '${item.totalPoints} pts',
                                style: GoogleFonts.poppins(
                                  color: isTop3 ? Colors.white : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
