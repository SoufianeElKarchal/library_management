import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'books_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    BooksScreen(),

    ProfileScreen(),

    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Management"),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () async {
              await AuthService().logout();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Livres"),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),

            label: "Paramètres",
          ),
        ],
      ),

      floatingActionButton: widget.role == "gerant"
          ? FloatingActionButton(
              onPressed: () {
                // Ajouter un livre
              },

              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
