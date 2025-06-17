class User {
  final String id;
  final String username;
  final String avatar;
  final String signature;
  final String gmtCreate;
  final String gmtModified;
  final int isDeleted;

  User({
    required this.id,
    required this.username,
    required this.avatar,
    required this.signature,
    required this.gmtCreate,
    required this.gmtModified,
    required this.isDeleted,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String,
      signature: json['signature'] as String,
      gmtCreate: json['gmtCreate'] as String,
      gmtModified: json['gmtModified'] as String,
      isDeleted: json['isDeleted'] as int,
    );
  }
}