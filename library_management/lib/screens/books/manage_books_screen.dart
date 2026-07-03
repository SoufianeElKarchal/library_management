import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_book_screen.dart';

class ManageBooksScreen extends StatelessWidget {
  const ManageBooksScreen({super.key});

  Future<void> supprimerLivre(String id) async {
    await FirebaseFirestore.instance.collection("books").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gérer les livres")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("books").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun livre disponible"));
          }

          final books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.menu_book),

                  title: Text(book["titre"]),

                  subtitle: Text(book["auteur"]),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => EditBookScreen(
                                id: book.id,

                                book: book.data() as Map<String, dynamic>,
                              ),
                            ),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          bool? confirmation = await showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: const Text("Confirmation"),
                                content: const Text("Supprimer ce livre ?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text("Non"),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text("Oui"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmation == true) {
                            supprimerLivre(book.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
