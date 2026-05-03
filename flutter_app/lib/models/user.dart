class AppUser {
  final int    id;
  final String username;
  final String role; // admin | user | guest
  final String token;

  const AppUser({
    required this.id,
    required this.username,
    required this.role,
    required this.token,
  });

  bool get canWrite   => role == 'admin' || role == 'user';
  bool get canDelete  => role == 'admin';
  bool get isAdmin    => role == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> j, String token) => AppUser(
        id:       j['id'] as int,
        username: j['username'] as String,
        role:     j['role'] as String,
        token:    token,
      );
}
