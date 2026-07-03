import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String searchQuery = "";
  String selectedCategory = "Toutes";
  final List<String> categories = ["Toutes", "Informatique", "Mathématiques", "Roman", "Science"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- Barre de recherche ---
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher un livre...',
                prefixIcon: Icon(Icons.search, color: Colors.indigo),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),

        // --- Filtres par catégorie ---
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedCategory == categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: ChoiceChip(
                  label: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.indigo,
                  backgroundColor: Colors.white,
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedCategory = categories[index];
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // --- Grille des livres (2 par ligne) ---
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("books").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Aucun livre disponible."));
              }

              // Filtrage des résultats
              var books = snapshot.data!.docs.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                var matchesSearch = data['titre'].toString().toLowerCase().contains(searchQuery);
                var matchesCategory = selectedCategory == "Toutes" || data['categorie'] == selectedCategory;
                return matchesSearch && matchesCategory;
              }).toList();

              if (books.isEmpty) {
                return const Center(child: Text("Aucun livre ne correspond à votre recherche."));
              }

              return GridView.builder(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 80), // bottom pour la nav bar flottante
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cartes par ligne
                  crossAxisSpacing: 15, // Espace horizontal entre les cartes
                  mainAxisSpacing: 15, // Espace vertical entre les cartes
                  childAspectRatio: 0.60, // Ratio pour des cartes bien verticales
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  var bookData = books[index].data() as Map<String, dynamic>;
                  String bookId = books[index].id;
                  bool isAvailable = bookData['isAvailable'] ?? false;
                  String imageUrl = bookData['imageUrl'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context, 
                        '/bookDetails', 
                        arguments: {'id': bookId, ...bookData}
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Partie supérieure : Image et Badge
                          Expanded(
                            flex: 4,
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withOpacity(0.05),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  child: imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 50, color: Colors.indigo),
                                          ),
                                        )
                                      : const Icon(Icons.menu_book, size: 50, color: Colors.indigo),
                                ),
                                // Badge Disponibilité positionné sur l'image
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isAvailable ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isAvailable ? "Dispo" : "Emprunté",
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 2. Partie inférieure : Informations textuelles
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bookData['titre'] ?? 'Sans titre',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        bookData['auteur'] ?? 'Auteur inconnu',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          bookData['categorie'] ?? '',
                                          style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.thumb_up, size: 12, color: Colors.blue),
                                          const SizedBox(width: 4),
                                          Text("${bookData['likes'] ?? 0}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}