class UserModel {
  String id;
  String nom;
  String email;
  String role;

  UserModel({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'nom': nom, 'email': email, 'role': role};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      nom: map['nom'],
      email: map['email'],
      role: map['role'],
    );
  }
}
