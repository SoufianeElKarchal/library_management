import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _emprunterLivre(String bookId, String titre) async {
    if (currentUserId == null) return;

    await FirebaseFirestore.instance.collection('loans').add({
      'bookId': bookId,
      'userId': currentUserId,
      'date': DateTime.now().toIso8601String(),
      'status': 'en cours',
    });

    await FirebaseFirestore.instance.collection('books').doc(bookId).update({
      'isAvailable': false,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vous avez emprunté : $titre"), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _toggleReaction(String bookId, String type, Map<String, dynamic> bookData) async {
    if (currentUserId == null) return;

    List likedBy = List.from(bookData['likedBy'] ?? []);
    List dislikedBy = List.from(bookData['dislikedBy'] ?? []);
    
    int likesCount = bookData['likes'] ?? 0;
    int dislikesCount = bookData['dislikes'] ?? 0;

    if (type == 'like') {
      if (likedBy.contains(currentUserId)) {
        likedBy.remove(currentUserId);
        likesCount--;
      } else {
        likedBy.add(currentUserId);
        likesCount++;
        if (dislikedBy.contains(currentUserId)) {
          dislikedBy.remove(currentUserId);
          dislikesCount--;
        }
      }
    } else if (type == 'dislike') {
      if (dislikedBy.contains(currentUserId)) {
        dislikedBy.remove(currentUserId);
        dislikesCount--;
      } else {
        dislikedBy.add(currentUserId);
        dislikesCount++;
        if (likedBy.contains(currentUserId)) {
          likedBy.remove(currentUserId);
          likesCount--;
        }
      }
    }

    await FirebaseFirestore.instance.collection('books').doc(bookId).update({
      'likes': likesCount,
      'dislikes': dislikesCount,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
    });
  }

  Future<void> _ajouterCommentaire(String bookId, List currentComments) async {
    if (_commentController.text.trim().isEmpty || currentUserId == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
    final nom = userDoc.data()?['nom'] ?? 'Utilisateur anonyme';

    List updatedComments = List.from(currentComments);
    updatedComments.add({
      'nom': nom,
      'texte': _commentController.text.trim(),
      'date': DateTime.now().toIso8601String(),
    });

    await FirebaseFirestore.instance.collection('books').doc(bookId).update({
      'comments': updatedComments,
    });

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null || !args.containsKey('id')) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur")),
        body: const Center(child: Text("Informations du livre introuvables.")),
      );
    }

    final bookId = args['id'];

    return Scaffold(
      appBar: AppBar(title: const Text("Détails de l'ouvrage")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('books').doc(bookId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Livre introuvable."));
          }

          var bookData = snapshot.data!.data() as Map<String, dynamic>;
          bool isAvailable = bookData['isAvailable'] ?? false;
          List comments = bookData['comments'] ?? [];
          String imageUrl = bookData['imageUrl'] ?? '';
          
          List likedBy = bookData['likedBy'] ?? [];
          List dislikedBy = bookData['dislikedBy'] ?? [];
          bool hasLiked = currentUserId != null && likedBy.contains(currentUserId);
          bool hasDisliked = currentUserId != null && dislikedBy.contains(currentUserId);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Affichage de l'image de couverture ---
                Center(
                  child: Container(
                    height: 250, // Hauteur fixe pour un bel affichage
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  _buildPlaceholderIcon(),
                            )
                          : _buildPlaceholderIcon(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Informations textuelles ---
                Text(
                  bookData['titre'] ?? 'Sans titre',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Par ${bookData['auteur']} | ${bookData['categorie']}",
                  style: TextStyle(fontSize: 18, color: Colors.grey[700], fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 15),
                
                Row(
                  children: [
                    Icon(
                      isAvailable ? Icons.check_circle : Icons.cancel,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAvailable ? "Disponible" : "Emprunté",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  bookData['description'] ?? "Aucune description disponible.",
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isAvailable ? () => _emprunterLivre(bookId, bookData['titre']) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvailable ? Colors.blue : Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isAvailable ? "Emprunter cet ouvrage" : "Indisponible pour le moment",
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Divider(height: 40, thickness: 1),

                // --- Système d'appréciation ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => _toggleReaction(bookId, 'like', bookData),
                      icon: Icon(hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined, color: Colors.blue),
                      label: Text("${bookData['likes'] ?? 0} Likes", style: TextStyle(color: hasLiked ? Colors.blue : Colors.grey)),
                    ),
                    TextButton.icon(
                      onPressed: () => _toggleReaction(bookId, 'dislike', bookData),
                      icon: Icon(hasDisliked ? Icons.thumb_down : Icons.thumb_down_outlined, color: Colors.red),
                      label: Text("${bookData['dislikes'] ?? 0} Dislikes", style: TextStyle(color: hasDisliked ? Colors.red : Colors.grey)),
                    ),
                  ],
                ),
                const Divider(height: 40, thickness: 1),

                // --- Espace Commentaires ---
                const Text("Commentaires", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: "Donnez votre avis...",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _ajouterCommentaire(bookId, comments),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                comments.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("Soyez le premier à commenter !", style: TextStyle(fontStyle: FontStyle.italic)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          var comment = comments[index];
                          String nomAuteur = "Utilisateur";
                          String texteCommentaire = "";

                          if (comment is String) {
                            texteCommentaire = comment;
                          } else if (comment is Map) {
                            nomAuteur = comment['nom'] ?? "Utilisateur";
                            texteCommentaire = comment['texte'] ?? "";
                          }

                          return Card(
                            elevation: 0,
                            color: Colors.grey[100],
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(nomAuteur[0].toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(nomAuteur, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(texteCommentaire),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget utilitaire pour afficher une icône par défaut si l'image ne charge pas
  Widget _buildPlaceholderIcon() {
    return Container(
      width: 170, // Largeur proportionnelle
      color: Colors.indigo.withOpacity(0.1),
      child: const Center(
        child: Icon(Icons.menu_book, size: 80, color: Colors.indigo),
      ),
    );
  }
}