class UserModel {
  final int? id;
  final String name;
  final String profilePic; // Sem o '?' para garantir que não seja nulo

  UserModel({
    this.id,
    required this.name,
    required this.profilePic,
  });

  factory UserModel.fromDbMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      profilePic: map['profile_pic'] ?? 'https://upload.wikimedia.org/wikipedia/commons/0/0b/Netflix-avatar.png',
    );
  }
}