import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final titreController = TextEditingController();
  final auteurController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();

  String categorie = "Informatique";
  bool disponible = true;

  Future<void> ajouterLivre() async {
    if (titreController.text.isEmpty ||
        auteurController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        imageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("books").add({
      "titre": titreController.text.trim(),
      "auteur": auteurController.text.trim(),
      "categorie": categorie,
      "description": descriptionController.text.trim(),
      "imageUrl": imageController.text.trim(),
      "isAvailable": disponible,
      "likes": 0,
      "dislikes": 0,
      "comments": <String>[],
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Livre ajouté avec succès")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un livre")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titreController,
              decoration: const InputDecoration(
                labelText: "Titre",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: auteurController,
              decoration: const InputDecoration(
                labelText: "Auteur",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: categorie,
              decoration: const InputDecoration(
                labelText: "Catégorie",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Informatique",
                  child: Text("Informatique"),
                ),
                DropdownMenuItem(
                  value: "Mathématiques",
                  child: Text("Mathématiques"),
                ),
                DropdownMenuItem(value: "Roman", child: Text("Roman")),
                DropdownMenuItem(value: "Science", child: Text("Science")),
              ],
              onChanged: (value) {
                setState(() {
                  categorie = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: "URL de l'image",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            SwitchListTile(
              title: const Text("Disponible"),
              value: disponible,
              onChanged: (value) {
                setState(() {
                  disponible = value;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: ajouterLivre,
                icon: const Icon(Icons.save),
                label: const Text("Ajouter le livre"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
