import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

import './admin_screen.dart';
import '../books/books_screen.dart';
import '../profile/profile_screen.dart';
import './settings_screen.dart'; 

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  List<Widget> get pages => [
    const BooksScreen(), 
    const ProfileScreen(), 
    widget.role == "gerant" ? const AdminScreen() : const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Un fond très légèrement grisé pour faire ressortir les cartes
      extendBody: true, // PERMET AU CONTENU DE DÉFILER DERRIÈRE LA BARRE FLOTTANTE
      
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // Création d'un header avec dégradé et bords arrondis
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
        ),
        title: const Text(
          "Gestion Bibliothèque",
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 22, 
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().logout();
              // On conserve ta logique propre de navigation avec les routes nommées
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),

      body: pages[currentIndex],

      // Création de la barre de navigation flottante
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.indigo,
              unselectedItemColor: Colors.grey[400],
              showSelectedLabels: true,
              showUnselectedLabels: false, // Cache le texte quand ce n'est pas sélectionné
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book, size: 28),
                  label: "Livres",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person, size: 28),
                  label: "Profil",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    widget.role == "gerant"
                        ? Icons.admin_panel_settings_outlined
                        : Icons.settings_outlined,
                  ),
                  activeIcon: Icon(
                    widget.role == "gerant"
                        ? Icons.admin_panel_settings
                        : Icons.settings,
                    size: 28,
                  ),
                  label: widget.role == "gerant" ? "Admin" : "Paramètres",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}