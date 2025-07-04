import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  static SupabaseClient get client => _client;

  // Auth methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );

    if (response.user != null) {
      await _client.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'username': username,
        'total_points': 0,
      });
    }

    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Database methods
  static Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await _client
        .from('courses')
        .select()
        .order('title');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getQuestions({
    required String courseId,
    required String difficulty,
    int? limit,
  }) async {
    PostgrestTransformBuilder<PostgrestList> query = _client
        .from('questions')
        .select()
        .eq('course_id', courseId)
        .eq('difficulty', difficulty);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> saveScore({
    required String userId,
    required String courseId,
    required String difficulty,
    required int score,
    required int totalQuestions,
    required int pointsEarned,
  }) async {
    await _client.from('scores').insert({
      'user_id': userId,
      'course_id': courseId,
      'difficulty': difficulty,
      'score': score,
      'total_questions': totalQuestions,
      'points_earned': pointsEarned,
    });

    // Update user's total points
    await _client.rpc('update_user_points', params: {
      'user_id': userId,
      'points_to_add': pointsEarned,
    });
  }

  static Future<List<Map<String, dynamic>>> getLeaderboard({
    int limit = 10,
  }) async {
    final response = await _client
        .from('users')
        .select('username, total_points')
        .order('total_points', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  static Future<List<Map<String, dynamic>>> getUserCourseScores(String userId) async {
    final response = await _client
        .from('scores')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }
}