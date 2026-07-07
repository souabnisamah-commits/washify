import 'dart:html' as html;

/// Manages user session persistence using HTML localStorage.
/// Stores only the user ID — the full profile is re-fetched from Firestore on restore.
class SessionService {
  static const String _keyUserId = 'washify_session_user_id';

  static final SessionService _instance = SessionService._();

  SessionService._();

  /// Returns the singleton instance.
  static SessionService get instance => _instance;

  /// Must be called once at app startup (in main.dart).
  static Future<SessionService> init() async {
    return _instance;
  }

  /// Persist the logged-in user's ID.
  Future<void> saveSession(String userId) async {
    try {
      html.window.localStorage[_keyUserId] = userId;
    } catch (e) {
      print('Error saving to localStorage: $e');
    }
  }

  /// Retrieve the stored user ID, or null if no session exists.
  String? getSavedUserId() {
    try {
      return html.window.localStorage[_keyUserId];
    } catch (e) {
      print('Error reading from localStorage: $e');
      return null;
    }
  }

  /// Clear the saved session (on logout).
  Future<void> clearSession() async {
    try {
      html.window.localStorage.remove(_keyUserId);
    } catch (e) {
      print('Error clearing localStorage: $e');
    }
  }
}
