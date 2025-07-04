import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class LeaderboardItem {
  final String username;
  final int totalPoints;
  final int rank;

  LeaderboardItem({
    required this.username,
    required this.totalPoints,
    required this.rank,
  });
}

class LeaderboardProvider extends ChangeNotifier {
  List<LeaderboardItem> _globalLeaderboard = [];
  Map<String, int> _userCoursePoints = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<LeaderboardItem> get globalLeaderboard => _globalLeaderboard;
  Map<String, int> get userCoursePoints => _userCoursePoints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load global leaderboard
  Future<void> loadGlobalLeaderboard() async {
    _setLoading(true);
    try {
      final leaderboardData = await SupabaseService.getLeaderboard(limit: 100);
      _globalLeaderboard = leaderboardData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return LeaderboardItem(
          username: data['username'],
          totalPoints: data['total_points'],
          rank: index + 1,
        );
      }).toList();
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load user's course-specific points
  Future<void> loadUserCoursePoints(String userId) async {
    try {
      final scores = await SupabaseService.getUserCourseScores(userId);
      _userCoursePoints = {};

      for (final score in scores) {
        final courseId = score['course_id'] as String;
        final points = score['points_earned'] as int;
        _userCoursePoints[courseId] =
            (_userCoursePoints[courseId] ?? 0) + points;
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Get user's rank in global leaderboard
  int getUserRank(String username) {
    final userItem = _globalLeaderboard
        .where((item) => item.username == username)
        .firstOrNull;
    return userItem?.rank ?? -1;
  }

  // Get top N users
  List<LeaderboardItem> getTopUsers(int count) {
    return _globalLeaderboard.take(count).toList();
  }

  // Refresh leaderboard data
  Future<void> refresh() async {
    await loadGlobalLeaderboard();
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
}
