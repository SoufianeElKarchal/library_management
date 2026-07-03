import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditBookScreen extends StatefulWidget {
  final String id;
  final Map<String, dynamic> book;

  const EditBookScreen({super.key, required this.id, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  late TextEditingController titreController;
  late TextEditingController auteurController;
  late TextEditingController descriptionController;
  late TextEditingController imageController;

  late String categorie;
  late bool disponible;

  @override
  void initState() {
    super.initState();

    titreController = TextEditingController(text: widget.book["titre"]);

    auteurController = TextEditingController(text: widget.book["auteur"]);

    descriptionController = TextEditingController(
      text: widget.book["description"],
    );

    imageController = TextEditingController(text: widget.book["imageUrl"]);

    categorie = widget.book["categorie"];
    disponible = widget.book["isAvailable"];
  }

  Future<void> modifierLivre() async {
    await FirebaseFirestore.instance.collection("books").doc(widget.id).update({
      "titre": titreController.text,

      "auteur": auteurController.text,

      "categorie": categorie,

      "description": descriptionController.text,

      "imageUrl": imageController.text,

      "isAvailable": disponible,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Livre modifié")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier le livre")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: titreController,
              decoration: const InputDecoration(labelText: "Titre"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: auteurController,
              decoration: const InputDecoration(labelText: "Auteur"),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: categorie,

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
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: "Image URL"),
            ),

            const SizedBox(height: 15),

            SwitchListTile(
              value: disponible,

              title: const Text("Disponible"),

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
                onPressed: modifierLivre,

                icon: const Icon(Icons.save),

                label: const Text("Enregistrer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
