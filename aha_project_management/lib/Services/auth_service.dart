class AuthService {
  String? _currentUserId;

  String? getCurrentUserId() {
    return _currentUserId;
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }
}

AuthService authService = AuthService();
