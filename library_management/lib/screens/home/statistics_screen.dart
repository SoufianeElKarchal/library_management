import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  Future<Map<String, int>> _getStats() async {
    // Récupération dynamique des compteurs depuis Firestore
    var booksSnapshot = await FirebaseFirestore.instance.collection('books').count().get();
    var usersSnapshot = await FirebaseFirestore.instance.collection('users').count().get();
    var loansSnapshot = await FirebaseFirestore.instance.collection('loans').count().get();

    return {
      'books': booksSnapshot.count ?? 0,
      'users': usersSnapshot.count ?? 0,
      'loans': loansSnapshot.count ?? 0,
    };
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                Text(
                  count.toString(),
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistiques de la bibliothèque")),
      body: FutureBuilder<Map<String, int>>(
        future: _getStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur lors du chargement des statistiques."));
          }

          var stats = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStatCard("Total des Livres", stats['books']!, Icons.library_books, Colors.blue),
                const SizedBox(height: 15),
                _buildStatCard("Total des Utilisateurs", stats['users']!, Icons.people, Colors.orange),
                const SizedBox(height: 15),
                _buildStatCard("Total des Emprunts", stats['loans']!, Icons.assignment, Colors.green),
              ],
            ),
          );
        },
      ),
    );
  }
}