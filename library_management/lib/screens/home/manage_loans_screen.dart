import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageLoansScreen extends StatelessWidget {
  const ManageLoansScreen({super.key});

  // Fonction pour accepter ou refuser un emprunt
  Future<void> _traiterEmprunt(BuildContext context, String loanId, String bookId, bool isAccepted) async {
    String nouveauStatus = isAccepted ? 'confirmé' : 'refusé';

    // 1. Mettre à jour le statut de l'emprunt
    await FirebaseFirestore.instance.collection('loans').doc(loanId).update({
      'status': nouveauStatus,
    });

    // 2. Si refusé, le livre redevient disponible
    if (!isAccepted) {
      await FirebaseFirestore.instance.collection('books').doc(bookId).update({
        'isAvailable': true,
      });
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("L'emprunt a été $nouveauStatus."),
          backgroundColor: isAccepted ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestion des Emprunts")),
      body: StreamBuilder<QuerySnapshot>(
        // On ne récupère que les emprunts en attente
        stream: FirebaseFirestore.instance.collection('loans').where('status', isEqualTo: 'en cours').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Aucun emprunt en attente.", style: TextStyle(fontSize: 18)),
            );
          }

          var loans = snapshot.data!.docs;

          return ListView.builder(
            itemCount: loans.length,
            itemBuilder: (context, index) {
              var loanData = loans[index].data() as Map<String, dynamic>;
              String loanId = loans[index].id;
              String bookId = loanData['bookId'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Utilisation d'un FutureBuilder pour aller chercher le titre du livre
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
                        builder: (context, bookSnapshot) {
                          if (bookSnapshot.hasData && bookSnapshot.data!.exists) {
                            return Text(
                              "Livre : ${bookSnapshot.data!['titre']}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            );
                          }
                          return const Text("Chargement du livre...");
                        },
                      ),
                      const SizedBox(height: 5),
                      Text("Date : ${loanData['date'].toString().substring(0, 10)}"),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => _traiterEmprunt(context, loanId, bookId, false),
                            icon: const Icon(Icons.close, color: Colors.white),
                            label: const Text("Refuser", style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () => _traiterEmprunt(context, loanId, bookId, true),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text("Confirmer", style: TextStyle(color: Colors.white)),
                          ),
                        ],
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