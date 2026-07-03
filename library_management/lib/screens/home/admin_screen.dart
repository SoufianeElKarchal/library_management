import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Widget buildCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        const CircleAvatar(
          radius: 45,
          backgroundColor: Colors.blue,
          child: Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            "Espace Gérant",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 30),

        buildCard(context, "Ajouter un livre", Icons.add_box, () {
          Navigator.pushNamed(context, '/addBook');
        }),

        buildCard(context, "Gérer les livres", Icons.menu_book, () {
          Navigator.pushNamed(context, '/manageBooks');
        }),

        // Remplacement de la gestion utilisateur par la gestion des emprunts
        buildCard(context, "Gérer les emprunts", Icons.assignment_turned_in, () {
          Navigator.pushNamed(context, '/manageLoans');
        }),

        buildCard(context, "Statistiques", Icons.bar_chart, () {
          Navigator.pushNamed(context, '/statistics');
        }),
      ],
    );
  }
}