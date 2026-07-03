class BookModel {
  String id;
  String titre;
  String auteur;
  String categorie;
  String description;
  bool isAvailable;
  int likes;
  int dislikes;
  List comments;

  BookModel({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.categorie,
    required this.description,
    required this.isAvailable,
    required this.likes,
    required this.dislikes,
    required this.comments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'auteur': auteur,
      'categorie': categorie,
      'description': description,
      'isAvailable': isAvailable,
      'likes': likes,
      'dislikes': dislikes,
      'comments': comments,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'],
      titre: map['titre'],
      auteur: map['auteur'],
      categorie: map['categorie'],
      description: map['description'],
      isAvailable: map['isAvailable'],
      likes: map['likes'],
      dislikes: map['dislikes'],
      comments: List.from(map['comments']),
    );
  }
}
