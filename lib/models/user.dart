class User {
  final int? id;
  final String username;
  final String password;
  final String fullName;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'username': username,
      'password': password,
      'full_name': fullName,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      fullName: map['full_name'] ?? '',
    );
  }
}
