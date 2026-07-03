import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  // Fonction pour afficher une boîte de dialogue et modifier le nom
  Future<void> _modifierNom() async {
    TextEditingController nomController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier le profil"),
          content: TextField(
            controller: nomController,
            decoration: const InputDecoration(
              hintText: "Entrez votre nouveau nom",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomController.text.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Mise à jour du nom dans Firestore
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'nom': nomController.text.trim()});
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Nom mis à jour avec succès !"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context); // Ferme la boîte de dialogue
                    }
                  }
                }
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pas de Scaffold ici car cet écran est affiché à l'intérieur du HomeScreen qui a déjà une AppBar
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // --- Section Compte ---
        const Text(
          "Général",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 10),
        
        Card(
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blueGrey),
                title: const Text("Modifier mon nom"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _modifierNom,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.blueGrey),
                title: const Text("Changer le mot de passe"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fonctionnalité en cours de développement")),
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 25),

        // --- Section Préférences ---
        const Text(
          "Préférences",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 10),
        
        Card(
          elevation: 2,
          child: SwitchListTile(
            title: const Text("Notifications"),
            subtitle: const Text("Rappels pour le retour des ouvrages"),
            secondary: const Icon(Icons.notifications_active, color: Colors.amber),
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
        ),

        const SizedBox(height: 40),

        // --- Bouton Déconnexion ---
        Center(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await AuthService().logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text("Se déconnecter", style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}