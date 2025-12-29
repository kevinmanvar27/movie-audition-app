import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _authTokenKey = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';
  static const String _userProfilePhotoKey = 'user_profile_photo';
  static const String _userRoleIdKey = 'user_role_id'; // Add role ID key
  static const String _userPhoneKey = 'user_phone'; // Add phone key
  static const String _userLocationKey = 'user_location'; // Add location key
  static const String _resetTokenKey = 'reset_token'; // Add reset token key

  // Singleton pattern
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save user session data
  Future<void> saveSession({
    required String token,
    required String name,
    required String email,
    required int userId,
    String? profilePhoto,
    int? roleId, // Add roleId parameter
    String? phone, // Add phone parameter
    String? location, // Add location parameter
  }) async {
    await _prefs.setString(_authTokenKey, token);
    await _prefs.setString(_userNameKey, name);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setInt(_userIdKey, userId);
    if (profilePhoto != null) {
      await _prefs.setString(_userProfilePhotoKey, profilePhoto);
    }
    if (roleId != null) {
      await _prefs.setInt(_userRoleIdKey, roleId);
    }
    if (phone != null) {
      await _prefs.setString(_userPhoneKey, phone);
    }
    if (location != null) {
      await _prefs.setString(_userLocationKey, location);
    }
  }

  // Save reset token
  Future<void> saveResetToken(String resetToken) async {
    await _prefs.setString(_resetTokenKey, resetToken);
  }

  // Get reset token
  String? get resetToken => _prefs.getString(_resetTokenKey);

  // Clear reset token
  Future<void> clearResetToken() async {
    await _prefs.remove(_resetTokenKey);
  }

  // Get auth token
  String? get authToken => _prefs.getString(_authTokenKey);

  // Get user name
  String? get userName => _prefs.getString(_userNameKey);

  // Get user email
  String? get userEmail => _prefs.getString(_userEmailKey);

  // Get user ID
  int? get userId => _prefs.getInt(_userIdKey);

  // Get user profile photo
  String? get userProfilePhoto => _prefs.getString(_userProfilePhotoKey);

  // Get user role ID
  int? get userRoleId => _prefs.getInt(_userRoleIdKey);

  // Get user phone
  String? get userPhone => _prefs.getString(_userPhoneKey);

  // Get user location
  String? get userLocation => _prefs.getString(_userLocationKey);

  // Check if user is logged in
  bool get isLoggedIn => authToken != null && authToken!.isNotEmpty;

  // Clear session data (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_authTokenKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userProfilePhotoKey);
    await _prefs.remove(_userRoleIdKey); // Remove role ID
    await _prefs.remove(_userPhoneKey); // Remove phone
    await _prefs.remove(_userLocationKey); // Remove location
    await _prefs.remove(_resetTokenKey); // Remove reset token
  }
}