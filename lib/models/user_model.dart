class UserModel {
  final int? id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  const UserModel({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'avatar': avatar,
  };

  String get fullName => '$firstName $lastName'.trim();
}