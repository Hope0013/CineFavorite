class UserModel {
  // Atributos
  final int? id;
  final String name;
  final String profilePic;

  UserModel({
    this.id,
    required this.name,
    required this.profilePic,
  });

  factory UserModel.fromDbMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      // Se por algum motivo o banco de dados retornar nulo para a foto de perfil, o modelo já garante uma imagem padrão da Netflix. 
      // Isso evita telas cinzas ou erros de carregamento de imagem
      profilePic: map['profile_pic'] ?? 'https://upload.wikimedia.org/wikipedia/commons/0/0b/Netflix-avatar.png',
    );
  }
}