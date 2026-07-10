import 'package:shared_preferences/shared_preferences.dart';

/// Manages user session persistence using SharedPreferences.
/// Stores only the user ID — the full profile is re-fetched from Firestore on restore.
class SessionService {
  static const String _keyUserId = 'washify_session_user_id';

  static final SessionService _instance = SessionService._();
  static late SharedPreferences _prefs;

  SessionService._();

  /// Returns the singleton instance.
  static SessionService get instance => _instance;

  /// Must be called once at app startup (in main.dart).
  static Future<SessionService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _instance;
  }

  /// Persist the logged-in user's ID.
  Future<void> saveSession(String userId) async {
    try {
      await _prefs.setString(_keyUserId, userId);
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  /// Retrieve the stored user ID, or null if no session exists.
  String? getSavedUserId() {
    try {
      return _prefs.getString(_keyUserId);
    } catch (e) {
      print('Error reading session: $e');
      return null;
    }
  }

  /// Clear the saved session (on logout).
  Future<void> clearSession() async {
    try {
      await _prefs.remove(_keyUserId);
    } catch (e) {
      print('Error clearing session: $e');
    }
  }
}
