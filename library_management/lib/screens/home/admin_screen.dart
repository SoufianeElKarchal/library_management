import 'package:flutter/material.dart';
import '../books/add_book_screen.dart';
import '../books/manage_books_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Widget buildCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 35),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Espace Gérant"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 45,
              child: Icon(Icons.admin_panel_settings, size: 50),
            ),

            const SizedBox(height: 15),

            const Text(
              "Bienvenue Gérant",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            buildCard(context, "Ajouter un livre", Icons.add_box, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBookScreen()),
              );
            }),

            buildCard(context, "Gérer les livres", Icons.menu_book, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageBooksScreen()),
              );
            }),

            buildCard(context, "Gestion des utilisateurs", Icons.people, () {}),

            buildCard(context, "Statistiques", Icons.bar_chart, () {}),
          ],
        ),
      ),
    );
  }
}
