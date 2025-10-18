class User {
  final String id;
  final String email;
  final List<String> roles;
  final String name;
  final String surname;
  final bool isEmailConfirmed;

  User({
    required this.id,
    required this.email,
    required this.roles,
    required this.name,
    required this.surname,
    required this.isEmailConfirmed,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>).cast<String>(),
      name: json['name'] as String,
      surname: json['surname'] as String,
      isEmailConfirmed: json['isEmailConfirmed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'roles': roles,
      'name': name,
      'surname': surname,
      'isEmailConfirmed': isEmailConfirmed,
    };
  }

  String get fullName => '$name $surname'.trim();
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;
  final int expiresIn;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      expiresIn: json['expires_in'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'expires_in': expiresIn,
    };
  }
}

