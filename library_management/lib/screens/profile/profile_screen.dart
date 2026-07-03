import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Center(child: Text("Aucun utilisateur connecté."));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text("Impossible de charger le profil."));
        }

        var userData = userSnapshot.data!.data() as Map<String, dynamic>;
        String nom = userData['nom'] ?? 'Utilisateur';
        String email = userData['email'] ?? '';
        String role = userData['role'] ?? 'etudiant';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- En-tête du profil ---
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: role == 'gerant' ? Colors.orange[100] : Colors.blue[100],
                      child: Text(
                        nom[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: role == 'gerant' ? Colors.orange[800] : Colors.blue[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      nom,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        role == 'gerant' ? "Gérant de la bibliothèque" : "Étudiant",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: role == 'gerant' ? Colors.orange[200] : Colors.blue[200],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Divider(thickness: 1),
              const SizedBox(height: 15),

              // --- Section conditionnelle selon le rôle ---
              if (role == 'gerant') ...[
                const Text(
                  "Tableau de bord Administrateur",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.security, color: Colors.orange),
                    title: Text("Accès Total au Catalogue"),
                    subtitle: Text("Vous pouvez ajouter, modifier et supprimer des ouvrages depuis l'onglet Admin."),
                  ),
                ),
              ] else ...[
                // Si c'est un étudiant, on affiche son historique d'emprunts
                const Text(
                  "Mon Historique d'Emprunts",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _buildLoansList(),
              ],
            ],
          ),
        );
      },
    );
  }

  // Widget qui écoute en temps réel les emprunts de l'étudiant connecté
  Widget _buildLoansList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('loans')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, loanSnapshot) {
        if (loanSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!loanSnapshot.hasData || loanSnapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("Vous n'avez pas encore emprunté d'ouvrages."),
          );
        }

        var loans = loanSnapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: loans.length,
          itemBuilder: (context, index) {
            var loanData = loans[index].data() as Map<String, dynamic>;
            String bookId = loanData['bookId'] ?? '';
            String status = loanData['status'] ?? 'en cours';
            String dateRaw = loanData['date'] ?? '';
            
            // Formatage basique de la date (YYYY-MM-DD)
            String dateFormatted = dateRaw.length >= 10 ? dateRaw.substring(0, 10) : dateRaw;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(
                  status == 'rendu' ? Icons.assignment_turned_in : Icons.menu_book,
                  color: status == 'rendu' ? Colors.green : Colors.blue,
                ),
                // Appel d'un widget secondaire pour récupérer le titre du livre via son ID
                title: _BookTitleWidget(bookId: bookId),
                subtitle: Text("Emprunté le : $dateFormatted"),
                trailing: Chip(
                  label: Text(
                    status.toUpperCase(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: status == 'rendu' ? Colors.green : Colors.orange,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Widget secondaire servant à récupérer le titre d'un livre à partir de son identifiant
class _BookTitleWidget extends StatelessWidget {
  final String bookId;

  const _BookTitleWidget({required this.bookId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Chargement du titre...", style: TextStyle(color: Colors.grey));
        }
        if (snapshot.hasData && snapshot.data!.exists) {
          var bookData = snapshot.data!.data() as Map<String, dynamic>;
          return Text(
            bookData['titre'] ?? 'Sans titre',
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }
        return const Text("Livre supprimé ou introuvable", style: TextStyle(fontStyle: FontStyle.italic));
      },
    );
  }
}